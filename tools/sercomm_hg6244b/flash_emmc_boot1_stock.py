#!/usr/bin/env python3
"""
flash_emmc_boot1_stock.py - write the STOCK CFE into the eMMC SECOND boot
partition (hwpart 2 / CFE's emmcflash2.cfe), leaving the first boot partition
(hwpart 1 / boot0) completely untouched.

boot0 holds our U-Boot.  This script never writes hwpart 1 and never writes
hwpart 0 (user area / GPT).

Isolation proof: it records boot0's CRC32 *before* the write and re-reads it
*after*, and fails loudly if it changed.

Layout:
    hwpart 2, block 0x0, 0x2000 blocks (4 MiB)  <- stock boot0 dump
    the CFE payload itself lives at offset 0x10000 inside that image
"""

import os
import socket
import time
import zlib

UART_HOST = "172.16.1.110"
UART_PORT = 8888
TFTP_PORT = 6969

HERE = os.path.dirname(os.path.abspath(__file__))
IMAGE_LOCAL = os.environ.get(
    "EMMC_STOCK_IMAGE", os.path.join(HERE, "deliverables", "emmc_boot0_stock.bin"))
IMAGE_TFTP = "emmc_boot0_stock.bin"

LOAD_ADDR = 0x04000000
SECOND_BOOT_HWPART = 2          # 1 = boot0 (our U-Boot, DO NOT TOUCH), 2 = boot1
TOTAL_BLOCKS = 0x2000           # 4 MiB

def main():
    img = open(IMAGE_LOCAL, "rb").read()
    want = zlib.crc32(img) & 0xFFFFFFFF
    print("stock CFE image : %s" % IMAGE_LOCAL)
    print("                : %d bytes, crc32 %08x" % (len(img), want))
    print("target          : mmc hwpart %d (second boot partition), blocks 0x0..0x%x"
          % (SECOND_BOOT_HWPART, TOTAL_BLOCKS - 1))
    print("NOT TOUCHED     : hwpart 1 (boot0 = U-Boot), hwpart 0 (user area)\n")

    s = socket.create_connection((UART_HOST, UART_PORT), timeout=8)
    s.settimeout(0.4)

    def drain(sec, stop=True):
        end = time.time() + sec
        buf = b""
        while time.time() < end:
            try:
                d = s.recv(8192)
                if d:
                    buf += d
                    if stop and b"=>" in buf[-200:]:
                        break
            except socket.timeout:
                pass
        return buf.decode("latin1", "replace")

    def clean(t):
        return "\n".join(l.strip() for l in t.splitlines()
                         if l.strip() and "bbh full" not in l
                         and "Failed to send" not in l)

    def resync():
        for _ in range(6):
            s.sendall(b"\r")
            if "=>" in drain(1.0):
                return True
        s.sendall(b"\x03")
        return "=>" in drain(1.5)

    def run(cmd, wait=8.0, tries=3):
        out = ""
        for a in range(tries):
            drain(0.4)
            s.sendall(cmd.encode() + b"\r\n")
            out = clean(drain(wait))
            if cmd.split()[0] in out:
                return out
            print("   [retry %d: %s]" % (a + 1, cmd))
            resync()
        return out

    resync()

    def crc_of(hwpart, label):
        run("mmc dev 0 %d" % hwpart, 6.0)
        run("mmc read 0x%x 0x0 0x%x" % (LOAD_ADDR, TOTAL_BLOCKS), 20.0)
        out = run("crc32 0x%x 0x%x" % (LOAD_ADDR, len(img)), 15.0)
        # U-Boot prints:  crc32 for 04000000 ... 043fffff ==> 2d64be07
        if "==>" in out:
            tail = out.split("==>")[-1].strip()
            if tail:
                tok = tail.split()[0]
                if len(tok) == 8 and all(c in "0123456789abcdef" for c in tok):
                    return tok
        return None

    print("--- baseline: read both boot partitions (read-only) ---")
    boot0_before = crc_of(1, "boot0")
    boot1_before = crc_of(SECOND_BOOT_HWPART, "boot1")
    print("  boot0 (hwpart 1) crc32 = %s   <- our U-Boot" % boot0_before)
    print("  boot1 (hwpart 2) crc32 = %s   <- target (blank = %08x)"
          % (boot1_before, zlib.crc32(b"\xff" * len(img)) & 0xFFFFFFFF))

    print("\n--- tftpboot the stock CFE image ---")
    run("setenv tftpdstp %d" % TFTP_PORT, 4.0)
    out = run("tftpboot 0x%x %s" % (LOAD_ADDR, IMAGE_TFTP), 45.0)
    print(out)
    if "Bytes transferred" not in out:
        print("ERROR: transfer failed"); return 1
    out = run("crc32 0x%x 0x%x" % (LOAD_ADDR, len(img)), 15.0)
    print(out)
    if "%08x" % want not in out:
        print("ERROR: RAM crc mismatch - aborting before any write"); return 1

    print("\n--- writing to hwpart %d ONLY ---" % SECOND_BOOT_HWPART)
    print(run("mmc dev 0 %d" % SECOND_BOOT_HWPART, 6.0))
    print(run("mmc write 0x%x 0x0 0x%x" % (LOAD_ADDR, TOTAL_BLOCKS), 60.0))

    print("\n--- verify boot1 == stock image ---")
    boot1_after = crc_of(SECOND_BOOT_HWPART, "boot1")
    ok1 = boot1_after == ("%08x" % want)

    print("\n--- re-read boot0: must be UNCHANGED ---")
    boot0_after = crc_of(1, "boot0")
    ok0 = boot0_after == boot0_before

    run("mmc dev 0 0", 5.0)

    print("\n" + "=" * 62)
    print("  boot0 (hwpart 1, our U-Boot)")
    print("      before %s" % boot0_before)
    print("      after  %s   -> %s" % (boot0_after,
          "UNCHANGED" if ok0 else "*** CHANGED - SOMETHING WENT WRONG ***"))
    print("  boot1 (hwpart 2, stock CFE)")
    print("      after  %s  (expected %08x) -> %s"
          % (boot1_after, want, "VERIFIED" if ok1 else "*** MISMATCH ***"))
    print("=" * 62)
    s.close()
    return 0 if (ok1 and ok0) else 1

if __name__ == "__main__":
    raise SystemExit(main())
