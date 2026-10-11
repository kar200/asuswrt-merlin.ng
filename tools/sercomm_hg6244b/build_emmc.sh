#!/usr/bin/env bash
#
# Build Broadcom BCM6856 eMMC Bootloader for Sercomm HG6244B.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BLDIR="/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders"
OPTIONS="options_6856_emmc"
CHIP="6856"
JOBS="${JOBS:-$(nproc)}"
CONTAINER="${CONTAINER:-sercomm-toolchain}"
IMAGE="${IMAGE:-docker.io/gnuton/asuswrt-merlin-toolchains-docker:latest}"

echo "============================================================"
echo " Building BCM6856 eMMC Bootloader (${OPTIONS})"
echo " Repository: ${REPO_ROOT}"
echo "============================================================"

# Ensure build container is running and correctly mounted
if podman container exists "${CONTAINER}" 2>/dev/null; then
    mounted_src=$(podman inspect "${CONTAINER}" --format '{{range .Mounts}}{{if eq .Destination "/build/asuswrt-merlin"}}{{.Source}}{{end}}{{end}}')
    if [ "${mounted_src}" != "${REPO_ROOT}" ]; then
        echo "[!] Container '${CONTAINER}' mounts '${mounted_src}' instead of '${REPO_ROOT}'."
        CONTAINER="sercomm-toolchain-$(basename "${REPO_ROOT}")"
    fi
fi

if ! podman container exists "${CONTAINER}" 2>/dev/null; then
    echo "[*] Creating Podman container '${CONTAINER}'..."
    podman run -d --name "${CONTAINER}" \
        -v "${REPO_ROOT}:/build/asuswrt-merlin:z" \
        "${IMAGE}" sleep infinity
else
    podman start "${CONTAINER}" >/dev/null 2>&1 || true
fi

echo "[*] Setting up toolchain environment in '${CONTAINER}'..."
podman exec -u 0 "${CONTAINER}" bash -lc "
mkdir -p /opt
if [ ! -e /opt/toolchains ]; then
    ln -snf /home/docker/am-toolchains/brcm-arm-hnd /opt/toolchains
fi
if [ -d /opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1 ] && [ ! -e /opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr ]; then
    ln -snf . /opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr
fi
"

echo "[*] Running build inside container '${CONTAINER}'..."
podman exec -u 0 "${CONTAINER}" bash -lc "
set -e
cd '${BLDIR}'

# Clean previous target configs to prevent stale configs
rm -f u-boot-2019.07/configs/tmp_*bcm96856_defconfig
rm -f obj/uboot/.config
rm -f obj/binaries/*env.bin_headered

MK='make OPTIONS=${OPTIONS} BRCM_CHIP=${CHIP}'

echo '=== Step 1: Configure & Common (TPL, DDR3, MCB, hashtable) ==='
\$MK -j${JOBS} common

echo '=== Step 2: Build SPL (FSBL) ==='
\$MK -j${JOBS} spl

echo '=== Step 3: Build U-Boot Proper ==='
\$MK -j${JOBS} uboot

echo '=== Step 4: Assemble Stage 1 Loader (2MB) ==='
\$MK -j${JOBS} loaderimage

echo '=== Step 5: Assemble Bootstrap Image (eMMC boot partition) ==='
\$MK -j${JOBS} image_bootstrap_emmc
"

echo "[+] eMMC build finished successfully."
echo "[*] Assembling and verifying deliverables..."
python3 "${SCRIPT_DIR}/assemble_and_verify.py" --target emmc
