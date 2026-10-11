# Sercomm HG6244B (BCM68360_B1 / BCM6856) — Bootloader Build & Flash Guide

Everything needed to rebuild, verify and flash the custom U-Boot 2019.07 that runs
alongside the stock firmware on the Sercomm HG6244B v2 — on **SPI NOR** and on
**eMMC** — from a clean checkout, without any of the original debugging context.

Board identity: `Chip ID: BCM68360_B1` (= BCM6856), CFE boardtype `968360BG`,
1 GiB DDR3, Samsung `8GTF4` eMMC (7.3 GiB), XM25QH13C-class 16 MiB SPI NOR.

---

## 0. TL;DR

**Current eMMC update:** use the dated FIT-only release in §5.2 and §6.3.
Do not rebuild or flash the loader to install it. The commands immediately below
are the **legacy full-image workflow**, not the September 22 update procedure.
The port-6969 example requires a different build with `CONFIG_TFTP_PORT=y`.

```bash
# 1. build both bootloaders (SPI-NOR + eMMC), from the repo root
tools/sercomm_hg6244b/build_all.sh

# 2. serve the deliverables and flash the SPI-NOR over the network
tools/sercomm_hg6244b/tftp_server.py            # port 6969
tools/sercomm_hg6244b/flash_spinor_tftp.py spinor_16MB_full.bin 0x2E0000

# 3. or flash the eMMC boot0 partition over the network
tools/sercomm_hg6244b/flash_emmc_uboot.py
```

Then cold power-cycle by hand. **Never issue the software `reset`.**

---

## 1. Repository layout

| Path | What |
|---|---|
| `release/src-rt-5.04behnd.4916/bootloaders/` | The Broadcom/ASUS bootloader build tree (U-Boot 2019.07 + TPL/SPL + FIT). This is the only part of the SDK the port touches. |
| `…/bootloaders/build/configs/` | Per-target `.arch` (Kconfig fragments) and `env_*.conf` (U-Boot environment) sources. |
| `…/bootloaders/u-boot-2019.07/` | U-Boot proper, TPL and SPL sources, plus the BCM6856 board support. |
| `…/bootloaders/obj/` | Build output. `obj/binaries/` holds the assembled stage-1 loader, the env blob and the FIT. Pre-existing objects are committed by the vendor; **never `make clean`** (it deletes `obj/binaries/`). |
| `tools/sercomm_hg6244b/` | This directory: build scripts, flash/test tools, guides, and the packaged `deliverables/`. |
| `tools/sercomm_hg6244b/GPIO_MAP.md` | Authoritative GPIO map (LEDs, buttons) dumped from the stock CFE. |
| `tools/sercomm_hg6244b/deliverables/` | Dated tested release, configuration snapshot, and retained historical images; see §5 for provenance and hashes. |

---

## 2. Toolchain

The build uses the ASUSWRT-Merlin toolchain container (Broadcom AArch64 GCC 10.3.0,
Buildroot 2021.02.4, host utilities):

```bash
podman pull docker.io/gnuton/asuswrt-merlin-toolchains-docker:latest
```

Both build scripts create/enter a container named `sercomm-toolchain` with the
repository mounted at `/build/asuswrt-merlin`, and execute as UID 0 inside it
(rootless Podman maps the host UID to container root, which keeps the bind mount
writable). The scripts also create the `/opt/toolchains` symlink and the
`crosstools-aarch64-…/usr` self-link that the Broadcom Makefiles expect.

---

## 3. Building

### 3.1 Turnkey

These scripts rebuild loaders and overwrite generic deliverable names. Keep the
archived v4 rollback and dated release safe before using them. For the isolated
proper-U-Boot build used by the current release, see §5.2 instead.

```bash
tools/sercomm_hg6244b/build_all.sh     # runs both targets, then assembles deliverables
tools/sercomm_hg6244b/build_spinor.sh  # SPI-NOR only
tools/sercomm_hg6244b/build_emmc.sh    # eMMC only
```

Each script then calls `assemble_and_verify.py`, which validates the SBI/COT headers
and CRCs and stages the results in `deliverables/`.

