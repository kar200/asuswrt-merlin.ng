# Sercomm HG6244B (BCM6856) Bootloader Build & Flashing Guide

This directory contains the build automation, packaging scripts, and binary patch utilities for building the custom U-Boot 2019.07 bootloader for the **Sercomm HG6244B** (Broadcom BCM6856 dual Cortex-A53) home gateway.

---

## 1. Toolchain & Environment Setup (Podman)

The build utilizes the official ASUSWRT-Merlin toolchain container image (`docker.io/gnuton/asuswrt-merlin-toolchains-docker:latest`), which contains the required Broadcom AArch64 cross-compiler (`aarch64-linux-gcc 10.3.0`), host tools, and buildroot utilities.

### 1.1 Pull the Container Image
```bash
podman pull docker.io/gnuton/asuswrt-merlin-toolchains-docker:latest
```

### 1.2 Start the Build Container
You can let the build scripts launch the container automatically, or run it manually:
```bash
podman run -d --name sercomm-toolchain \
  -v "$(pwd)/../..:/build/asuswrt-merlin:z" \
  docker.io/gnuton/asuswrt-merlin-toolchains-docker:latest sleep infinity
```

> [!NOTE]
> Because rootless Podman maps your host UID to root inside the container, all compilation commands inside the container execute as UID 0 (`-u 0`) to seamlessly share write permissions on the bind-mounted repository.

---

## 2. Building the Bootloaders

All build scripts are located in `tools/sercomm_hg6244b/`.

### 2.1 Build Everything (Turnkey Pipeline)
To build both SPI-NOR and eMMC images and assemble final deliverables in one shot:
```bash
cd tools/sercomm_hg6244b
./build_all.sh
```

### 2.2 Individual Builds
- **SPI-NOR Flash Bootloader**:
  ```bash
  ./build_spinor.sh
  ```
- **eMMC Hardware Boot Partition Bootloader**:
  ```bash
  ./build_emmc.sh
  ```

---

## 3. Generated Deliverables

Artifacts are verified and staged in `tools/sercomm_hg6244b/deliverables/`:

| File | Size | Target Location | Description |
|---|---|---|---|
| `spinor_16MB_full.bin` | 16 MiB | Full SPI Flash | Complete 16 MiB chip image with 0xFF padding, suitable for external SPI programmers or flashing `0x0 - 0x1000000`. |
| `bootstrap_image_spinor.bin` | ~2.99 MiB | SPI Flash `0x0` | 2 MiB Stage 1 Loader + Stage 2 U-Boot FIT container (`brcm_simple.itb`), flashed via U-Boot `sf update 0x05000000 0 ${filesize}`. |
| `emmc_boot0_custom.bin` | 4 MiB | `mmcblk0boot0` | 2 MiB Stage 1 Loader + Stage 2 U-Boot FIT container, flashed to eMMC hardware boot partition 1 (`mmc dev 0 1`). |
| `brcm_simple.itb` | ~898 KiB | RAM or offset `0x200000` | Signed U-Boot proper FIT container with device tree and network drivers. |
| `checksums.sha256` | — | Host verification | SHA-256 hashes of all generated binaries. |

---

## 4. Hardware Pinout & Peripherals

### 4.1 Push Buttons
| Button | GPIO Pin | Active Level | Description |
|---|---|---|---|
| **PB_RESET** | **GPIO 26** | Low (0 = Pressed) | Front/Rear physical Reset button. Hooked to U-Boot rescue check. |
| **PB_WPS** | **GPIO 28** | Low (0 = Pressed) | Physical WPS button. Hooked to U-Boot WPS check. |
| **PB_WIFI** | **GPIO 81** | Low (0 = Pressed) | Physical Wi-Fi button. |

### 4.2 Front Panel LEDs (Active Low: 0 = ON, 1 = OFF)
| Indicator | GPIO Pin | Description | Default State in U-Boot |
|---|---|---|---|
| **STATUS Enable** | **GPIO 2** | Master power circuit for Status RGB LED | **0 (Active / Powered)** |
| **STATUS Red** | **GPIO 27** | Status Red channel | **0 (Active)** |
| **STATUS Green** | **GPIO 59** | Status Green channel | **0 (Active)** |
| **STATUS Blue** | **GPIO 22** | Status Blue channel | **1 (Off)** |
| **INTERNET Green** | **GPIO 1** | WAN Carrier Link Green | **1 (Off)** |
| **INTERNET Red** | **GPIO 62** | WAN No-Carrier Red | **1 (Off)** |
| **WPS RGB** | **GPIO 8, 9, 10** | WPS Red, Green, Blue | **1, 1, 1 (Off)** |
| **IPTV** | **GPIO 7** | IPTV Activity LED | **1 (Off)** |
| **Phone 1 / 2** | **GPIO 13, 0** | FXS VoIP status LEDs | **1, 1 (Off)** |

