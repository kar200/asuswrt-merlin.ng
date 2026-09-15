#!/usr/bin/env bash
#
# Build both SPI-NOR and eMMC Bootloaders and package deliverables.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "############################################################"
echo "# Sercomm HG6244B U-Boot End-to-End Build Pipeline         #"
echo "############################################################"

bash "${SCRIPT_DIR}/build_spinor.sh"
bash "${SCRIPT_DIR}/build_emmc.sh"

echo ""
echo "############################################################"
echo "# All Bootloaders Built and Verified Successfully!         #"
echo "# Deliverables staged in: ${SCRIPT_DIR}/deliverables       #"
echo "############################################################"
ls -la "${SCRIPT_DIR}/deliverables"
cat "${SCRIPT_DIR}/deliverables/checksums.sha256"