### 3.2 What the scripts actually run

Inside the container, from `release/src-rt-5.04behnd.4916/bootloaders`:

```bash
# stale-config wipe (see 3.3)
rm -f u-boot-2019.07/configs/tmp_*bcm96856_defconfig
rm -f obj/uboot/.config
rm -f obj/binaries/*env.bin_headered

MK='make OPTIONS=<options_6856_spinor|options_6856_emmc> BRCM_CHIP=6856'

$MK common          # TPL + DDR3 + MCB + hashtable, and the .arch -> defconfig conversion
$MK spl             # FSBL
$MK uboot           # U-Boot proper -> brcm_simple.itb
$MK loaderimage     # stage-1 loader (2 MiB) + env blob
$MK image_bootstrap_spinor   # (SPI)  loader + FIT
$MK image_bootstrap_emmc     # (eMMC) loader + FIT
```

### 3.3 Build gotchas (all three have bitten us)

1. **Stale generated defconfig.** The rule that turns
   `build/configs/options_6856_<target>.arch` into
   `u-boot-2019.07/configs/tmp_*_bcm96856_defconfig` does not depend on the `.arch`
   file, and `obj/uboot/.config` is *shared* between the SPI and eMMC builds.
   Changing a `.arch` therefore does nothing unless you delete both files first.
   Always keep the `rm -f` lines above.

2. **Stale environment blob.** Older revisions of this tree had an
   `env.bin_headered` rule with no prerequisites, so edits to
   `build/configs/env_*.conf` silently did not make it into the image. The rule now
   depends on the env file, and the build scripts additionally delete
   `obj/binaries/*env.bin_headered` so the blob is always regenerated.

3. **Never run `make clean`.** It removes `obj/binaries/`, which contains
   vendor-provided binaries that are not produced from source in this tree.

---

## 4. Configuration that makes the port work

### 4.1 `build/configs/emmc_6856.arch` — eMMC boot support

```perl
$c->set('CONFIG_TPL_MMC_SUPPORT','y');
$c->set('CONFIG_SPL_MMC_SUPPORT','y');
$c->unset('CONFIG_TPL_SPI_FLASH_SUPPORT');
```

Without this the eMMC image dies at

```
TPL: Unsupported Boot Device!
TPL: failed to boot from all boot devices
```

because the TPL was linked with only `tpl_spinor_load_image()` (`BOOT_DEVICE_NOR`).
`spinor.arch` *unsets* `CONFIG_TPL_MMC_SUPPORT` in the shared `obj/uboot/.config`,
which is exactly why the eMMC build has to re-set it **and** why the stale-config
wipe in 3.3 is mandatory.

### 4.2 Environment blobs (`build/configs/env_*.conf`)

`env_SPINOR_2M_6856ref.conf` and `env_EMMC_2M_6856ref.conf` are compiled into the
16 KiB env blob (`mkenvimage --bootmagic`) that is embedded in the stage-1 loader.
They are the *runtime* defaults; the compiled-in defaults live in
`u-boot-2019.07/include/configs/bcm96856.h`.

Both files are **serial-only** for the console:

```
stdin=serial
stdout=serial
stderr=serial
netconsole=echo Enabling NetConsole...;setenv stdout serial,nc;setenv stderr serial;setenv stdin serial,nc
```

> [!WARNING]
> Never put `nc` in `stdout`/`stdin` **by default**. NetConsole output goes through
> `eth_send`; if a packet fails, the error is printed, which recurses into another
> send, and the Broadcom BBH queue fills up:
> `non empty at bbh full(ingress=8,egress=0,diff=8)` /
> `bcmbca_eth_send:Failed to send packet len N: error = -1`.
> NetConsole must stay opt-in via `run netconsole`.

