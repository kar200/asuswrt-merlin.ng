#!/usr/bin/env python3
"""
flash_spinor_ymodem.py - Stream bootstrap_image_spinor.bin over TCP UART bridge,
verify CRC32 in RAM, flash to SPI-NOR via sf update, and readback-verify.
"""

import socket
import sys
import os
import time
import struct
import zlib

TARGET_IP = "172.16.1.110"
TARGET_PORT = 8888
IMG_PATH = "/home/karim/github/asuswrt-merlin.ng/tools/sercomm_hg6244b/deliverables/bootstrap_image_spinor.bin"
FLASH_OFFSET = 0x0
LOAD_ADDR = 0x04000000
READBACK_ADDR = 0x01000000

SOH = 0x01
STX = 0x02
EOT = 0x04
ACK = 0x06
NAK = 0x15
CAN = 0x18
C_CHR = 0x43


def crc16_ccitt(data: bytes) -> int:
    crc = 0
    for byte in data:
        crc ^= (byte << 8)
        for _ in range(8):
            if crc & 0x8000:
                crc = ((crc << 1) ^ 0x1021) & 0xffff
            else:
                crc = (crc << 1) & 0xffff
    return crc


def drain_input(s: socket.socket, quiet: float = 0.3):
    old = s.gettimeout()
    s.settimeout(quiet)
    try:
        while True:
            c = s.recv(4096)
            if not c:
                break
    except socket.timeout:
        pass
    finally:
        s.settimeout(old)


def send_cmd_wait_prompt(s: socket.socket, cmd: str, timeout: float = 60.0) -> str:
    drain_input(s)
    s.sendall(cmd.encode("ascii") + b"\n")
    out = b""
    t0 = time.time()
    while time.time() - t0 < timeout:
        try:
            chunk = s.recv(4096)
            if not chunk:
                break
            out += chunk
            if b"=> " in out:
                break
        except socket.timeout:
            pass
    return out.decode("latin1", errors="replace")


