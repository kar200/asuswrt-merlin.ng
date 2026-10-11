#!/usr/bin/env bash
#
# Build Broadcom BCM6856 Linux 4.1.52 Kernel for Sercomm HG6244B.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
KDIR="/build/asuswrt-merlin/release/src-rt-5.02L.07p2axhnd/kernel/linux-4.1"
BRCMDRIVERS_DIR="/build/asuswrt-merlin/release/src-rt-5.02L.07p2axhnd/bcmdrivers"
DELIV_DIR="${SCRIPT_DIR}/deliverables/kernel"
JOBS="${JOBS:-$(nproc)}"
CONTAINER="${CONTAINER:-sercomm-toolchain}"
IMAGE="${IMAGE:-docker.io/gnuton/asuswrt-merlin-toolchains-docker:latest}"
TOOLCHAIN_PREFIX="/opt/toolchains/crosstools-aarch64-gcc-5.5-linux-4.1-glibc-2.26-binutils-2.28.1/bin/aarch64-linux-"

echo "============================================================"
echo " Building BCM6856 Linux 4.1.52 Kernel"
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
"

echo "[*] Ensuring bcmdrivers autogen files exist..."
podman exec -u 0 "${CONTAINER}" bash -lc "
cd '${BRCMDRIVERS_DIR}'
if [ ! -f Kconfig.autogen ] || [ ! -f Makefile.autogen ]; then
    echo '# Automatically generated file -- do not modify manually' > Kconfig.autogen.tmp
    echo '# Automatically generated file -- do not modify manually' > Makefile.autogen.tmp
    echo '\$(info READING AG MAKEFILE)' >> Makefile.autogen.tmp
    for autodetect in \$(find * -type f -name autodetect); do
        dir=\${autodetect%/*}
        driver=\$(grep -i '^DRIVER\|FEATURE:' \$autodetect | awk -F ': *' '{ print \$2 }')
        [ \"\$driver\" ] || driver=\${dir##*/}
        DRIVER=\$(echo \"\${driver}\" | tr '[:lower:]' '[:upper:]')
        echo \"\\\$(eval \\\$(call LN_RULE_AG, CONFIG_BCM_\${DRIVER}, \$dir, \\\$(LN_NAME)))\" >> Makefile.autogen.tmp
        if [ -e \$dir/Kconfig.autodetect ]; then
            echo \"menu \\\"\${DRIVER}\\\"\" >> Kconfig.autogen.tmp
            echo \"source \\\"../../bcmdrivers/\$dir/Kconfig.autodetect\\\"\" >> Kconfig.autogen.tmp
            echo \"endmenu \" >> Kconfig.autogen.tmp
            echo \"\" >> Kconfig.autogen.tmp
        fi
    done
    mv Makefile.autogen.tmp Makefile.autogen
    mv Kconfig.autogen.tmp Kconfig.autogen
fi
"

echo "[*] Configuring kernel with kernel_4.1_bcm6856.config..."
podman exec -u 0 "${CONTAINER}" bash -lc "
set -e
export BUILD_DIR=/build/asuswrt-merlin/release/src-rt-5.02L.07p2axhnd
export SHARED_DIR=\${BUILD_DIR}/shared
export BRCMDRIVERS_DIR=\${BUILD_DIR}/bcmdrivers
export KERNEL_DIR=\${BUILD_DIR}/kernel/linux-4.1
export BRCM_BOARD=bcm963xx
export BRCM_CHIP=6856
export BRCM_BOARD_ID=96856
export INC_BRCMSHARED_PUB_PATH=\${SHARED_DIR}/opensource/include
export INC_BRCMSHARED_PRIV_PATH=\${SHARED_DIR}/broadcom/include
export INC_BRCMDRIVER_PUB_PATH=\${BRCMDRIVERS_DIR}/opensource/include
export INC_BRCMDRIVER_PRIV_PATH=\${BRCMDRIVERS_DIR}/broadcom/include
export INC_BRCMBOARDPARMS_PATH=\${SHARED_DIR}/opensource/boardparms
export INC_FLASH_PATH=\${SHARED_DIR}/opensource/flash
export INC_UTILS_PATH=\${SHARED_DIR}/opensource/utils
export INC_SPI_PATH=\${SHARED_DIR}/opensource/spi
export INC_BCMDRIVER_PATH=\${BRCMDRIVERS_DIR}
export BCM_KF=1

cd "${KDIR}"
cp /build/asuswrt-merlin/tools/sercomm_hg6244b/kernel_4.1_bcm6856.config .config
make ARCH=arm64 CROSS_COMPILE='${TOOLCHAIN_PREFIX}' olddefconfig
"

echo "[*] Building kernel Image..."
podman exec -u 0 "${CONTAINER}" bash -lc "
set -e
export BUILD_DIR=/build/asuswrt-merlin/release/src-rt-5.02L.07p2axhnd
export SHARED_DIR=\${BUILD_DIR}/shared
export BRCMDRIVERS_DIR=\${BUILD_DIR}/bcmdrivers
export KERNEL_DIR=\${BUILD_DIR}/kernel/linux-4.1
export BRCM_BOARD=bcm963xx
export BRCM_CHIP=6856
export BRCM_BOARD_ID=96856
export INC_BRCMSHARED_PUB_PATH=\${SHARED_DIR}/opensource/include
export INC_BRCMSHARED_PRIV_PATH=\${SHARED_DIR}/broadcom/include
export INC_BRCMDRIVER_PUB_PATH=\${BRCMDRIVERS_DIR}/opensource/include
export INC_BRCMDRIVER_PRIV_PATH=\${BRCMDRIVERS_DIR}/broadcom/include
export INC_BRCMBOARDPARMS_PATH=\${SHARED_DIR}/opensource/boardparms
export INC_FLASH_PATH=\${SHARED_DIR}/opensource/flash
export INC_UTILS_PATH=\${SHARED_DIR}/opensource/utils
export INC_SPI_PATH=\${SHARED_DIR}/opensource/spi
export INC_BCMDRIVER_PATH=\${BRCMDRIVERS_DIR}
export BCM_KF=1

cd "${KDIR}"
make -j${JOBS} BUILD_NAME=BCM96856GWO ARCH=arm64 CROSS_COMPILE='${TOOLCHAIN_PREFIX}' Image
"

echo "[+] Kernel build complete. Staging deliverables..."
mkdir -p "${DELIV_DIR}"
cp -v "${REPO_ROOT}/release/src-rt-5.02L.07p2axhnd/kernel/linux-4.1/arch/arm64/boot/Image" "${DELIV_DIR}/Image"
cp -v "${REPO_ROOT}/release/src-rt-5.02L.07p2axhnd/kernel/linux-4.1/System.map" "${DELIV_DIR}/System.map"
cp -v "${REPO_ROOT}/release/src-rt-5.02L.07p2axhnd/kernel/linux-4.1/.config" "${DELIV_DIR}/kernel.config"

echo "[+] Kernel Image successfully staged in: ${DELIV_DIR}"
ls -la "${DELIV_DIR}"