> [!CAUTION]
> The env **blob** and the **compiled-in** defaults are different things, and
> `env default -a` only restores the latter. `CONFIG_USE_DEFAULT_ENV_FILE` is not set
> and the env backend is `CONFIG_ENV_IS_IN_BOOT_MAGIC=y`, so the reset target is just
> `CONFIG_EXTRA_ENV_SETTINGS` from `include/configs/bcm96856.h` — a handful of
> variables that do **not** include `btn_reset`, `btn_wifi`, `boardid`, `MCB`,
> `serverip` or `boot_cfe`. The reset button runs exactly `env default -a; saveenv`,
> so pressing it replaces the working environment *and* the blob with that minimal
> set. If the button is meant to restore the shipped environment, its hooks have to
> be duplicated into `bcm96856.h`, or the button pointed at an explicit restore
> command instead.

Button hooks (identical in both files):

```
btn_reset=env default -a;saveenv     # factory-restore the U-Boot environment
btn_wifi=run netconsole              # enable NetConsole
```

Change either at runtime with `setenv btn_wifi "<cmd>"; saveenv` — no rebuild needed.

Env copy locations (`env_boot_magic`, `size@offset,offset`):

| Target | Value | Notes |
|---|---|---|
| SPI NOR | `16384@0x40000,0xad000` | not in the SPI env file — inherited from the compiled default in `include/configs/bcm96856.h` |
| eMMC | `16384@0x40000,0xae000` | set explicitly in `env_EMMC_2M_6856ref.conf`; the eMMC copies are 0x40000 and 0xae000 |

Other env differences worth knowing:

* eMMC adds `bootcmd=run init_leds; echo Type run boot_cfe to boot stock Linux; sleep 3`
  and `init_leds=gpio set 1; gpio set 22; gpio set 27; gpio clear 59` (status LED amber).
* Both carry `boot_cfe`, which chain-loads the stock CFE image out of `bootfs1`
  (see §7.4) — this is how you reach stock Linux from U-Boot.
* `IMAGE=SPINOR:2M,6M` vs `IMAGE=EMMC`, plus `MCB=1527`, `boardid=96856`,
  `netmask=255.255.255.0`. A missing `boardid`/`netmask`/`MCB` produces
  `boardid is not defined in uboot environment`, `HTTPD: netmask not defined`, or
  `no mcb specified explicitly, use safe mode`.

### 4.3 Device tree buttons — `arch/arm/dts/bcm96856.dts`

| Button | GPIO | Node | Action |
|---|---|---|---|
| RESET | 26 | `reset_button` | release → `run btn_reset`, and autoboot is aborted (`stop_boot_cmd`) |
| WIFI | 81 | `wifi_button` | press → `run btn_wifi` |
| WPS | 28 | *not wired* | deliberately unused |

Pin numbers come from the stock CFE's own map (`sc_gpio d`) — see `GPIO_MAP.md`,
including the correction history: an earlier revision wrongly used gpioc 82/83,
which are not the buttons.

### 4.4 `board/broadcom/bcmbca/bcmbca_button.c` — generic hook

`bcmbca_button_init()` walks the button subnodes and registers a
`PRESS_EVENT`/`RELEASE_EVENT` action named `hook` for every button except
`reset_button`; the action runs the node's `hook_cmd` property through
`run_command()`. This is what turns the DTS `hook_cmd = "run btn_wifi"` into
behaviour, and it means future buttons only need a DTS + env change.

Buttons are polled **once**, by `btn_poll_block()` in `common/main.c: main_loop()`,
immediately before `bootdelay_process()`, and the poll loops until every button is
released. Nothing polls at the `=>` prompt, so a button must be held at power-on and
then let go.

### 4.5 Recovered sources

`u-boot-2019.07/net/{arp,net,ping,tftp}.c` are committed here, but the vendor tree
shipped only the corresponding `.o` objects. They are required for any rebuild that
touches the network stack.

---

## 5. Deliverables

All files below are in `tools/sercomm_hg6244b/deliverables/`. Verify them from
that directory with `sha256sum -c checksums.sha256`.

