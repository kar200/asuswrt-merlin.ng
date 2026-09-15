#!/usr/bin/env python3
"""
Patch Broadcom prebuilt autoboot.o for Sercomm HG6244B hardware.

What this patch does:
1. Neutralizes ASUS Aura RGB routines (turn_cled_all, turn_cled_boot, turn_cled_rescue)
   by inserting AArch64 'RET' (0xd65f03c0) instructions at their entry points.
2. Changes the rescue recovery button check from Broadcom reference GPIO 23 (0x17)
   to Sercomm HG6244B physical Reset button PB_RESET (GPIO 26 / 0x1a).
3. Changes the WPS button check from Broadcom reference GPIO 33 (0x21)
   to Sercomm HG6244B physical WPS button PB_WPS (GPIO 28 / 0x1c).
"""
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
AUTOBOOT_O = os.path.join(
    REPO_ROOT,
    "release", "src-rt-5.04behnd.4916", "bootloaders", "u-boot-2019.07",
    "common", "autoboot.o"
)

PATCH_TABLE = [
    # (offset, expected_orig_bytes, new_bytes, description)
    (0x1fc, bytes.fromhex("fd7bbfa9"), bytes.fromhex("c0035fd6"), "turn_cled_all -> ret"),
    (0x6b0, bytes.fromhex("fd7bbea9"), bytes.fromhex("c0035fd6"), "turn_cled_boot -> ret"),
    (0x708, bytes.fromhex("e2"),       bytes.fromhex("c0"),       "turn_cled_rescue -> ret (part 1)"),
    (0x70a, bytes.fromhex("002a"),     bytes.fromhex("5fd6"),     "turn_cled_rescue -> ret (part 2)"),
    (0x738, bytes.fromhex("00000090"), bytes.fromhex("c0035fd6"), "init_all_gpio cled loop -> ret"),
    (0xa10, bytes.fromhex("2004"),     bytes.fromhex("8003"),     "rescue GPIO 23 -> 26 (PB_RESET)"),
    (0xaf0, bytes.fromhex("e002"),     bytes.fromhex("4003"),     "rescue check GPIO 23 -> 26"),
    (0xddc, bytes.fromhex("2004"),     bytes.fromhex("8003"),     "WPS GPIO 33 -> 28 (PB_WPS)"),
    (0xde8, bytes.fromhex("e002"),     bytes.fromhex("4003"),     "WPS check GPIO 33 -> 28"),
]


def patch_file(path):
    if not os.path.exists(path):
        print(f"[-] Target file not found: {path}")
        return False

    with open(path, "rb") as f:
        data = bytearray(f.read())

    applied = 0
    already_patched = 0

    for off, orig, new, desc in PATCH_TABLE:
        cur = data[off:off + len(orig)]
        if cur == orig:
            data[off:off + len(orig)] = new
            applied += 1
            print(f"[+] Applied: {desc} at 0x{off:x}")
        elif cur == new:
            already_patched += 1
            print(f"[=] Already patched: {desc} at 0x{off:x}")
        else:
            print(f"[-] Mismatch at 0x{off:x}: expected {orig.hex()}, found {cur.hex()} ({desc})")
            return False

    if applied > 0:
        with open(path, "wb") as f:
            f.write(data)
        print(f"[+] Successfully wrote {applied} patches to {path}")
    else:
        print(f"[=] File already fully patched ({already_patched} matches).")

    return True


if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else AUTOBOOT_O
    if not patch_file(target):
        sys.exit(1)
