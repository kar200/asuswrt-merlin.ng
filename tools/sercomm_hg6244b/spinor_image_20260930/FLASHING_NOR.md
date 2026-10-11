# Flashing `spinor_16MB_full_rescuecli2_20260930.bin` (SPI NOR, 16 MiB)

Complete, prebuilt image for the soldered XMC XM25QH128C/D 16 MiB SPI NOR —
the same feature set as the eMMC `rescuecli2` release, nothing to rebuild.
Verified as a consistent SPL/TPL SHA-256 set before publishing (the SPL's
baked-in digest table matches the TPL in this image — see the loader-set rule
in `../README.md`; never mix blobs from different builds).

Layout (also validated by `assemble_and_verify.py`):

| offset | content |
|---|---|
| 0x00000 | SPL 2019.07 (Sep 30 2026) with **early amber status LED** + blob hash table |
| 0x20000 | DDR3 training blob |
| 0x40000 | environment — `bootcmd` auto-chains CFE from eMMC p6, `reset_cli` (NetConsole UDP 6666 + blue LED), `boot_cfe_p2`, `boot_factory`, full eMMC rescue tooling |
| 0xad000 | environment copy |
| 0x80000 + copies | TPL 2019.07 (Sep 30 2026) |
| 0x200000 | signed bootstrap FIT — U-Boot proper (Sep 30 2026) |
| end | 0xFF padding |

`bootcmd` on NOR now performs a **complete boot**: `init_leds` → eMMC probe →
chainload the stage-2 CFE from `p6`/`bootfs2` → your firmware slots. With this
image the NOR is a fully independent boot path (and NetConsole host), not just
a recovery prompt.

## Boot selector (hardware strap)

`MISC->miscStrapBus` bits 10..8, set by resistors R16/R17/R18
(populated = 0, open = 1; SoC pulls open pins high):

| strap | mode |
|---|---|
| **R18 shorted (factory)** | boot from **eMMC** |
| **R18 open** | boot from **SPI NOR** (this image) |

## Flash procedure 1 (preferred): in-system from the router's Linux

Boot the router from **eMMC** (factory strap) and flash the NOR from the
running system — the SoC's HSSPI bus is idle, no external programmer needed.
Works on the stock firmware and the custom rootfs (module vermagic matches the
4.1.52 flash kernel).

```sh
# 1. transfer spinor_flash.ko + the image to the router
#    (stock: wget from a PC HTTP server or USB stick; custom rootfs: scp)
#    module: ../kmod/snor_flash.ko in the elife-router-tools tree

# 2. create /dev/snor (16 MiB char device, erase-before-program)
insmod snor_flash.ko

# 3. verify the source image
md5sum spinor_16MB_full_rescuecli2_20260930.bin
#    expect 382361b765c863a879e75e279c13a94b  (sha256 in SHA256SUMS:
#    2ef2ec24bdbf95e651fd5c083e51e0244a2f342e0a95ecbca0775f1db17be225)

# 4. write the whole chip (~23 s) and read it back
dd if=spinor_16MB_full_rescuecli2_20260930.bin of=/dev/snor bs=1M
md5sum /dev/snor        # must match the image checksum exactly

# 5. power-cycle with R18 open -> boots this image
```

**Rule:** only flash the NOR while booted from eMMC. Never program the NOR the
system is currently executing from.

## Flash procedure 2: external programmer

Only with the chip desoldered (or the SoC held out of the bus — in-circuit
CH341A writes are unreliable because the BCM6856 HSSPI drives the same lines):

```sh
flashrom -p ch341a_spi -c XM25QH128C -w spinor_16MB_full_rescuecli2_20260930.bin
flashrom -p ch341a_spi -c XM25QH128C -v spinor_16MB_full_rescuecli2_20260930.bin
```

## FIT-only update (running NOR U-Boot)

If the loader (SPL/TPL/env) is already this build and only U-Boot proper
changed, update just the FIT region from the NOR U-Boot prompt:

```
loady 0x20000000                 # send the FIT over YMODEM
crc32 0x20000000 <size-hex>      # verify against the host CRC first
sf probe 0:0
sf update 0x20000000 0x200000 <size-aligned>
```

Never `sf write` over the loader region (0x0–0x200000) from the running NOR
U-Boot — that is the hash-coupled set; replace it whole from eMMC Linux.

## Post-flash verification

- R18 open, power on: status LED **amber ~1 s after power-on**, console shows
  `U-Boot SPL 2019.07 (Sep 30 2026 …)` → three `digest sha256 OK` → TPL →
  `U-Boot 2019.07 (Sep 30 2026 …)`, then auto-chains CFE from eMMC and boots
  your firmware. LED green at chain start.
- RESET during the 3 s window: recovery CLI, status LED **blue**, NetConsole
  on UDP 6666.
- Restore R18 (shorted) to return to eMMC boot.