Only the dated eMMC FIT was newly flashed and cold-booted for this release.
Existing generic artifacts are retained, not rebuilt or newly certified. In
particular, `brcm_simple.itb` is the September 17 SMP-capable v4 rollback from
commit `b805d76fbf`, not the September 15 single-CPU image described by older
versions of this guide. Shared `obj/binaries/` at the parent commit `abbb619468`
contains later SPI-NOR output and is **not** the source of this eMMC release.

### 5.1 SPI NOR (XM25QH128C-class, 16 MiB)

| File | Size | CRC32 | MD5 | Description |
|---|---|---|---|---|
| `spinor_16MB_full.bin` | 16777216 | `7d1e1c4c` | `f58201bce3e9e2a6ddc8492c0f2d652f` | Retained full 16 MiB chip image. |
| `bootstrap_image_spinor.bin` | 2998461 | `bc63450e` | `de3788586fa8a5235b745e8f5f556096` | Retained loader + FIT; not the old `0x2E0000`-byte padded file. |
| `spinor_4MB_W25Q32JV.bin` | 4194304 | `09af12fa` | `f54619894c76d1ccfb85c717e4c91d28` | Full image for the 4 MiB W25Q32JV replacement parts. |
| `loader_spinor.bin` | 2097152 | `5585dd9a` | `86b4e778fcfcfa385ee52e5a876a4808` | Retained stage-1 TPL/SPL loader alone. |

These are metadata checks of retained files, not new SPI-NOR hardware tests.
They do not all represent the same build; the eMMC release does not update them.
Use the manifest for exact identity, not the older guide's September 15 stamp.

The retained 4 MiB image is an older artifact: do not assume it matches the
current 16 MiB image's prefix. Also, 4 MiB parts leave no room for the
`bootfs`/`rootfs` `mtdparts` regions assumed by the 16 MiB environment.

Layout, identical on SPI NOR and inside the eMMC boot partition:

```
offset 0x000000  (2 MiB)   stage-1 loader (TPL + SPL + env blob)
offset 0x200000            U-Boot proper as a FIT (brcm_simple.itb)
```

### 5.2 Current eMMC FIT-only release

Banner: `U-Boot 2019.07 (Sep 22 2026 - 04:24:51 +0000)`,
`Build: sercomm-ramopts-20260922`.

| Artifact | Bytes | CRC32 | Use |
|---|---:|---|---|
| `emmc_brcm_simple_ramopts_20260922.itb` | 921853 | `be7a45cf` | Signed FIT before sector padding |
| `emmc_brcm_simple_ramopts_20260922_padded.itb` | 922112 | `83fc2934` | Flash **boot0 LBA 0x1000**, **0x709 blocks** |
| `uboot_emmc_ramopts.bin` | 916863 | `b009a790` | Raw U-Boot + control DTB; **not directly flashable** |

SHA256 of the padded FIT:
`a0413201603a6212d2f579eb4c1a5f3423e2820d00170d7e127c2b2fb7b56549`.
All artifact hashes, including `ramopts_20260922.config`, are in the manifest.

#### Configuration and isolated build

Source: `release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07`, base target
`bcm96856_defconfig`, `OPTIONS=options_6856_emmc`, `BRCM_CHIP=6856`.
The durable change is in `build/configs/emmc_6856.arch`, not generated `.config`:
`CONFIG_CMD_TFTPPUT`, `CONFIG_CMD_BOOTMENU`, `CONFIG_CMD_PXE`,
`CONFIG_CMD_MEMINFO`, `CONFIG_CMD_LOG`, `CONFIG_CMD_TIME`, `CONFIG_CMD_GETTIME`,
and `CONFIG_CMD_FS_UUID`. Kconfig also enables `CONFIG_MENU`, `CONFIG_BOOTP_PXE`,
and PXE client architecture `0x16`. DHCP and Broadcom HTTP recovery were already on.

The release was built in `sercomm-toolchain`, with this repository mounted at
`/build/asuswrt-merlin`. From its `release/src-rt-5.04behnd.4916/bootloaders`
directory, the isolated build recipe is:

```bash
MK='make OPTIONS=options_6856_emmc BRCM_CHIP=6856 bcm_uboot_uboot_prefix=ramopts_ BLD_COMMON=n UBOOT_BUILD_TAG=sercomm-ramopts-20260922 -o rt_ver'
$MK configure
make -C u-boot-2019.07 O=../obj/ramopts_uboot -j8 \
  CROSS_COMPILE=/opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/aarch64-linux- \
  BLD_COMMON=y tools
$MK -j8 uboot
```

Use a fresh isolated output/config for future builds; the stale-config warning
in §3.3 applies to the prefixed temporary defconfig too. No `make clean`,
`common`, `spl`, or `loaderimage` was run for this release. Required prebuilt
vendor artifacts were retained. The host-tools step supplies `fdtgrep`, `mkimage`,
and `scripts/dtc/dtc`. GCC was 10.3.0 / binutils 2.36.1 / Buildroot 2021.02.4.

`package_emmc_ramopts.py` preserves the tested payload identity and never flashes.
It requires the exact `obj/ramopts_uboot` output and a running, correctly mounted
container; it intentionally rejects a newly compiled binary with a different
hash. It is an archival packaging recipe, not automatic qualification of future
builds. On the host, with Python 3, Podman, and `fdtget` available:

```bash
python3 tools/sercomm_hg6244b/package_emmc_ramopts.py --output-dir /tmp/sercomm-fit-check
```

The output directory must not contain either output FIT. The script checks raw
payload and v4 identities, uses the SDK's existing GEN3 demo signing key, and
verifies both v4 and new RSA-PSS/SHA256 header signatures. No private key is
copied into this tools directory. Vendor packaging uses two external-data nodes,
a 4096-byte header reserve, `conf_uboot`, and load/entry `0x01000000`. The vendor
U-Boot node displays `Unknown Image` in `iminfo`, as v4 does; its hashes must pass.
FIT timestamps and randomized signatures can change when repackaging, even when
the payload is identical. Use the archived files for the exact tested release.

#### Verification and limitations

- RAM command tests: TFTP upload of 4097 synthetic bytes matched its host hash;
  interactive bootmenu selection executed the expected echo; PXE fetched a
  controlled config and dispatched a harmless local command; meminfo, logging,
  gettime, and `time sleep 1` passed. `fsuuid mmc 0:f` matched p15's ext4 UUID.
  Partition numbers in U-Boot are hexadecimal (`f` = decimal 15).
- RAM chain-loading must preserve the **live loader-patched control DTB**. The
  packaged DTB describes only 128 MiB; the loader supplies 1 GiB and
  `/chosen/boot_device = "EMMC"`. The raw executable is `0xddb30` bytes, so this
  build's appended-DTB address at load `0x01000000` is `0x010ddb30`. Recalculate
  that offset for any other binary. Never boot Linux with the unpatched 128 MiB map.
- Flash read-back compared all 922112 bytes; SHA256, CRC32, and both FIT payload
  hashes passed. All 2097152 prefix bytes and 1175040 tail bytes matched before
  and after. Loader, saved environment, kernel, and rootfs were not flashed.
- Cold activation on September 22 confirmed the new banner, 1 GiB DRAM,
  `/chosen/boot_device = "EMMC"`, and the existing saved boot macros.
- Custom p15 Linux: CPU online `0-1`, MemTotal `983888 kB`, writable ext4 root,
  and a responsive shell. No new cntfrq warning, oops, panic, or call trace was
  observed. `CloseKernelHWWD` remains in use without `StopKick`. These are smoke
  tests, not a long-term stability guarantee.
- Linux `br0` still has RX=0 and no IPv4 lease; only the `udhcpc` client was seen.
  LAN forwarding and full V1 startup-chain alignment remain unfinished.
- Full PXE kernel/netboot, HTTP reachability/uploads, and peripheral features
  such as USB Ethernet have not been qualified by these tests.

#### Retained rollback and legacy whole-partition images

`brcm_simple.itb` remains the v4 rollback:
SHA256 `1e5b3a0cc83bf9ceb5d451d8e64de398a76e186098af8fb9a56decf313a9a859`.
Its 0xFF-padded 512-byte representation occupies `0x6e1` blocks, CRC32 `990f203c`,
SHA256 `ca2264c5d89a464854308735d13ccf94eb88b96e7cf4136f5558015959b375a9`.
Rollback requires that separate padding/count, not the new release's `0x709`.