> [!TIP]
> The bootloader default is **Solid Amber Status LED** with all other LEDs off (`GPIO 2=0, 27=0, 59=0, 22=1`).

---

## 5. Flashing Procedures

### 5.1 Flashing SPI-NOR Flash from U-Boot Shell
1. Host PC connected to router LAN port at `192.168.1.100`.
2. Router boots to U-Boot prompt `=> ` at `192.168.1.1`.
3. In U-Boot:
   ```text
   setenv serverip 192.168.1.100; setenv ipaddr 192.168.1.1
   tftpboot 0x05000000 bootstrap_image_spinor.bin
   sf probe 0:0
   sf update 0x05000000 0 ${filesize}
   sf read 0x06000000 0 ${filesize}
   cmp.b 0x05000000 0x06000000 ${filesize}
   ```

### 5.2 Flashing eMMC Hardware Boot Partition (`mmcblk0boot0`)
#### Option A: From U-Boot Shell
```text
setenv serverip 192.168.1.100; setenv ipaddr 192.168.1.1
tftpboot 0x05000000 emmc_boot0_custom.bin
mmc dev 0 1
mmc write 0x05000000 0 0x2000
mmc read 0x06000000 0 0x2000
cmp.b 0x05000000 0x06000000 0x400000
```

#### Option B: From Linux Root Shell (In-System Flash)
```bash
# Unlock hardware boot partition
echo 0 > /sys/block/mmcblk0boot0/force_ro

# Flash 4 MiB image
dd if=emmc_boot0_custom.bin of=/dev/mmcblk0boot0 bs=1M && sync

# Verify readback
dd if=/dev/mmcblk0boot0 bs=1M count=4 | sha256sum

# Re-lock write protection
echo 1 > /sys/block/mmcblk0boot0/force_ro
```

---

## 6. NetConsole (Remote UDP Shell) Usage

NetConsole operates over **UDP port 6666** on IP `192.168.1.1`.

### Activating NetConsole Safely
To enable NetConsole on demand:
```text
run netconsole
```
Or manually:
```text
setenv ncip 255.255.255.255
setenv stdout serial,nc
setenv stdin serial,nc
setenv stderr serial
```

> [!WARNING]
> Keep `stderr=serial`! Never route `stderr` to `nc` persistently during cold boot. If network transmission experiences a packet drop, an error printed to `stderr` would recursively attempt network transmission, causing Broadcom buffer queue exhaustion (`bbh full`).

### Connecting from Host
**Recommended: Pure-Python Client** (Zero dependencies, bidirectional, raw TTY):
```bash
tools/sercomm_hg6244b/netconsole.py 192.168.1.1
```
Or in Fish shell:
```fish
netconsole 192.168.1.1
```

*Hotkeys:*
- `Ctrl+]` or `Ctrl+\` or `Ctrl+Q`: Exit console
- `Ctrl+C`: Send interrupt/break to U-Boot
- Pipe input supported: `echo "version" | tools/sercomm_hg6244b/netconsole.py 192.168.1.1`

Alternatively using `socat`:
```bash
socat file:$(tty),raw,echo=0 udp-datagram:192.168.1.1:6666,bind=:6666
```

---

## 7. Chainloading Stock CFE Firmware

To boot the factory firmware from eMMC at any time from U-Boot:
```text
run boot_cfe
```
Macro definition:
```text
boot_cfe=echo Booting stock CFE from eMMC bootfs1 ...; mmc dev 0 0; mmc read 0x04000000 0x1000 0x900; cp.b 0x040012a1 0x01000000 0x1008d8; mw.b 0x011008d8 0 0x00200000; mw.l 0x0101f2e0 0x14000004 1; dcache off; icache off; go 0x01000000
```
This reads `bootfs1` (LBA `0x1000`), extracts `cferam.000` at `+0x12a1`, patches CFE's interactive prompt delay, clears BSS, and executes stock Linux without touching factory flash partitions.

