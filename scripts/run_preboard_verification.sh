#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOC_DIR="${SOC_DIR:-${HOME}/Desktop/e203_hbirdv2}"

run_step() {
  local label="$1"
  shift
  echo "[PREBOARD_STEP] ${label}"
  "$@"
}

run_step "generate model" "${ROOT_DIR}/Project_Manager.sh" gen_model
run_step "sdk precheck" "${ROOT_DIR}/Project_Manager.sh" precheck
run_step "local rtl regression" "${ROOT_DIR}/Project_Manager.sh" run_hw
run_step "official lightweight nice" bash "${SOC_DIR}/tb/run_nice_light.sh"
run_step "sdk fullsoc regression" bash "${ROOT_DIR}/scripts/run_sdk_fullsoc_regression.sh"

echo "[PREBOARD_PASS] all pre-board simulations and tests passed"