`bootstrap_image_emmc_boot_part.bin`, `emmc_boot0_custom.bin`, and
`emmc_boot0_stock.bin` are retained historical files. The whole-boot0 image is
**not** a backup of the currently flashed board: it can overwrite saved
configuration and the loader. Do not install it as this FIT-only update.

---

## 6. Flashing

### 6.1 TFTP server

The current eMMC build uses standard TFTP **UDP port 69**. `CONFIG_TFTP_PORT`
is not enabled, so `setenv tftpdstp 6969` does not redirect it to the bundled
port-6969 helper. Use an existing trusted TFTP service rooted at the directory
containing the release file. Bind it only to the intended LAN interface; do not
start a DHCP server on a connected home LAN.

For a DHCP lease without automatic image download:

```text
setenv autoload no
dhcp
```

Set a reachable `serverip` explicitly afterward; a DHCP server is not necessarily
your TFTP server. An IP-qualified filename avoids ambiguity. These are session
settings; no `saveenv` is required. TFTP has no authentication: verify the file's
local manifest and its downloaded hash before writing. TFTP upload is enabled;
the server may require a precreated writable destination file.

`sdk httpd_start` enables Broadcom's HTTP recovery endpoint (TCP 80). Uploading
firmware can flash storage and reboot, even when U-Boot runs from RAM or
`no_commit_image` is set. This is not a read-only HTTP test. It has not been
live-tested for this release; use only an isolated, trusted recovery network.

The following SPI-NOR procedure is historical and requires its stated features;
it was not revalidated as part of the eMMC update.

### 6.2 SPI NOR — network flash (recommended)

```bash
tools/sercomm_hg6244b/flash_spinor_tftp.py spinor_16MB_full.bin 0x2E0000
```

The tool sets `tftpdstp`, does `tftpboot` into RAM, verifies the RAM CRC32, runs
`sf update 0x04000000 0x0 ${filesize}`, and verifies with a **second compare-only
`sf update`** (which reports `0 bytes written, N bytes skipped` when flash matches
RAM).

> [!IMPORTANT]
> Do **not** use `sf read` to verify — it crashes this U-Boot build. Compare-mode
> `sf update` is the supported readback path.

Manual equivalent:

```text
setenv serverip 192.168.1.100; setenv ipaddr 192.168.1.1; setenv tftpdstp 6969
tftpboot 0x04000000 spinor_16MB_full.bin
sf probe 0:0
sf update 0x04000000 0x0 0x2E0000
sf update 0x04000000 0x0 0x2E0000      # 2nd pass must report 0 bytes written
```

`flash_spinor_ymodem.py` is the fallback path over the serial console (no network
needed, ~9.6 KB/s instead of ~5 MB/s).

This path issues **no `mmc` command at all** — the eMMC is not touched.

### 6.3 eMMC boot0 — current FIT-only update

Requires the already-working compatible eMMC loader, **1 GiB** DRAM, backups,
and a local UART recovery path. Do not run `flash_emmc_uboot.py` or
`flash_emmc_netconsole.py` for this release: they are legacy full-loader
flashers with older fixed counts and would not preserve the saved environment.

Run each phase separately and **stop on any error or mismatch**. Do not paste
all phases as an unattended script. Adapt the addresses below to your trusted
LAN; `172.16.1.110` / `172.16.1.114` were the client/server during validation.
Do not duplicate another device's address. Intercept autoboot; the saved
`bootcmd` on the development board includes a stock-CFE fallback.

```text
setenv bootcmd true
setenv bootdelay -1
setenv autostart no
setenv autoload no
setenv ipaddr 172.16.1.110
setenv serverip 172.16.1.114
setenv netmask 255.255.255.0
setenv netretry no
tftpboot 0x10000000 172.16.1.114:emmc_brcm_simple_ramopts_20260922_padded.itb
crc32 0x10000000 0xe1200
hash sha256 0x10000000 0xe1200
iminfo 0x10000000
```

