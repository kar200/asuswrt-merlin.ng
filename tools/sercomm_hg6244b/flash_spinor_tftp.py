#!/usr/bin/env python3
"""
flash_spinor_tftp.py - flash the SPI-NOR U-Boot payload over the network.

Much faster than the YMODEM route (which runs at ~9.6 KB/s over the 115200
console): the image is pulled with tftpboot into RAM, then written with
`sf update`.  At ~2 MB/s a 2.9 MB payload takes a couple of seconds instead
of five minutes.

Safety properties, same as the YMODEM flasher:
  * writes SPI NOR only - it NEVER issues any mmc command, so the eMMC is
    not touched
  * never issues `reset`; the board is cold power-cycled by hand
  * verification is a SECOND `sf update` (compare-only), which reports
    "0 bytes written, N bytes skipped" when flash == RAM.  `sf read` is
    deliberately not used; it crashes this U-Boot.

The image must be reachable from the board's TFTP server (env `serverip`,
default 192.168.1.100).

Usage:
    flash_spinor_tftp.py <tftp-filename> <length> [uart-host]
Example:
    flash_spinor_tftp.py spinor_16MB_full.bin 0x2E0000
"""

import os
import socket
import sys
import time
import zlib

UART_HOST = "172.16.1.110"
UART_PORT = 8888

TFTP_ADDR = 0x04000000          # U-Boot load address
FLASH_OFFSET = 0x0
TFTP_SERVER_PORT = 6969         # port 69 needs root; server runs high and
                                # U-Boot is pointed at it with $tftpdstp
                                # (set for this transfer only, never saved)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 1
    fname = os.path.basename(sys.argv[1])
    length = int(sys.argv[2], 0) if len(sys.argv) > 2 else 0x2E0000
    host = sys.argv[3] if len(sys.argv) > 3 else UART_HOST
    tftp_port = int(sys.argv[4], 0) if len(sys.argv) > 4 else TFTP_SERVER_PORT

    # Local copy, used to compute the CRC we expect the board to report.
    local = None
    here = os.path.dirname(os.path.abspath(__file__))
    for cand in (os.path.join(here, "deliverables", fname),
                 os.path.join(here, fname), fname):
        if os.path.isfile(cand):
            local = cand
            break

    print("TFTP file : %s" % fname)
    print("Length    : 0x%x bytes (%.2f MiB)" % (length, length / 1048576.0))
    print("Flash offs: 0x%x" % FLASH_OFFSET)
    if local:
        data = open(local, "rb").read()[:length]
        expected = zlib.crc32(data) & 0xFFFFFFFF
        print("Local copy: %s -> CRC32 %08x" % (local, expected))
    else:
        print("Local copy not found; will not be able to check the RAM CRC")

    s = socket.create_connection((host, UART_PORT), timeout=8)
    s.settimeout(0.5)

    def drain(sec, stop_at_prompt=True):
        end = time.time() + sec
        buf = b""
        while time.time() < end:
            try:
                d = s.recv(8192)
                if d:
                    buf += d
                    # return as soon as U-Boot is back at its prompt rather
                    # than blocking for the full budget
                    if stop_at_prompt and b"=>" in buf[-200:]:
                        break
            except socket.timeout:
                pass
        return buf.decode("latin1", "replace")

    def clean(t):
        return "\n".join(l for l in t.splitlines()
                         if "bbh full" not in l and "Failed to send" not in l
                         and l.strip())

    def run(cmd, wait=8.0):
        drain(0.4)
        s.sendall(cmd.encode() + b"\r\n")
        return clean(drain(wait))

    # get to a prompt
    for _ in range(4):
        if "=>" in drain(1.5):
            break
        s.sendall(b"\r\n")
    else:
        s.sendall(b"\x03")
        drain(1.5)

    print("\n--- track server port (temporary, not saved) ---")
    run("setenv tftpdstp %d" % tftp_port)
    print(run("printenv serverip ipaddr tftpdstp"))

    print("\n--- tftpboot ---")
    out = run("tftpboot 0x%x %s" % (TFTP_ADDR, fname), wait=60.0)
    print(out)
    if "Bytes transferred" not in out and "TFTP error" not in out:
        print("WARNING: no 'Bytes transferred' in the output")

    if local and "=>" in out:
        print("\n--- RAM CRC32 ---")
        out = run("crc32 0x%x 0x%x" % (TFTP_ADDR, length), wait=20.0)
        print(out)
        if "%08x" % expected not in out:
            print("ERROR: RAM CRC32 mismatch - NOT flashing.")
            s.close()
            return 1
        print("RAM CRC32 OK")

    print("\n--- sf probe ---")
    out = run("sf probe 0:0")
    print(out)
    if "SF: Detected" not in out:
        print("ERROR: SPI NOR probe failed - NOT flashing.")
        s.close()
        return 1

    print("\n--- sf update (write) ---")
    out = run("sf update 0x%x 0x%x 0x%x" % (TFTP_ADDR, FLASH_OFFSET, length),
              wait=120.0)
    print(out)
    if "failed" in out.lower():
        print("ERROR: sf update reported a failure.")
        s.close()
        return 1

    print("\n--- sf update (compare-only verify) ---")
    out = run("sf update 0x%x 0x%x 0x%x" % (TFTP_ADDR, FLASH_OFFSET, length),
              wait=120.0)
    print(out)
    if "0 bytes written" in out:
        print("\n*** FLASH VERIFIED: flash content matches RAM exactly ***")
    else:
        print("\nWARNING: verification did not report '0 bytes written'")

    print("\neMMC untouched (no mmc command issued).")
    print("Cold power-cycle the board - not the software 'reset' command.")
    s.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
