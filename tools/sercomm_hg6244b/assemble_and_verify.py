#!/usr/bin/env python3
"""
Assemble and verify the Sercomm HG6244B (Broadcom BCM6856) bootloader deliverables.

Handles both:
1. SPI-NOR Flash:
   - 2 MiB loader (SBI header, SPL, DDR3 training blobs, MCB table, TPL, NVRAM)
   - 16 MiB full chip image with 0xFF padding
2. eMMC Hardware Boot Partition:
   - 4 MiB mmcblk0boot0 image (2 MiB Stage 1 Loader + 2 MiB Stage 2 U-Boot FIT)

Usage:
  python3 assemble_and_verify.py [--target all|spinor|emmc]
"""
import argparse
import hashlib
import os
import re
import shutil
import struct
import sys
import zlib

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
BL_DIR = os.path.join(REPO_ROOT, "release", "src-rt-5.04behnd.4916", "bootloaders")
BIN_DIR = os.path.join(BL_DIR, "obj", "binaries")
OUT_DIR = os.path.join(SCRIPT_DIR, "deliverables")

FLASH_SIZE_SPINOR = 16 * 1024 * 1024  # 16 MiB
LOADER_SIZE_SPINOR = 2 * 1024 * 1024  # 2 MiB
BOOT0_SIZE_EMMC = 4 * 1024 * 1024     # 4 MiB
FIT_OFFSET_EMMC = 2 * 1024 * 1024     # 2 MiB (LBA 0x1000)

SBI_MAGIC_1 = 183954
SBI_MAGIC_2 = 145257
FDT_MAGIC = 0xD00DFEED


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def md5(path):
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def crc32_broadcom(data):
    """Broadcom SBI CRC32 variant (xorout=0)."""
    return (zlib.crc32(data) ^ 0xFFFFFFFF) & 0xFFFFFFFF


def parse_map(path):
    entries = []
    pat = re.compile(r"^0x([0-9a-fA-F]+)\s+(\S+)\s+\((\d+) bytes\)")
    with open(path) as f:
        for line in f:
            m = pat.match(line.strip())
            if m:
                entries.append((int(m.group(1), 16), m.group(2), int(m.group(3))))
    return entries


def find_input(name, entries):
    if name.startswith("spinor_") or name.startswith("emmc_"):
        return os.path.join(BIN_DIR, name)
    for cand in (name, "spinor_" + name, "emmc_" + name):
        p = os.path.join(BIN_DIR, cand)
        if os.path.exists(p):
            return p
    raise FileNotFoundError(name)


def process_spinor():
    loader_path = os.path.join(BIN_DIR, "loader_test_spinor_6856.bin")
    map_path = loader_path + ".map"
    bootstrap_path = os.path.join(BIN_DIR, "bootstrap_image_spinor.bin")

    if not os.path.exists(loader_path) or not os.path.exists(bootstrap_path):
        print(f"[-] SPI-NOR artifacts missing in {BIN_DIR}")
        return False

    print("\n" + "=" * 60)
    print("VERIFYING & ASSEMBLING SPI-NOR DELIVERABLES")
    print("=" * 60)

    loader = open(loader_path, "rb").read()
    assert len(loader) == LOADER_SIZE_SPINOR, f"Invalid loader size: {len(loader)}"

    f0, f1 = struct.unpack_from("<II", loader, 0)
    assert f0 == SBI_MAGIC_1 and f1 == SBI_MAGIC_2, f"Invalid SBI magic: {f0:#x}/{f1:#x}"
    ver, eligible, hdr_len, img_len, crc = struct.unpack_from("<IIIII", loader, 8)
    assert crc == crc32_broadcom(loader[:hdr_len - 4]), "SBI header CRC mismatch"

    boot = open(bootstrap_path, "rb").read()
    fit_magic = struct.unpack_from(">I", boot, LOADER_SIZE_SPINOR)[0]
    assert fit_magic == FDT_MAGIC, f"Invalid FIT magic at 2MB offset: {fit_magic:#x}"

    # Stage deliverables
    out_loader = os.path.join(OUT_DIR, "loader_spinor.bin")
    shutil.copyfile(loader_path, out_loader)

    out_bootstrap = os.path.join(OUT_DIR, "bootstrap_image_spinor.bin")
    shutil.copyfile(bootstrap_path, out_bootstrap)

    out_full = os.path.join(OUT_DIR, "spinor_16MB_full.bin")
    with open(out_full, "wb") as f:
        f.write(boot)
        f.write(b"\xff" * (FLASH_SIZE_SPINOR - len(boot)))

    assert os.path.getsize(out_full) == FLASH_SIZE_SPINOR, "16MB image size mismatch"

    print(f"[+] loader_spinor.bin:        {os.path.getsize(out_loader)} bytes (SHA256: {sha256(out_loader)})")
    print(f"[+] bootstrap_image_spinor.bin: {os.path.getsize(out_bootstrap)} bytes (SHA256: {sha256(out_bootstrap)})")
    print(f"[+] spinor_16MB_full.bin:     {os.path.getsize(out_full)} bytes (SHA256: {sha256(out_full)})")
    return True


