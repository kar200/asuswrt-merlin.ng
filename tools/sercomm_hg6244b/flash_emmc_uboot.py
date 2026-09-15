#!/usr/bin/env python3
"""
flash_emmc_uboot.py - write U-Boot into the eMMC boot0 partition ONLY.

The board's eMMC layout puts the bootloader in boot0 (mmc hwpart 1) with the
same split as SPI NOR:

    boot0 offset 0x000000  (block 0x0000)  ->  2 MiB loader region
    boot0 offset 0x200000  (block 0x1000)  ->  bootstrap FIT (U-Boot proper)

Offsets are explicit and nothing outside those two ranges is touched.

SAFETY
  * writes ONLY mmc hwpart 1 (boot0).  hwpart 0 - the user area, its GPT and
    every partition - is never written.  `mmc dev 0 0` is only used to restore
    the default device at the end.
  * no erase of the partition, no GPT write
  * every write is verified by reading the blocks back with `mmc read` and
    comparing CRC32 against the local file
  * never issues `reset`; cold power-cycle by hand
"""

import os
import socket
import sys
import time
import zlib

UART_HOST = "172.16.1.110"
UART_PORT = 8888
TFTP_PORT = 6969

LOAD_ADDR = 0x04000000
BOOT0_HWPART = 1
LOADER_BLOCKS = 0x1000          # 2 MiB
FIT_BLOCK_OFF = 0x1000          # 2 MiB into boot0
FIT_BLOCKS = 0x6DC              # 1756 blocks = 899072 bytes (FIT padded with 0xFF)

HERE = os.path.dirname(os.path.abspath(__file__))
FIT_DIR = os.environ.get("EMMC_FIT_DIR", os.path.join(HERE, "deliverables"))
LOADER_FILE = os.environ.get("EMMC_LOADER_FILE",
                              "bootstrap_image_emmc_boot_part.bin")
FIT_FILE = os.environ.get("EMMC_FIT_FILE", "brcm_simple.itb")


def main():
    ld = open(os.path.join(FIT_DIR, LOADER_FILE), "rb").read()
    fit = open(os.path.join(FIT_DIR, FIT_FILE), "rb").read()
    blocks = (len(fit) + 511) // 512
    pad = blocks * 512 - len(fit)
    padded = fit + b"\xff" * pad
    ld_crc = zlib.crc32(ld) & 0xFFFFFFFF
    fit_crc = zlib.crc32(fit) & 0xFFFFFFFF
    padded_crc = zlib.crc32(padded) & 0xFFFFFFFF
    print("loader : %d bytes  crc32 %08x  -> boot0 block 0x0     (%d blocks)"
          % (len(ld), ld_crc, LOADER_BLOCKS))
    print("FIT    : %d bytes  crc32 %08x  -> boot0 block 0x%x  (%d blocks, pad %d)"
          % (len(fit), fit_crc, FIT_BLOCK_OFF, blocks, pad))
    assert blocks == FIT_BLOCKS, "FIT block count changed: %d" % blocks

    s = socket.create_connection((UART_HOST, UART_PORT), timeout=8)
    s.settimeout(0.4)

    def drain(sec, stop_at_prompt=True):
        end = time.time() + sec
        buf = b""
        while time.time() < end:
            try:
                d = s.recv(8192)
                if d:
                    buf += d
                    if stop_at_prompt and b"=>" in buf[-200:]:
                        break
            except socket.timeout:
                pass
        return buf.decode("latin1", "replace")

    def clean(t):
        return "\n".join(l for l in t.splitlines()
                         if "bbh full" not in l and "Failed to send" not in l
                         and l.strip())

    def resync():
        """Get back to a known prompt after stray bytes corrupt a command."""
        for _ in range(6):
            s.sendall(b"\r")
            if "=>" in drain(1.0):
                return True
        s.sendall(b"\x03")
        return "=>" in drain(1.5)

    def run(cmd, wait=10.0, tries=3):
        out = ""
        for attempt in range(tries):
            drain(0.5)
            s.sendall(cmd.encode() + b"\r\n")
            out = clean(drain(wait))
            # the console echoes the command; if the first token is missing the
            # line was corrupted by a stray byte, so resync and retry
            if cmd.split()[0] in out:
                return out
            print("   [stray byte on %r - resync + retry %d]" % (cmd, attempt + 1))
            resync()
        return out

    resync()

    for _ in range(5):
        if "=>" in drain(1.5):
            break
        s.sendall(b"\r\n")

    # keep the console quiet during the mmc writes
    print("\n--- tftpboot loader ---")
    out = run("tftpboot 0x%x %s" % (LOAD_ADDR, LOADER_FILE), wait=60.0)
    print(out)
    if "Bytes transferred" not in out:
        print("ERROR: loader transfer failed"); s.close(); return 1
    out = run("crc32 0x%x 0x%x" % (LOAD_ADDR, len(ld)), wait=20.0)
    print(out)
    if "%08x" % ld_crc not in out:
        print("ERROR: loader RAM CRC mismatch"); s.close(); return 1

    print("\n--- writing loader to boot0 block 0x0 ---")
    print(run("mmc dev 0 %d" % BOOT0_HWPART))
    print(run("mmc write 0x%x 0x0 0x%x" % (LOAD_ADDR, LOADER_BLOCKS), wait=60.0))

    print("\n--- tftpboot FIT ---")
    out = run("tftpboot 0x%x %s" % (LOAD_ADDR, FIT_FILE), wait=60.0)
    print(out)
    if "Bytes transferred" not in out:
        print("ERROR: FIT transfer failed"); s.close(); return 1

    # pad the tail of the last block with 0xFF so we do not write stale RAM
    print(run("mw.b 0x%x 0xff 0x%x" % (LOAD_ADDR + len(fit), pad)))
    out = run("crc32 0x%x 0x%x" % (LOAD_ADDR, len(padded)), wait=20.0)
    print(out)
    if "%08x" % padded_crc not in out:
        print("ERROR: padded FIT RAM CRC mismatch"); s.close(); return 1

    print("\n--- writing FIT to boot0 block 0x%x ---" % FIT_BLOCK_OFF)
    print(run("mmc write 0x%x 0x%x 0x%x" % (LOAD_ADDR, FIT_BLOCK_OFF, FIT_BLOCKS),
              wait=60.0))

    print("\n=== VERIFY: read boot0 back and compare ===")
    print(run("mmc read 0x%x 0x0 0x%x" % (LOAD_ADDR, LOADER_BLOCKS), wait=30.0))
    out = run("crc32 0x%x 0x%x" % (LOAD_ADDR, len(ld)), wait=20.0)
    print("loader readback " + out)
    ok1 = ("%08x" % ld_crc) in out

    print(run("mmc read 0x%x 0x%x 0x%x" % (LOAD_ADDR, FIT_BLOCK_OFF, FIT_BLOCKS),
              wait=30.0))
    out = run("crc32 0x%x 0x%x" % (LOAD_ADDR, len(padded)), wait=20.0)
    print("FIT readback " + out)
    ok2 = ("%08x" % padded_crc) in out

    print(run("mmc dev 0 0"))
    print("\nloader @ boot0 0x0      : %s" % ("VERIFIED" if ok1 else "MISMATCH"))
    print("FIT    @ boot0 0x200000 : %s" % ("VERIFIED" if ok2 else "MISMATCH"))
    print("\nuser area (hwpart 0) was NOT written.")
    print("Cold power-cycle to test.")
    s.close()
    return 0 if (ok1 and ok2) else 1


if __name__ == "__main__":
    sys.exit(main())
