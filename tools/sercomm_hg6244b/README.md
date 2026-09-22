# Sercomm HG6244B U-Boot Tools & Deliverables

Standalone tools, build scripts and guides for the Sercomm HG6244B v2
(Broadcom BCM68360_B1 / BCM6856) U-Boot 2019.07 port, for both SPI NOR and eMMC.

### Current eMMC release — September 22, 2026

`sercomm-ramopts-20260922` adds TFTP upload, bootmenu, PXE, meminfo, log,
time, gettime, and fsuuid to the working SMP-capable eMMC build.

- Verified first in RAM, then flashed **only** to boot0 LBA `0x1000` and cold-booted.
- U-Boot reports 1 GiB and preserves EMMC environment discovery; custom p15 Linux
  boots with both CPUs online. Linux LAN forwarding is still unresolved.
- Use `emmc_brcm_simple_ramopts_20260922_padded.itb`: `0x709` blocks,
  CRC32 `83fc2934`. Full read-back matched; loader, saved environment, and the
  remaining boot0 bytes were unchanged. Kernel/rootfs were not flashed.
- The existing `brcm_simple.itb` is retained as the **v4 rollback**, not overwritten.
  The old whole-boot0 images and full-loader flash scripts are **not** the update
  path for this release. Follow the FIT-only procedure in the build guide.
- DHCP is already available: `setenv autoload no; dhcp` obtains a lease without
  downloading an image. `sdk httpd_start` is firmware recovery: uploading can
  flash storage and reboot. HTTP reachability and full PXE netboot are untested.
- This build uses TFTP port **69**; it does not enable `CONFIG_TFTP_PORT`, so the
  bundled port-6969 server is not compatible with it.

See the [build guide](PODMAN_BUILD_GUIDE.md#52-current-emmc-fit-only-release)
for artifact hashes, test scope, build/packaging provenance, and safe flashing.

### Documentation

| File | What |
|---|---|
| [`PODMAN_BUILD_GUIDE.md`](PODMAN_BUILD_GUIDE.md) | **Start here.** Toolchain, build targets, the config changes that make the port work, build gotchas, deliverables with CRCs, all flashing procedures, console access, safety rules and hardware reference. |
| [`GPIO_MAP.md`](GPIO_MAP.md) | Authoritative GPIO map dumped from the stock CFE: LEDs, buttons, correction history. |

### Build

| File | What |
|---|---|
| [`build_all.sh`](build_all.sh) | Turnkey: builds both targets and packages the deliverables. |
| [`build_spinor.sh`](build_spinor.sh) / [`build_emmc.sh`](build_emmc.sh) | Individual SPI-NOR / eMMC builds. |
| [`assemble_and_verify.py`](assemble_and_verify.py) | Legacy full-image assembler; overwrites generic deliverable names. Do not run it to publish the dated FIT-only release. |
| [`package_emmc_ramopts.py`](package_emmc_ramopts.py) | Packages only the exact RAM-tested payload into a separate output directory, verifies vendor signatures and payload identity, and never flashes. |
| [`patch_autoboot.py`](patch_autoboot.py) | Binary patch utility for the Broadcom `autoboot.o` blob (button mapping / ASUS Aura RGB overrides). |

### Flash

| File | What |
|---|---|
| [`tftp_server.py`](tftp_server.py) | Minimal TFTP server on port 6969 (U-Boot `tftpdstp`), serving `deliverables/` by default. |
| [`flash_spinor_tftp.py`](flash_spinor_tftp.py) | SPI-NOR flash over TFTP + `sf update`, with compare-mode readback verification. **Never issues an `mmc` command.** |
| [`flash_spinor_ymodem.py`](flash_spinor_ymodem.py) | SPI-NOR flash over serial YMODEM (fallback, no network required). |
| [`flash_emmc_uboot.py`](flash_emmc_uboot.py) | Writes U-Boot into eMMC **boot0 (hwpart 1)** only, over the UART bridge. |
| [`flash_emmc_netconsole.py`](flash_emmc_netconsole.py) | Same, over NetConsole UDP 6666 (for units with no UART). |
| [`flash_emmc_boot1_stock.py`](flash_emmc_boot1_stock.py) | Writes the **factory stock CFE** into eMMC **boot1 (hwpart 2)**, with a before/after boot0 CRC check to prove boot0 was untouched. |
| [`netconsole.py`](netconsole.py) | Standalone pure-Python interactive NetConsole client (bidirectional, raw TTY). |

### Deliverables

`deliverables/` holds the dated release and retained historical images, with
`checksums.sha256` covering the artifacts. The release configuration snapshot is
`ramopts_20260922.config`; see the guide for the validation scope of each artifact.

* **Current eMMC FIT-only update:** `emmc_brcm_simple_ramopts_20260922.itb` and
  `emmc_brcm_simple_ramopts_20260922_padded.itb`.
* **RAM-test input (not directly flashable):** `uboot_emmc_ramopts.bin`.

* **SPI NOR (16 MiB):** `spinor_16MB_full.bin`, `bootstrap_image_spinor.bin`, `loader_spinor.bin`
* **SPI NOR (4 MiB W25Q32JV):** `spinor_4MB_W25Q32JV.bin`
* **Historical eMMC artifacts:** `bootstrap_image_emmc_boot_part.bin` (2 MiB loader), `brcm_simple.itb` (v4 rollback FIT), `emmc_boot0_custom.bin` (legacy assembled 4 MiB partition image). These are unchanged.
* **eMMC boot1 (stock CFE):** `emmc_boot0_stock.bin`

All flash tools resolve their inputs relative to this directory (override with the
`EMMC_FIT_DIR`, `EMMC_LOADER_FILE`, `EMMC_FIT_FILE` and `EMMC_STOCK_IMAGE`
environment variables).