Require `922112 (e1200 hex)` bytes, CRC `83fc2934`, the padded SHA256 from §5.2,
and both FIT hashes OK. Preserve both untouched ranges in RAM before the write:

```text
mmc dev 0 1
mmc read 0x22000000 0 0x1000
mmc read 0x24000000 0x1709 0x8f7
```

Require both reads to succeed. Then write **only** the FIT and compare it:

```text
mmc dev 0 1 && mmc write 0x10000000 0x1000 0x709
mmc read 0x20000000 0x1000 0x709 && cmp.b 0x10000000 0x20000000 0xe1200
crc32 0x20000000 0xe1200
hash sha256 0x20000000 0xe1200
iminfo 0x20000000
```

Require 1801 blocks written/read, all 922112 bytes identical, the expected
CRC/SHA256, and both FIT hashes OK. Verify the untouched loader/environment and
tail, then restore the user-area selection without writing it:

```text
mmc read 0x23000000 0 0x1000 && cmp.b 0x22000000 0x23000000 0x200000
mmc read 0x25000000 0x1709 0x8f7 && cmp.b 0x24000000 0x25000000 0x11ee00
mmc dev 0 0
```

Require all prefix/tail bytes identical. No `saveenv`, loader write, kernel/rootfs
write, or software reset. If UART execution is ambiguous, inspect console replay
and read storage before retrying; a bare newline can repeat the previous command.
Cold power-cycle by hand, intercept autoboot, and verify the banner and DRAM.

For the development board's existing custom p15 installation only, read the
kernel and DTB and check their CRCs before booting; these locations are **not** a
universal partition layout or an installer:

```text
mmc dev 0 0
mmc read 0x00080000 0x3000 0x4428
crc32 0x00080000 0x885000
mmc read 0x06000000 0x8000 0x10
crc32 0x06000000 0x2000
```

Expected CRCs: kernel `92509926`, DTB `8cc340c0`. Only after both match:

```text
setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p15 rw rootwait
booti 0x00080000 - 0x06000000
```

This avoids executing the stock fallback. Check CPU online `0-1`, memory, and
client-only DHCP in Linux. Do not boot stock firmware on the home LAN: it may
start a DHCP server and update storage.

### 6.4 eMMC boot1 — stock CFE, and the boot-partition switch

The eMMC has two 4 MiB hardware boot partitions. boot0 normally holds our U-Boot;
the *factory* image (`emmc_boot0_stock.bin`, the stock CFE) can be placed in boot1 so
the unit can boot stock firmware from the boot partition as well:

```bash
tools/sercomm_hg6244b/flash_emmc_boot1_stock.py
```

That script writes only `hwpart 2`, and proves isolation by recording boot0's CRC32
before and after the write and failing if it changed.

Selecting which partition the BootROM boots is a single EXT_CSD write — no data is
touched and it is fully reversible:

```text
mmc partconf 0              # read EXT_CSD[179]
mmc partconf 0 1 2 0        # BOOT_ACK=1, BOOT_PARTITION_ENABLE=2 (boot1), PARTITION_ACCESS=0
mmc partconf 0 1 1 0        # ...and back to boot0 (our U-Boot)
```

Then **cold power-cycle**.

> [!NOTE]
> Observed behaviour: the stock CFE re-asserts `EXT_CSD[179]` with
> `BOOT_PARTITION_ENABLE=1` during its own initialisation (the CFE image contains
> `CMD 6 - SWITCH` handling and partition-select error paths; nothing in the stock
> rootfs touches the boot-partition config). The practical effect is convenient —
> setting `BOOT_PARTITION_ENABLE=2` boots stock CFE **exactly once**, and the next
> boot is back on boot0/U-Boot automatically. It is not a sticky setting.

To boot stock Linux from U-Boot instead, use the `boot_cfe` env macro (present in
both env files), which loads the CFE from `bootfs1` in the user area:

