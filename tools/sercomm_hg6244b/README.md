# Sercomm HG6244B U-Boot Tools & Deliverables

Standalone tools, build scripts and guides for the Sercomm HG6244B v2
(Broadcom BCM68360_B1 / BCM6856) U-Boot 2019.07 port, for both SPI NOR and eMMC.

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
| [`assemble_and_verify.py`](assemble_and_verify.py) | Validates SBI/COT/FIT headers and CRCs, assembles the final flash images. |
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

`deliverables/` holds the final verified images exactly as flashed, with
`checksums.sha256` covering all of them.

* **SPI NOR (16 MiB):** `spinor_16MB_full.bin`, `bootstrap_image_spinor.bin`, `loader_spinor.bin`
* **SPI NOR (4 MiB W25Q32JV):** `spinor_4MB_W25Q32JV.bin`
* **eMMC boot0 (U-Boot):** `bootstrap_image_emmc_boot_part.bin` (2 MiB loader), `brcm_simple.itb` (FIT), `emmc_boot0_custom.bin` (assembled 4 MiB partition image)
* **eMMC boot1 (stock CFE):** `emmc_boot0_stock.bin`

All flash tools resolve their inputs relative to this directory (override with the
`EMMC_FIT_DIR`, `EMMC_LOADER_FILE`, `EMMC_FIT_FILE` and `EMMC_STOCK_IMAGE`
environment variables).
