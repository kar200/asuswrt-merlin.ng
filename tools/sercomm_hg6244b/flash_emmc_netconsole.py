#!/usr/bin/env python3
"""
flash_emmc_netconsole.py - write U-Boot into a router's eMMC boot0 over
NETCONSOLE only (no UART available).

Same layout and safety rules as flash_emmc_uboot.py:

    boot0 (mmc hwpart 1) block 0x0000  <-  2 MiB loader region
    boot0 (mmc hwpart 1) block 0x1000  <-  bootstrap FIT (U-Boot proper)

Differences: the console is U-Boot netconsole on UDP 6666 instead of the
TCP-serial bridge.  UDP is packet based, so there are no stray-byte
corruptions; instead every command is retried until its echo is seen.

SAFETY
  * writes ONLY mmc hwpart 1 (boot0); hwpart 0 (user area / GPT) is read but
    never written
  * every write verified by mmc read + crc32 against the local file
  * tftpdstp is set for the transfer only and never saved
  * no `reset`
"""

import os
import socket
import sys
import time
import zlib

ROUTER = "192.168.1.1"
NC_PORT = 6666
TFTP_PORT = 6969

LOAD_ADDR = 0x04000000
BOOT0_HWPART = 1
LOADER_BLOCKS = 0x1000
FIT_BLOCK_OFF = 0x1000
FIT_BLOCKS = 0x6DC

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
    padded_crc = zlib.crc32(padded) & 0xFFFFFFFF
    assert blocks == FIT_BLOCKS, "FIT block count changed: %d" % blocks
    print("loader : %d B crc32 %08x -> boot0 0x0    (%d blocks)" % (len(ld), ld_crc, LOADER_BLOCKS))
    print("FIT    : %d B crc32 %08x -> boot0 0x%x (%d blocks, pad %d)"
          % (len(fit), zlib.crc32(fit) & 0xFFFFFFFF, FIT_BLOCK_OFF, blocks, pad))

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    for o in (socket.SO_REUSEADDR, socket.SO_REUSEPORT, socket.SO_BROADCAST):
        try:
            s.setsockopt(socket.SOL_SOCKET, o, 1)
        except Exception:
            pass
    s.bind(("0.0.0.0", NC_PORT))
    s.settimeout(0.4)

    def collect(sec):
        end = time.time() + sec
        buf = b""
        while time.time() < end:
            try:
                d, _ = s.recvfrom(16384)
                if d:
                    buf += d
            except socket.timeout:
                pass
        return buf.decode("latin1", "replace")

    def clean(t):
        return "\n".join(l.strip() for l in t.splitlines()
                         if l.strip() and "bbh full" not in l
                         and "Failed to send" not in l)

    def run(cmd, wait=8.0, tries=3):
        out = ""
        for a in range(tries):
            collect(0.3)
            s.sendto((cmd + "\r\n").encode(), (ROUTER, NC_PORT))
            out = clean(collect(wait))
            if cmd.split()[0] in out:
                return out
            print("   [retry %d for %r]" % (a + 1, cmd))
        return out

    print("\n--- sync ---")
    print(run("version", 6.0))

    print("\n--- point U-Boot at the TFTP server port (not saved) ---")
    run("setenv tftpdstp %d" % TFTP_PORT, 4.0)

    print("\n--- tftpboot loader ---")
    out = run("tftpboot 0x%x %s" % (LOAD_ADDR, LOADER_FILE), 40.0)
    print(out)
    if "Bytes transferred" not in out:
        print("ERROR: loader transfer failed"); return 1
    out = run("crc32 0x%x 0x%x" % (LOAD_ADDR, len(ld)), 12.0)
    print(out)
    if "%08x" % ld_crc not in out:
        print("ERROR: loader RAM crc mismatch"); return 1

    print("\n--- write loader to boot0 block 0x0 ---")
    print(run("mmc dev 0 %d" % BOOT0_HWPART, 6.0))
    print(run("mmc write 0x%x 0x0 0x%x" % (LOAD_ADDR, LOADER_BLOCKS), 40.0))

    print("\n--- tftpboot FIT ---")
    out = run("tftpboot 0x%x %s" % (LOAD_ADDR, FIT_FILE), 40.0)
    print(out)
    if "Bytes transferred" not in out:
        print("ERROR: FIT transfer failed"); return 1
    run("mw.b 0x%x 0xff 0x%x" % (LOAD_ADDR + len(fit), pad), 5.0)
    out = run("crc32 0x%x 0x%x" % (LOAD_ADDR, len(padded)), 12.0)
    print(out)
    if "%08x" % padded_crc not in out:
        print("ERROR: padded FIT RAM crc mismatch"); return 1

    print("\n--- write FIT to boot0 block 0x%x ---" % FIT_BLOCK_OFF)
    print(run("mmc write 0x%x 0x%x 0x%x" % (LOAD_ADDR, FIT_BLOCK_OFF, FIT_BLOCKS), 40.0))

    print("\n=== VERIFY ===")
    run("mmc read 0x%x 0x0 0x%x" % (LOAD_ADDR, LOADER_BLOCKS), 20.0)
    o1 = run("crc32 0x%x 0x%x" % (LOAD_ADDR, len(ld)), 12.0)
    print("loader readback:", o1)
    run("mmc read 0x%x 0x%x 0x%x" % (LOAD_ADDR, FIT_BLOCK_OFF, FIT_BLOCKS), 20.0)
    o2 = run("crc32 0x%x 0x%x" % (LOAD_ADDR, len(padded)), 12.0)
    print("FIT readback   :", o2)
    run("mmc dev 0 0", 5.0)
    ok1 = ("%08x" % ld_crc) in o1
    ok2 = ("%08x" % padded_crc) in o2
    print("\nloader @ boot0 0x0      : %s" % ("VERIFIED" if ok1 else "MISMATCH"))
    print("FIT    @ boot0 0x200000 : %s" % ("VERIFIED" if ok2 else "MISMATCH"))
    print("\nuser area (hwpart 0) was NOT written.  Cold power-cycle to test.")
    s.close()
    return 0 if (ok1 and ok2) else 1


if __name__ == "__main__":
    sys.exit(main())
