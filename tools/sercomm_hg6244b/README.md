# Sercomm HG6244B U-Boot Tools & Deliverables

Standalone tools, build scripts and guides for the Sercomm HG6244B v2
(Broadcom BCM68360_B1 / BCM6856) U-Boot 2019.07 port, for both SPI NOR and eMMC.

### Current eMMC release — September 30, 2026 (`rescuecli2`)

`50404p3@533676`, banner `U-Boot 2019.07 (Sep 30 2026 - 06:23:18)`. Cold-boot
and netconsole-verified on hardware; supersedes the 20260922 FIT-only release
(kept below as rollback).

New in this release:

- **Early status LED** — the front-panel status RGB turns **amber ~1 s after
  power-on**, before DDR training (`spl_status_led_early()` raw-register hook
  in `board_spl.c`, called before `spl_board_ddrinit`). Confirmed on hardware.
- **Reset button = recovery CLI** — pressing/releasing RESET during the boot
  window runs `reset_cli`: drops to the U-Boot prompt with **NetConsole
  enabled** (UDP 6666, bidirectional — remote U-Boot flashing verified, no
  UART needed) and turns the status LED **blue** for the whole CLI session.
  Normal boot (`run bootcmd`) returns the LED to green. The old
  `btn_reset=env default -a;saveenv` behaviour (which wiped the saved
  environment) is gone.
- **Boot chain decoupled from slot 0** — `boot_cfe` now chainloads the
  stage-2 CFE from `p6`/`bootfs2` (LBA `0x3E000`) instead of `p2`, so
  flashing firmware slot 0 no longer touches the boot chain. The p2 path is
  kept as `boot_cfe_p2`.
- **`boot_factory`** (experimental, untested): chainloads the factory stage-1
  CFE (`cfe-v 5.0207p1`) preserved in eMMC **boot1** @ block `0x80` — boot1
  is never selected by the BootROM strap and serves as a factory reserve.

Deliverables: `emmc_brcm_rescuecli2_20260930_padded.itb` (`0x6E1` blocks,
FIT-only update path to boot0 LBA `0x1000`) and
`loader_recovery_20260930.bin` (full 2 MiB loader + env splice, see the
loader-set rule below). SHA-256 in `checksums.sha256`.

**Complete prebuilt boot0 image:** [`emmc_boot0_image_20260930/`](emmc_boot0_image_20260930/)
holds the finished 4 MiB eMMC boot0 image (loader + env + FIT, SHA-256-coupled
set, nothing to rebuild) with a step-by-step guide for flashing it **from a
running Linux on the router** — stock firmware (TR-069 unlock root) or the
custom rootfs — using `dd` on `/dev/mmcblk0boot0` with `force_ro` unlock and
mandatory read-back verification.

**Complete prebuilt SPI NOR image:** [`spinor_image_20260930/`](spinor_image_20260930/)
is the same `rescuecli2` feature set for the soldered 16 MiB NOR flash — early
amber LED, reset → blue NetConsole CLI, and a `bootcmd` that auto-chains CFE
from eMMC so the NOR is a fully independent boot path. `FLASHING_NOR.md`
covers the R18 boot strap and in-system flashing via the `snor_flash.ko`
`/dev/snor` module (plus CH341A and FIT-only update paths). The image was
verified as a consistent SPL/TPL SHA-256 set before publishing.

> **Loader-set rule (do not learn this the hard way):** the 2 MiB eMMC-boot0
> loader is a cryptographically-coupled set. The SPL carries a baked-in
> SHA-256 table (~offset 0x16000) covering env, MCBs, DDR3 and the TPL;
> flashing a new SPL without the matching TPL boot-loops with
> `digest sha256 mismatch` and leaves **no** prompt/netconsole (the reset
> rescue lives in U-Boot proper, which never runs). Update the loader only
> as the whole 2 MiB with the environment re-spliced into both slots
> (`0x40000` and `0xae000`) in a single `mmc write` of `0x1000` blocks.

### Previous eMMC release — September 22, 2026

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
| [`build_kernel_4.1.sh`](build_kernel_4.1.sh) | Compiles the Broadcom BCM6856 Linux 4.1.52 kernel inside Podman and stages deliverables. |
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
* **Linux 4.1.52 Kernel (BCM6856):** `deliverables/kernel/Image`, `System.map`, and `kernel.config`.

* **SPI NOR (16 MiB):** `spinor_16MB_full.bin`, `bootstrap_image_spinor.bin`, `loader_spinor.bin`
* **SPI NOR (4 MiB W25Q32JV):** `spinor_4MB_W25Q32JV.bin`
* **Historical eMMC artifacts:** `bootstrap_image_emmc_boot_part.bin` (2 MiB loader), `brcm_simple.itb` (v4 rollback FIT), `emmc_boot0_custom.bin` (legacy assembled 4 MiB partition image). These are unchanged.
* **eMMC boot1 (stock CFE):** `emmc_boot0_stock.bin`

All flash tools resolve their inputs relative to this directory (override with the
`EMMC_FIT_DIR`, `EMMC_LOADER_FILE`, `EMMC_FIT_FILE` and `EMMC_STOCK_IMAGE`
environment variables).
