# Sercomm HG6244B U-Boot Tools & Deliverables

This directory contains standalone tools, build scripts, and guides for the Sercomm HG6244B (Broadcom BCM6856) bootloader project.

### Contents:
- [`PODMAN_BUILD_GUIDE.md`](PODMAN_BUILD_GUIDE.md): Complete guide on the Podman toolchain environment, build commands, flashing instructions, and NetConsole usage.
- [`build_all.sh`](build_all.sh): Turnkey script to build both SPI-NOR and eMMC bootloaders and assemble final deliverables.
- [`build_spinor.sh`](build_spinor.sh): Dedicated build script for SPI-NOR bootloader.
- [`build_emmc.sh`](build_emmc.sh): Dedicated build script for eMMC bootloader.
- [`assemble_and_verify.py`](assemble_and_verify.py): Checks SBI/COT/FIT headers, validates CRCs, and generates final flash images.
- [`patch_autoboot.py`](patch_autoboot.py): Binary patch utility for Broadcom `autoboot.o` to map Sercomm PB_RESET (GPIO 26) and disable ASUS Aura RGB overrides.
- `deliverables/`: Output directory where packaged bootloader binaries and checksums are placed.