```text
run boot_cfe
boot_cfe=echo Booting stock CFE from eMMC bootfs1 ...; mmc dev 0 0; mmc read 0x04000000 0x1000 0x900; cp.b 0x040012a1 0x01000000 0x1008d8; mw.b 0x011008d8 0 0x00200000; mw.l 0x0101f2e0 0x14000004 1; dcache off; icache off; go 0x01000000
```

---

## 7. Console

### 7.1 Serial

The default console is 115200 8N1. The current development bridge is
`172.16.1.109:8888`; some legacy tools still hardcode `.110`, so check their
configuration before use. The bridge is effectively single-client and replays
buffered output on connection. Quiet-drain helpers can return before long MMC
operations finish; require a fresh, attributable response before continuing.

### 7.2 NetConsole (opt-in)

UDP **6666**, `ncip=255.255.255.255` (broadcast), while the serial console stays
attached:

```text
run netconsole
```

```bash
tools/sercomm_hg6244b/netconsole.py 192.168.1.1
```

The console switch is live: `common/console.c` registers
`U_BOOT_ENV_CALLBACK(console, on_console)`, so `setenv stdin/stdout` re-assigns the
console immediately without a reboot.

> [!WARNING]
> Keep `stderr=serial`. Routing `stderr` to `nc` is what produces the recursive
> `bbh full` / `Failed to send packet` storm described in §4.2.

Because the shipped default environment is serial-only, a unit **without** UART
access can still be recovered: hold the **Wi-Fi button (GPIO 81)** at power-on, which
runs `btn_wifi` → `run netconsole`.

---

## 8. Safety rules

1. **Never use the software `reset` command.** Cold power-cycle by hand. (Untested
   reset paths have left units in a state where the console does not come back.)
2. **Never write eMMC `hwpart 0`** — the user area, its GPT, and every partition.
   Only `hwpart 1` (boot0) and `hwpart 2` (boot1) are ever written.
3. **Never `make clean`** in the bootloader tree.
4. In Linux, `/etc/mount_fs.sh` runs `mke2fs -t ext4 -F /dev/protect` on **any**
   non-zero exit from `mount`. A failed mount of the factory-data partition will
   therefore wipe factory data. Mount it read-only (`mount -t ext4 /dev/protect
   /var/ft -r`) and never let that script see a failure.
5. `mmc partconf` writes only EXT_CSD and is reversible; `mmc rst-function` and
   `mmc hwpartition … complete` are **write-once** — do not touch them.
6. Do not start a DHCP server on a connected home LAN. The custom p15 system
   uses an `udhcpc` client on `br0`; never run the stock fallback casually.
7. FIT-only updates preserve the loader and saved environment. Never substitute
   a whole-boot0 image or invoke HTTP firmware upload as a diagnostic check.

---

## 9. Hardware reference

See [`GPIO_MAP.md`](GPIO_MAP.md) for the full GPIO map, LED level table, the button
wiring and the correction history.

Stock eMMC partition map (identical GUIDs on both units): `nvram`, `bootfs1`,
`rootfs1`, `mdata1_1/2`, `bootfs2`, `rootfs2`, `mdata2_1/2`, `protect`, `bootflag`,
`xmlcfg`, `exmlcfg`, `appdata`, `reserved`.

Factory data (serial numbers, MACs, hardware version) lives in the **`protect`**
partition, an ext4 filesystem (UUID `9bef0001-d5e8-45c2-a409-6b96662d45f3`, 10 MiB)
mounted read-only at `/var/ft`. The chain is: GPT partition name → `/etc/mdev.conf`
→ `/etc/make_mmc_links.sh` → `/dev/protect` → `mount -r` → `libhal_product.so`
(`hal_mfg_*_from_flash()`, `/tmp/hw_info/csn`).

> [!NOTE]
> The base station's GPON serial number is **not** stored anywhere on the eMMC (the
> full 7.8 GB raw image was scanned for `ZTEG`/`ELFE`/`ALCL`/`HWTC`/`TMBB`/`gpon_sn`
> with no hits); it lives in SoC OTP.
