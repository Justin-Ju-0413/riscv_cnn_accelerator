#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
status=0

check_cmd() {
    local cmd="$1"
    local label="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        printf '[OK]   %s: %s\n' "$label" "$(command -v "$cmd")"
    else
        printf '[MISS] %s: command `%s` not found\n' "$label" "$cmd"
        status=1
    fi
}

check_path() {
    local path="$1"
    local label="$2"
    if [ -e "$path" ]; then
        printf '[OK]   %s: %s\n' "$label" "$path"
    else
        printf '[MISS] %s: expected path missing -> %s\n' "$label" "$path"
        status=1
    fi
}

check_path_any() {
    local label="$1"
    shift
    local path
    for path in "$@"; do
        if [ -e "$path" ]; then
            printf '[OK]   %s: %s\n' "$label" "$path"
            return 0
        fi
    done

    printf '[MISS] %s: expected path missing -> %s\n' "$label" "$1"
    status=1
}

echo '== Basic Tool Check =='
check_cmd bash "Shell"
check_cmd make "Build tool"
check_cmd iverilog "Verilog compiler"
check_cmd vvp "Verilog runtime"
check_cmd python3 "Python runtime"

echo
echo '== Repository Layout Check =='
check_path "$ROOT_DIR/hw/rtl/acc/cnn_nice_core.v" "NICE top"
check_path "$ROOT_DIR/hw/rtl/soc_wrapper/e203_cnn_nice_soc_wrap.v" "SoC wrapper"
check_path "$ROOT_DIR/hw/tb/e203_nice_harness.v" "E203 harness"
check_path "$ROOT_DIR/sw/inc/custom_insn.h" "Firmware ISA header"
check_path "$ROOT_DIR/sw/build/sdk_env.sh.template" "SDK env template"
check_path "$ROOT_DIR/sw/sdk_project/Makefile.template" "SDK project Makefile template"
check_path "$ROOT_DIR/sw/sdk_project/application/main.c" "SDK project application entry"
check_path "$ROOT_DIR/sw/sdk_project/config/project.mk" "SDK project config"
check_path_any "Pre-SDK checklist" \
    "$ROOT_DIR/PRE_SDK_CHECKLIST.md" \
    "$ROOT_DIR/docs/PRE_SDK_CHECKLIST.md" \
    "$ROOT_DIR/docs/archive/PRE_SDK_CHECKLIST.md"
check_path "$ROOT_DIR/third_party/nuclei-sdk/README.md" "Local Nuclei SDK clone"
check_path "$ROOT_DIR/third_party/nuclei-sdk/setup_config.sh.template" "SDK setup config template"

echo
echo '== Optional SDK Variables =='
if [ -n "${NUCLEI_SDK_ROOT:-}" ]; then
    printf '[INFO] NUCLEI_SDK_ROOT=%s\n' "$NUCLEI_SDK_ROOT"
else
    echo '[INFO] NUCLEI_SDK_ROOT is not set yet'
fi

if [ -n "${RISCV_GCC_ROOT:-}" ]; then
    printf '[INFO] RISCV_GCC_ROOT=%s\n' "$RISCV_GCC_ROOT"
else
    echo '[INFO] RISCV_GCC_ROOT is not set yet'
fi

echo
if [ "$status" -eq 0 ]; then
    echo 'Pre-SDK environment check passed.'
else
    echo 'Pre-SDK environment check found missing prerequisites.'
fi

exit "$status"
