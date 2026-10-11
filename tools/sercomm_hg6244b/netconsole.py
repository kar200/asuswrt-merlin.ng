#!/usr/bin/env python3
"""
U-Boot NetConsole Client in Pure Python 3.
Zero external dependencies. Works on Linux, macOS, and BSD.

Replaces brittle combinations of netcat (nc) and ncb.
"""

import sys
import os
import socket
import select
import argparse
import signal
import time

try:
    import termios
    import tty
    HAS_TERMIOS = True
except ImportError:
    HAS_TERMIOS = False


def setup_terminal():
    """Put stdin into raw mode if it's a TTY."""
    if not (HAS_TERMIOS and sys.stdin.isatty()):
        return None
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    tty.setraw(fd)
    return old_settings


def restore_terminal(old_settings):
    """Restore original terminal settings."""
    if HAS_TERMIOS and old_settings is not None and sys.stdin.isatty():
        try:
            termios.tcsetattr(sys.stdin.fileno(), termios.TCSADRAIN, old_settings)
        except Exception:
            pass


def main():
    parser = argparse.ArgumentParser(
        description="Interactive U-Boot NetConsole Client (Pure Python)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exit hotkey: Ctrl+] or Ctrl+\\
Interrupt (to U-Boot): Ctrl+C
"""
    )
    parser.add_argument(
        "target_ip",
        nargs="?",
        default="192.168.1.1",
        help="U-Boot IP address (default: 192.168.1.1)"
    )
    parser.add_argument(
        "-p", "--port",
        type=int,
        default=6666,
        help="U-Boot target port (default: 6666)"
    )
    parser.add_argument(
        "-l", "--listen-port",
        type=int,
        default=None,
        help="Local UDP listening port (default: same as target port)"
    )
    parser.add_argument(
        "-b", "--listen-only",
        action="store_true",
        help="Listen only mode (acts like ncb: dumps incoming UDP packets to stdout)"
    )
    parser.add_argument(
        "--no-auto-enter",
        action="store_true",
        help="Do not send initial newline on connect"
    )

    args = parser.parse_args()

    listen_port = args.listen_port if args.listen_port is not None else args.port
    target_ip = args.target_ip
    target_port = args.port

    # Create UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    except (AttributeError, OSError):
        pass
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

    try:
        sock.bind(("0.0.0.0", listen_port))
    except OSError as e:
        sys.stderr.write(f"Error binding to 0.0.0.0:{listen_port}: {e}\n")
        sys.stderr.write("Check if another process (nc, ncb, etc.) is already using the port.\n")
        sys.exit(1)

    # Listen-only mode (drop-in replacement for ncb)
    if args.listen_only:
        sys.stderr.write(f"Listening on UDP port {listen_port} (broadcast enabled)...\n")
        try:
            while True:
                data, addr = sock.recvfrom(4096)
                sys.stdout.buffer.write(data)
                sys.stdout.buffer.flush()
        except KeyboardInterrupt:
            pass
        finally:
            sock.close()
        return

    is_interactive = sys.stdin.isatty() and HAS_TERMIOS
    old_term_settings = None

    if is_interactive:
        sys.stderr.write(
            f"=== Connected to U-Boot at {target_ip}:{target_port} (listening on :{listen_port}) ===\r\n"
            f"=== Press Ctrl+] or Ctrl+\\ to exit. Press Ctrl+C to send break/interrupt to U-Boot. ===\r\n\r\n"
        )
        sys.stderr.flush()
        old_term_settings = setup_terminal()

        # Send initial enter to wake up prompt if board is already sitting at prompt
        if not args.no_auto_enter:
            try:
                sock.sendto(b"\r", (target_ip, target_port))
            except Exception:
                pass

    try:
        # Non-interactive mode (piped input)
        if not is_interactive:
            in_data = sys.stdin.buffer.read()
            if in_data:
                sock.sendto(in_data, (target_ip, target_port))
            
            # Wait for response with timeout
            sock.settimeout(2.0)
            while True:
                try:
                    data, addr = sock.recvfrom(4096)
                    sys.stdout.buffer.write(data)
                    sys.stdout.buffer.flush()
                except socket.timeout:
                    break
            return

        # Interactive loop
        stdin_fd = sys.stdin.fileno()
        sock_fd = sock.fileno()

        ctrl_c_count = 0
        last_ctrl_c_time = 0

        while True:
            rlist, _, _ = select.select([stdin_fd, sock_fd], [], [])

            if sock_fd in rlist:
                data, addr = sock.recvfrom(4096)
                if data:
                    # Convert bare newlines to \r\n to prevent staircasing in raw terminal
                    formatted = data.replace(b"\r\n", b"\n").replace(b"\n", b"\r\n")
                    sys.stdout.buffer.write(formatted)
                    sys.stdout.buffer.flush()

            if stdin_fd in rlist:
                user_input = os.read(stdin_fd, 1024)
                if not user_input:
                    break

                # Check for exit shortcuts:
                # 0x1d = Ctrl+], 0x1c = Ctrl+\, 0x11 = Ctrl+Q
                if b"\x1d" in user_input or b"\x1c" in user_input or b"\x11" in user_input:
                    break

                # Handle Ctrl+C (0x03): send to U-Boot as interrupt,
                # but if user presses it 3 times within 1 second, offer exit
                if user_input == b"\x03":
                    now = time.time()
                    if now - last_ctrl_c_time < 1.0:
                        ctrl_c_count += 1
                    else:
                        ctrl_c_count = 1
                    last_ctrl_c_time = now

                    if ctrl_c_count >= 3:
                        sys.stdout.buffer.write(b"\r\n[Exit on triple Ctrl+C]\r\n")
                        sys.stdout.buffer.flush()
                        break

                # Send input to U-Boot
                sock.sendto(user_input, (target_ip, target_port))

    except (KeyboardInterrupt, SystemExit):
        pass
    finally:
        if old_term_settings is not None:
            restore_terminal(old_term_settings)
            sys.stdout.buffer.write(b"\r\n[Disconnected]\r\n")
            sys.stdout.buffer.flush()
        sock.close()


if __name__ == "__main__":
    main()

