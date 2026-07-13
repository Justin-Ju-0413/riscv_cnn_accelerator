#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<'EOF'
Usage:
  ./Project_Manager.sh setup
  ./Project_Manager.sh run_hw
  ./Project_Manager.sh gen_model
  ./Project_Manager.sh precheck
  ./Project_Manager.sh status
  ./Project_Manager.sh install_sdk_app
  ./Project_Manager.sh new_benchmark_record short-name
EOF
}

cmd="${1:-}"

case "$cmd" in
    setup)
        echo ">>> No additional setup steps are required for the current repo."
        echo ">>> Ensure iverilog, vvp, gtkwave, and python3 are installed if you use all flows."
        ;;
    run_hw)
        make -C "$ROOT_DIR/hw/sim" clean
        make -C "$ROOT_DIR/hw/sim" run
        ;;
    gen_model)
        python3 "$ROOT_DIR/algo/python/generate_model.py"
        ;;
    precheck)
        "$ROOT_DIR/fpga/scripts/pre_sdk_check.sh"
        ;;
    status)
        echo "== Preparation Status =="
        echo "Hardware integration notes: INTEGRATION.md"
        echo "Decision matrix: INTEGRATION_DECISIONS.md"
        echo "Pre-SDK checklist: PRE_SDK_CHECKLIST.md"
        echo "Post-SDK playbook: POST_SDK_PLAYBOOK.md"
        ;;
    install_sdk_app)
        "$ROOT_DIR/sw/build/install_sdk_app.sh"
        ;;
    new_benchmark_record)
        shift
        "$ROOT_DIR/scripts/new_benchmark_record.sh" "$@"
        ;;
    *)
        usage
        exit 1
        ;;
esac
