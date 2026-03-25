#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_DIR="${1:-${SDK_DIR:-${ROOT_DIR}/third_party/nuclei-sdk}}"
PATCH_FILE="${PATCH_FILE:-${ROOT_DIR}/patches/nuclei-sdk-phase3-e203-safe.patch}"
STARTUP_FILE="${SDK_DIR}/SoC/evalsoc/Common/Source/GCC/startup_evalsoc.S"
SYSTEM_FILE="${SDK_DIR}/SoC/evalsoc/Common/Source/system_evalsoc.c"

sdk_patch_looks_present() {
  [[ -f "${STARTUP_FILE}" ]] && [[ -f "${SYSTEM_FILE}" ]] || return 1

  if grep -q 'E203_HBIRD_SAFE_STARTUP' "${STARTUP_FILE}" && \
     grep -q 'E203_HBIRD_SAFE_STARTUP' "${SYSTEM_FILE}"; then
    return 0
  fi

  return 1
}

if [[ ! -f "${PATCH_FILE}" ]]; then
  echo "[SDK_PATCH_ERROR] missing patch file: ${PATCH_FILE}" >&2
  exit 1
fi

if ! git -C "${SDK_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[SDK_PATCH_ERROR] not a git repository: ${SDK_DIR}" >&2
  exit 1
fi

if git -C "${SDK_DIR}" apply --check "${PATCH_FILE}" >/dev/null 2>&1; then
  git -C "${SDK_DIR}" apply "${PATCH_FILE}"
  echo "[SDK_PATCH] applied ${PATCH_FILE} to ${SDK_DIR}"
  exit 0
fi

if git -C "${SDK_DIR}" apply --reverse --check "${PATCH_FILE}" >/dev/null 2>&1; then
  echo "[SDK_PATCH] already present in ${SDK_DIR}"
  exit 0
fi

if sdk_patch_looks_present; then
  echo "[SDK_PATCH] startup-safe markers already present in ${SDK_DIR}; skipping patch replay"
  exit 0
fi

echo "[SDK_PATCH_ERROR] patch does not apply cleanly to ${SDK_DIR}" >&2
echo "[SDK_PATCH_ERROR] confirm the SDK tree matches origin/master or manually inspect local differences" >&2
exit 1
