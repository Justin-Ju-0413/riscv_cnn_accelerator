#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SDK_ROOT="${ROOT_DIR}/third_party/nuclei-sdk"
SRC_APP_DIR="${ROOT_DIR}/sw/sdk_project/nuclei_app"
DEST_APP_DIR="${SDK_ROOT}/application/baremetal/cnn_accel_demo"
SRC_INC_DIR="${ROOT_DIR}/sw/inc"
DEST_INC_DIR="${DEST_APP_DIR}/include"

if [ ! -d "${SDK_ROOT}" ]; then
    echo "Missing Nuclei SDK at ${SDK_ROOT}"
    echo "Clone the SDK first, then rerun this script."
    exit 1
fi

if [ ! -f "${SRC_APP_DIR}/main.c" ] || [ ! -f "${SRC_APP_DIR}/Makefile" ]; then
    echo "SDK-native app template is incomplete under ${SRC_APP_DIR}"
    exit 1
fi

rm -rf "${DEST_APP_DIR}"
mkdir -p "${DEST_INC_DIR}"

cp "${SRC_APP_DIR}/main.c" "${DEST_APP_DIR}/main.c"
cp "${SRC_APP_DIR}/Makefile" "${DEST_APP_DIR}/Makefile"
cp "${SRC_INC_DIR}/custom_insn.h" "${DEST_INC_DIR}/custom_insn.h"
cp "${SRC_INC_DIR}/cnn_v1_driver.h" "${DEST_INC_DIR}/cnn_v1_driver.h"
cp "${SRC_INC_DIR}/cnn_v1_benchmark.h" "${DEST_INC_DIR}/cnn_v1_benchmark.h"
cp "${SRC_INC_DIR}/cnn_v1_demo.h" "${DEST_INC_DIR}/cnn_v1_demo.h"

echo "Installed SDK app to ${DEST_APP_DIR}"
echo "Next step:"
echo "  cd ${DEST_APP_DIR}"
echo "  make SOC=<your_soc> BOARD=<your_board> CORE=<your_core>"
