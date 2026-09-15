# Sercomm HG6244B (BCM68360_B1 / BCM6856) — Bootloader Build & Flash Guide

Everything needed to rebuild, verify and flash the custom U-Boot 2019.07 that runs
alongside the stock firmware on the Sercomm HG6244B v2 — on **SPI NOR** and on
**eMMC** — from a clean checkout, without any of the original debugging context.

Board identity: `Chip ID: BCM68360_B1` (= BCM6856), CFE boardtype `968360BG`,
1 GiB DDR3, Samsung `8GTF4` eMMC (7.3 GiB), XM25QH13C-class 16 MiB SPI NOR.

---

## 0. TL;DR

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
| `tools/sercomm_hg6244b/deliverables/` | The final, verified images (and their checksums) exactly as flashed. |

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

All files below are in `tools/sercomm_hg6244b/deliverables/` and are exactly what was
flashed and verified on the router.

> [!NOTE]
> **Provenance.** These images were built from a working tree whose
> `include/configs/bcm96856.h` still carried `stdin`/`stdout` = `serial,nc` as the
> compiled-in default, and whose `bcmbca_xrdp_api.c` did not yet have the silent-drop
> patch (the `non empty at bbh full` string is still present in both images). The
> committed tree now has the serial-only header and the patch, so a rebuild from this
> repository produces a **different** FIT: the behaviour driven by the env blob is
> identical, the compiled-in defaults are not. Rebuild and re-verify the CRCs above
> before flashing if the images must match bit for bit.

### 5.1 SPI NOR (XM25QH128C-class, 16 MiB)

| File | Size | CRC32 | MD5 | Description |
|---|---|---|---|---|
| `spinor_16MB_full.bin` | 16777216 | `0e751af1` | `7677d87d6d582649787e57b4730c2848` | Full 16 MiB chip image (loader + FIT + 0xFF). For an external programmer. |
| `bootstrap_image_spinor.bin` | 3014656 | `e1410197` | `617876cee31c458b812e8b652f2612ce` | The first `0x2E0000` bytes of the above: loader + FIT padded to a block boundary. This is the payload for `sf update`. |
| `spinor_4MB_W25Q32JV.bin` | 4194304 | `09af12fa` | `f54619894c76d1ccfb85c717e4c91d28` | Full image for the 4 MiB W25Q32JV replacement parts. |
| `loader_spinor.bin` | 2097152 | `d68e84c5` | `c2c2d203bd1a44ba9b94b549894260b3` | Stage-1 TPL/SPL loader alone. |

U-Boot build stamp for the SPI images: `U-Boot 2019.07 (Sep 15 2026 - 12:54:45 +0000)`.

`spinor_4MB_W25Q32JV.bin` is byte-for-byte the first 4 MiB of `spinor_16MB_full.bin`
(verified), so it is produced by truncation rather than by a separate build — the
loader and FIT both fit well inside 4 MiB. Note that 4 MiB parts therefore leave no
room for the `bootfs`/`rootfs` `mtdparts` regions the 16 MiB env assumes.

Layout, identical on SPI NOR and inside the eMMC boot partition:

```
offset 0x000000  (2 MiB)   stage-1 loader (TPL + SPL + env blob)
offset 0x200000            U-Boot proper as a FIT (brcm_simple.itb)
```

### 5.2 eMMC boot0 (our U-Boot)

| File | Size | CRC32 | MD5 | Written to |
|---|---|---|---|---|
| `bootstrap_image_emmc_boot_part.bin` | 2097152 | `cd6bd371` | `54e1f4f0c0ebab2334f22c3d196bbb54` | the 2 MiB stage-1 loader → boot0 block `0x0` |
| `brcm_simple.itb` | 898621 | `b4cb9cb5` | `cc260ec3d595c16c5560ab13e1a2a37f` | the U-Boot FIT → boot0 block `0x1000` |
| `emmc_boot0_custom.bin` | 4194304 | `a1801fc3` | `99572b0d77b87e11e2f90ca8422a692b` | the whole boot0 via a single `mmc write 0x… 0 0x2000` |
| `emmc_boot0_stock.bin` | 4194304 | `2d64be07` | `1ad513ecf34b811556fbc35343888b76` | the **factory** boot-partition image (stock CFE), written to boot1 |

`emmc_boot0_custom.bin` is assembled from the two files above (loader at 0x0, FIT at
0x200000, 0xFF tail) — see `assemble_and_verify.py`. The staged names are unchanged
from the build pipeline output on purpose: `bootstrap_image_emmc_boot_part.bin` simply
is the 2 MiB loader, despite the generic name.

The FIT is written as 1756 blocks (`0x6DC`) = 899072 bytes, i.e. padded with 0xFF to
a 512-byte boundary; CRC32 of that padded region is `9d9e9043`.

U-Boot build stamp for the eMMC FIT: `U-Boot 2019.07 (Sep 15 2026 - 14:19:57 +0000)`.

> [!NOTE]
> The flasher writes **only** the loader range and the FIT range. The remaining
> ~1.2 MiB tail of boot0 is deliberately left untouched, so a CRC32 of the whole
> 4 MiB partition is *not* a stable identifier for a device that was flashed in
> place (it still contains whatever the partition held before). Compare the two
> ranges individually, or flash `emmc_boot0_custom.bin` if you want the whole
> partition deterministic.

---

## 6. Flashing

### 6.1 TFTP server

U-Boot pulls images with `tftpboot`. Port 69 needs root, so the helper server runs on
**6969** and U-Boot is pointed at it per transfer:

```bash
tools/sercomm_hg6244b/tftp_server.py [directory]   # defaults to deliverables/
```

```text
setenv tftpdstp 6969      # set for this transfer only — never saveenv this
```

`CONFIG_CMD_TFTPPUT is not set`, so U-Boot cannot upload. Host side is expected at
`192.168.1.100` (`serverip`).

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

### 6.3 eMMC boot0 — network flash

```bash
tools/sercomm_hg6244b/flash_emmc_uboot.py            # over the UART TCP bridge
tools/sercomm_hg6244b/flash_emmc_netconsole.py       # same, over UDP 6666 (no UART needed)
```

Both write **boot0 (hwpart 1) only**:

```text
tftpboot 0x04000000 bootstrap_image_emmc_boot_part.bin
mmc dev 0 1
mmc write 0x04000000 0x0 0x1000            # loader -> block 0x0
tftpboot 0x04000000 brcm_simple.itb
mw.b <end> 0xff <pad>                      # pad the tail of the last block
mmc write 0x04000000 0x1000 0x6DC          # FIT -> block 0x1000
# read both ranges back and compare CRC32
```

Every write is verified by reading the blocks back and comparing CRC32 against the
local file. `hwpart 0` (the user area, its GPT and every partition) is **never**
written.

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

The default and always-available console. 115200 8N1. On the development unit it is
reached through a TCP-UART bridge; the tools default to `172.16.1.110:8888` and
accept a host argument where it matters.

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
