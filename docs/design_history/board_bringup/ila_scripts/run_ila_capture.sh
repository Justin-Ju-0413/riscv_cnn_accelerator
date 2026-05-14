#!/bin/bash
# 一键 ILA 捕获 + 渲染
# 用法: bash run_ila_capture.sh pc_trace
#       bash run_ila_capture.sh nice_activity
#       bash run_ila_capture.sh all

MODE="${1:-all}"
VIVADO="D:\\Xilinx\\Vivado\\2023.2\\bin\\vivado.bat"
PYTHON="/c/Users/16084/AppData/Local/Programs/Python/Python313/python.exe"
TCL_SCRIPT="/c/Users/16084/Desktop/capture_ila.tcl"
RENDER_SCRIPT="/c/Users/16084/Desktop/render_ila_waveforms.py"

run_one() {
    local m=$1
    echo ""
    echo "############################################"
    echo "  Capturing: $m"
    echo "############################################"

    # Step 1: Capture with Vivado Tcl
    echo "[1/2] Running Vivado ILA capture..."
    cmd.exe /c "$VIVADO -mode tcl -source $TCL_SCRIPT -tclargs $m"

    if [ $? -ne 0 ]; then
        echo "ERROR: Vivado capture failed for $m"
        return 1
    fi

    # Step 2: Render with Python
    local csv_file="/c/Users/16084/Desktop/ila_${m}.csv"
    local png_file="/c/Users/16084/Desktop/ila_${m}.png"

    if [ ! -f "$csv_file" ]; then
        echo "ERROR: CSV not found: $csv_file"
        return 1
    fi

    echo "[2/2] Rendering waveform..."
    "$PYTHON" "$RENDER_SCRIPT" "$csv_file" "$m" "$png_file"

    if [ $? -eq 0 ]; then
        echo "Output: $png_file"
    fi
}

case "$MODE" in
    pc_trace|nice_activity)
        run_one "$MODE"
        ;;
    all)
        run_one "pc_trace"
        echo ""
        echo "============================================"
        echo "  Switch bitstream and re-run for nice_activity"
        echo "============================================"
        echo ""
        echo "NOTE: You need to program the CNN bitstream before capturing nice_activity."
        echo "The Tcl script will do this automatically."
        echo ""
        run_one "nice_activity"
        ;;
    *)
        echo "Usage: bash run_ila_capture.sh <pc_trace|nice_activity|all>"
        exit 1
        ;;
esac

echo ""
echo "Done!"
