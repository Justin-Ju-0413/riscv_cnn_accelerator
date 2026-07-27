#!/usr/bin/env bash

# Read-only environment report for the RISC-V/E203 NICE project.
# This script does not install packages, edit repositories, or touch hardware.

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOC_DIR="${SOC_DIR:-$(cd "${ROOT_DIR}/.." && pwd)/e203_hbirdv2}"
required_missing=0

print_tool() {
    local label="$1"
    local command_name="$2"
    local required="$3"
    local resolved
    local version

    resolved="$(command -v "${command_name}" 2>/dev/null || true)"
    if [[ -z "${resolved}" ]]; then
        if [[ "${required}" == "required" ]]; then
            printf 'MISSING  %-22s %s\n' "${label}" "${command_name}"
            required_missing=1
        else
            printf 'OPTIONAL %-22s not found\n' "${label}"
        fi
        return
    fi

    if [[ "${command_name}" == "iverilog" ]]; then
        version="$("${resolved}" -V 2>&1 | sed -n '1p')"
    else
        version="$("${resolved}" --version 2>&1 | sed -n '1p')"
    fi
    printf 'OK       %-22s %s | %s\n' "${label}" "${resolved}" "${version}"
}

print_repo() {
    local label="$1"
    local path="$2"

    if [[ ! -d "${path}/.git" ]]; then
        printf 'MISSING  %-22s %s\n' "${label}" "${path}"
        required_missing=1
        return
    fi

    printf 'OK       %-22s %s | branch=%s | commit=%s\n' \
        "${label}" \
        "${path}" \
        "$(git -C "${path}" branch --show-current)" \
        "$(git -C "${path}" rev-parse --short HEAD)"
}

printf 'RISC-V development environment audit\n'
printf 'date=%s\n' "$(date --iso-8601=seconds)"
printf 'user=%s\n' "$(id -un)"
printf 'kernel=%s\n' "$(uname -sr)"
printf '\nRepositories\n'
print_repo "accelerator repo" "${ROOT_DIR}"
print_repo "paired SoC repo" "${SOC_DIR}"

printf '\nRequired tools\n'
print_tool "RISC-V GCC" "riscv64-unknown-elf-gcc" required
print_tool "RISC-V debugger" "${RISCV_GDB_BIN:-gdb-multiarch}" required
print_tool "OpenOCD" "openocd" required
print_tool "Icarus Verilog" "iverilog" required
print_tool "GNU Make" "make" required
print_tool "Python" "python3" required
print_tool "Git" "git" required

printf '\nOptional publishing/board tools\n'
print_tool "GitHub CLI" "gh" optional
print_tool "Vivado" "vivado" optional

printf '\nBoard gates\n'
printf 'INFO     Vivado and physical UART/JTAG are optional for the current baseline reproduction.\n'

if [[ "${required_missing}" -ne 0 ]]; then
    printf '\nRESULT=FAIL (one or more required tools/repositories are missing)\n'
    exit 1
fi

printf '\nRESULT=PASS\n'
