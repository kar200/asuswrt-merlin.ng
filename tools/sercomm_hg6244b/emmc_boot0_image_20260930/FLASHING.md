# Flashing `emmc_boot0_rescuecli2_20260930.bin` from a running Linux

This is a **complete, prebuilt eMMC boot0 image** (4 MiB) — no rebuild needed.
It contains the whole bootloader chain of the Sercomm HG6244B v2
(Broadcom BCM6856):

| region | offset | content |
|---|---|---|
| 0x00000–0x20000 | SPL | U-Boot SPL 2019.07 (Sep 30 2026 - 06:50:20) with the **early amber status LED** (~1 s after power-on) and the SHA-256 blob table |
| 0x20000 | DDR3 blob | DDR training (unchanged) |
| 0x40000 / 0xae000 | environment | both env slots, pre-loaded: `bootcmd` auto-boots via stage-2 CFE, `reset_cli` (NetConsole UDP 6666 + **blue** LED), `boot_cfe` from p6, `boot_cfe_p2`, `boot_factory` (factory stage-1 CFE in boot1) |
| 0x80000 + copies | TPL | U-Boot TPL 2019.07 (Sep 30 2026 - 06:50:18) |
| 0x200000 | FIT | U-Boot proper `rescuecli2` (Sep 30 2026 - 06:23:18) |
| tail | — | 0xFF |

The SPL and TPL are a **SHA-256-coupled set** — this image keeps them matched
(see the loader-set rule in `../README.md`). Flashing it whole is therefore the
safe update path; never assemble partial loaders by hand.

What it does **not** touch: the eMMC user area (GPT, kernels, rootfs, your
data), eMMC **boot1** (factory stage-1 CFE reserve), and of course the SPI NOR
chip. After flashing, firmware slots/rootfs stay exactly as they are — only
the bootloader changes.

## Flash procedure (stock firmware or custom rootfs — identical)

Requirements: root shell on the router. On **stock** firmware get it with the
TR-069 unlock (`tools/unlock2/` in the elife-router-tools repo: SSH as
`SuperUser`, password = serial, then `sh`). On the custom rootfs you already
have root SSH.

### 1. Transfer the image to the router

`scp` does **not** work on stock firmware (the SSH login shell is `sc_cli`,
which rejects the sftp/scp subsystem). Use any of:

```sh
# a) have the router pull it (works everywhere; serve from your PC)
python3 -m http.server 8080            # on the PC, in the image's folder
wget -O /tmp/boot0.bin http://192.168.1.100:8080/emmc_boot0_rescuecli2_20260930.bin

# b) USB stick (mount it, copy the file)
# c) plain scp — custom rootfs only
scp emmc_boot0_rescuecli2_20260930.bin root@192.168.1.1:/tmp/boot0.bin
```

### 2. Verify the source file on the router

```sh
md5sum /tmp/boot0.bin
# must print: 92185071727657ea2fbbf59ea0d24369
```

### 3. Flash — eMMC boot0 (hardware boot partition 1) only

```sh
echo 0 > /sys/block/mmcblk0boot0/force_ro          # unlock the boot partition
dd if=/tmp/boot0.bin of=/dev/mmcblk0boot0 bs=512 conv=fsync
sync
echo 1 > /sys/block/mmcblk0boot0/force_ro          # re-lock
```

`/dev/mmcblk0boot0` is the eMMC hardware boot partition — 4 MiB, exactly the
size of this image. Do **not** substitute `mmcblk0boot1` (factory CFE reserve)
or any `mmcblk0p*` device.

### 4. Verify the flash (mandatory)

```sh
md5sum /dev/mmcblk0boot0
# must print: 92185071727657ea2fbbf59ea0d24369  (the full 4 MiB read-back)
```

Only reboot when the read-back checksum matches. If it does not, **do not
reboot** — re-run the `dd` and verify again (the running system is unaffected
until reboot; the old bootloader is what is keeping you alive).

### 5. Reboot

```sh
reboot
# or on stock: power-cycle. From a custom rootfs:
#   sync; echo b > /proc/sysrq-trigger
```

## Post-flash verification

- Front-panel status LED: **amber ~1 s after power-on** (before DDR training).
- Serial console / NetConsole shows `U-Boot SPL 2019.07 (Sep 30 2026 - 06:50:20)`,
  three `digest sha256 OK` lines, then `U-Boot 2019.07 (Sep 30 2026 - 06:23:18)`.
- Normal boot proceeds automatically (`bootcmd` → stage-2 CFE → your firmware
  slots); the status LED goes green at chain start.
- Pressing RESET during the 3 s boot window drops to the recovery CLI:
  status LED turns **blue**, NetConsole listens on UDP 6666 (broadcast), e.g.
  `netconsole 192.168.1.1` from a Linux PC gives a full U-Boot shell over the
  network — U-Boot can be re-flashed from there without opening the case.

## Recovery if a flash goes wrong

An interrupted `dd` (power loss mid-write) can leave the board unbootable with
no prompt. Recovery paths, in order of convenience:

1. **SPI NOR strap**: the board's soldered 16 MiB NOR flash holds a standalone
   U-Boot. Open the boot-strap resistor (R18 open = boot from NOR), power on,
   and the NOR U-Boot gives a prompt with eMMC write access — re-flash boot0
   from there (YMODEM: `loady` + `mmc dev 0 1` + `mmc write`), then restore
   the strap.
2. CH341A / external programmer on the eMMC or NOR.