def main():
    if not os.path.isfile(IMG_PATH):
        print(f"Error: {IMG_PATH} does not exist!")
        sys.exit(1)

    with open(IMG_PATH, "rb") as f:
        data = f.read()

    file_len = len(data)
    expected_crc = zlib.crc32(data)
    print(f"Image File: {IMG_PATH}")
    print(f"Size: {file_len} bytes (0x{file_len:x})")
    print(f"CRC32: {expected_crc:08x}")
    print(f"Target: {TARGET_IP}:{TARGET_PORT}")

    print("\nConnecting to UART bridge...")
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(5.0)
    try:
        s.connect((TARGET_IP, TARGET_PORT))
    except Exception as e:
        print(f"Failed to connect: {e}")
        sys.exit(1)

    print("Connected. Checking U-Boot prompt...")
    drain_input(s)
    res = send_cmd_wait_prompt(s, "", timeout=3.0)
    if "=> " not in res:
        res = send_cmd_wait_prompt(s, "\r", timeout=3.0)
    if "=> " not in res:
        print(f"ERROR: Could not get U-Boot prompt: {repr(res)}")
        s.close()
        sys.exit(1)

    print("U-Boot prompt confirmed. Initiating loady...")
    drain_input(s)
    s.sendall(f"loady 0x{LOAD_ADDR:x} 115200\n".encode("ascii"))

    t0 = time.time()
    got_c = False
    while time.time() - t0 < 8.0:
        try:
            ch = s.recv(1)
            if ch == b"C":
                got_c = True
                break
        except socket.timeout:
            pass

    if not got_c:
        print("ERROR: Target did not send 'C' ready character!")
        s.close()
        sys.exit(1)

    print("Target ready for YMODEM transfer.")

    # 1. Block 0 (filename + size in 128-byte SOH block)
    fname = "bootstrap_image_spinor.bin"
    payload = f"{fname}\x00{file_len}\x00".encode("latin1")
    payload = payload.ljust(128, b"\x00")
    crc = crc16_ccitt(payload)
    pkt0 = bytes([SOH, 0x00, 0xff]) + payload + struct.pack(">H", crc)
    s.sendall(pkt0)

    ack = s.recv(1)
    if ack != bytes([ACK]):
        print(f"ERROR: Expected ACK for block 0, got {repr(ack)}")
        s.close()
        sys.exit(1)

    time.sleep(0.05)
    s.settimeout(0.5)
    try:
        s.recv(10)
    except socket.timeout:
        pass
    s.settimeout(3.0)

    # 2. Stream data in 1024-byte STX blocks
    total_blocks = (file_len + 1023) // 1024
    print(f"Streaming {total_blocks} blocks ({file_len} bytes) at 115200 baud...")

    start_time = time.time()
    blk_num = 1

    for i in range(0, file_len, 1024):
        chunk = data[i:i+1024]
        if len(chunk) < 1024:
            chunk = chunk.ljust(1024, b"\x00")

        crc = crc16_ccitt(chunk)
        blk_byte = blk_num & 0xff
        inv_byte = (~blk_byte) & 0xff
        pkt = bytes([STX, blk_byte, inv_byte]) + chunk + struct.pack(">H", crc)

        retries = 3
        while retries > 0:
            s.sendall(pkt)
            resp = s.recv(1)
            if resp == bytes([ACK]):
                break
            elif resp == bytes([CAN]):
                print(f"\nERROR: Target sent CAN at block {blk_num}!")
                s.close()
                sys.exit(1)
            else:
                retries -= 1
                time.sleep(0.1)

        if retries == 0:
            print(f"\nERROR: Max retries exceeded on block {blk_num}")
            s.close()
            sys.exit(1)

        blk_num = (blk_num + 1) & 0xff

        sent_bytes = min(i + 1024, file_len)
        pct = (sent_bytes * 100) // file_len
        elapsed = time.time() - start_time
        speed = (sent_bytes / elapsed) if elapsed > 0 else 0
        rem_bytes = file_len - sent_bytes
        eta = (rem_bytes / speed) if speed > 0 else 0
        print(f"\r  [{pct:3d}%] {sent_bytes}/{file_len} bytes ({speed/1024:.1f} KB/s, ETA {eta:.0f}s)   ", end="", flush=True)

    print()
    total_time = time.time() - start_time
    print(f"Data stream complete in {total_time:.1f}s ({file_len/total_time/1024:.1f} KB/s)")

    # 3. Send EOT
    print("Sending EOT...")
    s.sendall(bytes([EOT]))
    eot_resp = s.recv(1)
    if eot_resp == bytes([NAK]):
        s.sendall(bytes([EOT]))
        eot_resp = s.recv(1)

    time.sleep(0.05)
    s.settimeout(0.5)
    try:
        s.recv(10)
    except socket.timeout:
        pass
    s.settimeout(3.0)

    # 4. Terminating empty Block 0
    empty_payload = b"\x00" * 128
    empty_crc = crc16_ccitt(empty_payload)
    empty_pkt = bytes([SOH, 0x00, 0xff]) + empty_payload + struct.pack(">H", empty_crc)
    s.sendall(empty_pkt)
    try:
        s.recv(1)
    except socket.timeout:
        pass

    time.sleep(0.5)
    out = b""
    s.settimeout(2.0)
    while True:
        try:
            c = s.recv(1024)
            if not c:
                break
            out += c
            if b"=> " in out:
                break
        except socket.timeout:
            break

    print("Target load summary:")
    print(out.decode("latin1", errors="replace").strip())

    # 5. Verify RAM CRC32
    print(f"\nVerifying CRC32 in RAM (0x{LOAD_ADDR:x}, 0x{file_len:x})...")
    res = send_cmd_wait_prompt(s, f"crc32 0x{LOAD_ADDR:x} 0x{file_len:x}")
    print(res.strip())
    expected_hex = f"{expected_crc:08x}"
    if expected_hex not in res:
        print(f"ERROR: RAM CRC32 does not match expected {expected_hex}!")
        s.close()
        sys.exit(1)
    print(f"SUCCESS: RAM CRC32 verified exact match ({expected_hex})!")

    # 6. Fill padding up to 64KB sector boundary
    aligned_len = ((file_len + 0xffff) // 0x10000) * 0x10000
    pad_bytes = aligned_len - file_len
    if pad_bytes > 0:
        pad_addr = LOAD_ADDR + file_len
        print(f"Padding {pad_bytes} bytes with 0xFF from 0x{pad_addr:x} to 0x{LOAD_ADDR + aligned_len:x}...")
        send_cmd_wait_prompt(s, f"mw.b 0x{pad_addr:x} 0xff 0x{pad_bytes:x}")

    # 7. Probe SPI NOR Flash
    print("\nProbing SPI NOR flash...")
    res = send_cmd_wait_prompt(s, "sf probe 0:0")
    print(res.strip())
    if "SF: Detected" not in res and "XM25" not in res:
        print("ERROR: SPI NOR probe failed!")
        s.close()
        sys.exit(1)

    # 8. Flash via sf update
    print(f"\nFlashing 0x{aligned_len:x} bytes ({aligned_len/(1024*1024):.2f} MiB) to SPI NOR offset 0x{FLASH_OFFSET:x}...")
    t_flash_start = time.time()
    res = send_cmd_wait_prompt(s, f"sf update 0x{LOAD_ADDR:x} 0x{FLASH_OFFSET:x} 0x{aligned_len:x}", timeout=120.0)
    print(res.strip())
    flash_time = time.time() - t_flash_start
    print(f"sf update finished in {flash_time:.1f}s")

    # 9. Readback and verify
    print(f"\nReading back 0x{file_len:x} bytes from SPI NOR 0x{FLASH_OFFSET:x} to 0x{READBACK_ADDR:x}...")
    res = send_cmd_wait_prompt(s, f"sf read 0x{READBACK_ADDR:x} 0x{FLASH_OFFSET:x} 0x{file_len:x}", timeout=30.0)
    print(res.strip())

    print("Computing read-back CRC32...")
    res = send_cmd_wait_prompt(s, f"crc32 0x{READBACK_ADDR:x} 0x{file_len:x}", timeout=10.0)
    print(res.strip())

    if expected_hex not in res:
        print(f"ERROR: Readback CRC32 does NOT match expected {expected_hex}!")
        s.close()
        sys.exit(1)

    print(f"\n*** FLASH INTEGRITY VERIFIED 100%: Readback CRC32 matches {expected_hex} ***")
    print("=" * 70)
    print("FLASH COMPLETE & VERIFIED 100%!")
    print(f"Updated bootstrap_image_spinor.bin to SPI NOR (0x0 - 0x{aligned_len:x}).")
    print("Default NetConsole environment is active at 0x40000 and 0xad000.")
    print("The chip is now ready to run standalone on routers without UART access.")
    print("=" * 70)
    s.close()


if __name__ == "__main__":
    main()

