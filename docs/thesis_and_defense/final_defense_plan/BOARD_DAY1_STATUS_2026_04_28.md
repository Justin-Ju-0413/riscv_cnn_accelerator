# 2026-04-28 Board Connection Status

## Summary

Today's board-side work started with a Windows/Vivado connection check.

Result:

- Vivado found the USB JTAG target.
- After reconnecting the board, Vivado detected `xc7a100t_0` on the JTAG chain.
- Windows UART is not ready because the USB Serial device is in an error state.

## Evidence

Vivado target found:

```text
localhost:3121/xilinx_tcf/Digilent/210512180081
```

Vivado failure:

```text
No devices detected on target localhost:3121/xilinx_tcf/Digilent/210512180081.
```

Vivado pass after reconnect:

```text
HW_DEVICES=xc7a100t_0
HW_DEVICE=xc7a100t NAME=xc7a100t_0
CHECK_PASS: xc7a100t_0 detected
```

USB status:

```text
USB Serial Converter: OK
USB Serial: Error
```

## Interpretation

This is a board connection and artifact-preparation blocker, not an RTL/full-SoC logic failure.

The current priority is to make the physical board path visible:

1. Keep Vivado detection of `xc7a100t_0` stable.
2. Make Windows expose a healthy UART COM port.
3. Rebuild or copy a fresh `system.bit`.
4. Then program the board and collect UART/LED/ILA evidence.

## Next Action

Check board power, JTAG orientation, mode switches, USB-UART driver, and cable seating. After that, rerun:

```powershell
& 'D:\Xilinx\Vivado\2023.2\bin\vivado.bat' -nojournal -nolog -mode batch -source 'C:\Users\16084\Documents\New project\riscv_cnn_accelerator\scripts\check_vivado_hw.tcl'
```