def process_emmc():
    boot_part_path = os.path.join(BIN_DIR, "bootstrap_image_emmc_boot_part.bin")
    fit_path = os.path.join(BIN_DIR, "brcm_simple.itb")

    if not os.path.exists(boot_part_path) or not os.path.exists(fit_path):
        print(f"[-] eMMC artifacts missing in {BIN_DIR}")
        return False

    print("\n" + "=" * 60)
    print("VERIFYING & ASSEMBLING eMMC (mmcblk0boot0) DELIVERABLES")
    print("=" * 60)

    loader = open(boot_part_path, "rb").read()
    assert len(loader) == 2 * 1024 * 1024, f"Invalid eMMC loader size: {len(loader)}"

    f0, f1 = struct.unpack_from("<II", loader, 0)
    assert f0 == SBI_MAGIC_1 and f1 == SBI_MAGIC_2, f"Invalid SBI magic: {f0:#x}/{f1:#x}"

    fit_data = open(fit_path, "rb").read()
    fit_magic = struct.unpack_from(">I", fit_data, 0)[0]
    assert fit_magic == FDT_MAGIC, f"Invalid FIT magic: {fit_magic:#x}"

    # Assemble 4 MiB unified mmcblk0boot0 image
    out_boot0 = os.path.join(OUT_DIR, "emmc_boot0_custom.bin")
    with open(out_boot0, "wb") as f:
        f.write(loader)  # 0 - 2 MiB (Sectors 0 - 4095)
        f.write(fit_data)  # 2 MiB+ (Sector 4096 / LBA 0x1000)
        curr = f.tell()
        if curr < BOOT0_SIZE_EMMC:
            f.write(b"\x00" * (BOOT0_SIZE_EMMC - curr))

    assert os.path.getsize(out_boot0) == BOOT0_SIZE_EMMC, "eMMC boot0 size mismatch"

    shutil.copyfile(boot_part_path, os.path.join(OUT_DIR, "bootstrap_image_emmc_boot_part.bin"))
    shutil.copyfile(fit_path, os.path.join(OUT_DIR, "brcm_simple.itb"))

    print(f"[+] emmc_boot0_custom.bin:   {os.path.getsize(out_boot0)} bytes (SHA256: {sha256(out_boot0)})")
    print(f"[+] brcm_simple.itb:         {os.path.getsize(fit_path)} bytes (SHA256: {sha256(fit_path)})")
    return True


def main():
    parser = argparse.ArgumentParser(description="Assemble Sercomm HG6244B U-Boot images")
    parser.add_argument("--target", choices=["all", "spinor", "emmc"], default="all")
    args = parser.parse_args()

    os.makedirs(OUT_DIR, exist_ok=True)
    success = True

    if args.target in ("all", "spinor"):
        if not process_spinor():
            success = False

    if args.target in ("all", "emmc"):
        if not process_emmc():
            success = False

    if success:
        # Write checksum file
        sums = []
        for fn in sorted(os.listdir(OUT_DIR)):
            if fn.endswith((".bin", ".itb")):
                fp = os.path.join(OUT_DIR, fn)
                sums.append(f"{sha256(fp)}  {fn}\n")
        with open(os.path.join(OUT_DIR, "checksums.sha256"), "w") as f:
            f.writelines(sums)
        print("\n[+] Verification and packaging COMPLETE. Deliverables ready in:")
        print(f"    {OUT_DIR}")
    else:
        print("\n[-] Build artifacts were missing. Run the build script first.")

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
