# Verification Flow v2.0 — CNN Accelerator on RISC-V FPGA

## Prerequisites

| Tool | Path | Version |
|------|------|---------|
| Vivado | `D:\Xilinx\Vivado\2023.2\bin\vivado.bat` | 2023.2 |
| RISC-V GCC | `D:\Xilinx\Vitis\2023.2\gnu\riscv\nt\riscv64-unknown-elf` | 12.2.0 |
| Git Bash | `/usr/bin/bash` | — |
| PuTTY | COM11, 115200-8N1 | — |
| Ubuntu VM | `ssh gstar@192.168.10.128` | Icarus Verilog |

## Repos

| Repo | Branch | Commit |
|------|--------|--------|
| `riscv_cnn_accelerator` | `codex/a7-bringup-v2-main` | `ca777c9` |
| `e203_hbirdv2` | `codex/a7-bringup-v2-soc` | `c20ce47` |

## Stage 1: RTL Simulation (16 tests)

```bash
ssh gstar@192.168.10.128 "cd ~/Desktop/riscv_cnn_accelerator && bash Project_Manager.sh run_hw"
```

**Expected output:** 16/16 `PASS`, including `normal_path expected=320 got=320`.

## Stage 2: Full-SoC Simulation (7 tests)

```bash
ssh gstar@192.168.10.128 "
  cd ~/Desktop/e203_hbirdv2/vsim/install && \
  iverilog -Wall -g2005-sv -D DISABLE_SV_ASSERTION=1 -D FPGA_SOURCE \
    -I rtl/core -I rtl/perips -I rtl/soc -I rtl/subsys \
    -I rtl/mems -I rtl/debug -I rtl/fab -I rtl/general \
    -I rtl/perips/apb_uart -I rtl/perips/apb_gpio \
    -I rtl/perips/apb_spi_master -I rtl/perips/apb_adv_timer \
    -I rtl/perips/apb_i2c \
    -s tb_e203_nice_light -o ../sim_fullsoc_nice \
    \$(find rtl -name '*.v' | sort) \
    tb/tb_e203_nice_light.v tb/tb_timing.v tb/tb_top.v && \
  cd .. && timeout 60 vvp sim_fullsoc_nice
"
```

**Expected output:** `[LIGHT_PASS]` with `pass_count=7 fail=0`.

## Stage 3: Build cnn_accel_demo Software

```powershell
powershell -NoProfile -ExecutionPolicy Bypass \
  -File "C:\Users\16084\Documents\New project\riscv_cnn_accelerator\scripts\Build-CnnAccelDemo.ps1"
```

**Expected output:** `CNN_ACCEL_DEMO_ELF=.../cnn_accel_demo.elf`, 64-bit ITCM conversion done.

## Stage 4: Build cnn_sysclk_ila Bitstream

```powershell
powershell -NoProfile -ExecutionPolicy Bypass \
  -File "C:\Users\16084\Documents\New project\riscv_cnn_accelerator\scripts\Invoke-Vivado-Fpga.ps1" \
  -BuildMode cnn_sysclk_ila -Action bit
```

**Expected output:** `write_bitstream completed`, WNS > 12ns, WHS > 0.05ns, 0 failing endpoints.

## Stage 5: Program FPGA + ILA Capture

```powershell
powershell -NoProfile -ExecutionPolicy Bypass \
  -File "C:\Users\16084\Documents\New project\riscv_cnn_accelerator\scripts\Capture-Vivado-Ila.ps1" \
  -BitFile "C:\Users\16084\Documents\Graduation_Design_Library\04_Experiments\Board_BringUp\2026-04-28_board_connection_check\cnn_sysclk_ila_artifacts\system.bit" \
  -ProbesFile "C:\Users\16084\Documents\Graduation_Design_Library\04_Experiments\Board_BringUp\2026-04-28_board_connection_check\cnn_sysclk_ila_artifacts\system.ltx" \
  -OutputDir "C:\Users\16084\Documents\Graduation_Design_Library\04_Experiments\Board_BringUp\2026-04-28_board_connection_check\cnn_sysclk_ila_ila_capture"
```

## Stage 6: Verify UART Output

Open PuTTY: **COM11, 115200 baud, 8 data bits, 1 stop bit, no parity, no flow control.**

Press board RESET. Expected output:

```
cnn_accel_demo: boot
Kernel: 3x3 INT8, Input: 4x4 INT8, Output: 2x2
ReLU: on
CPU reference done, cycles=1516
Accelerator done, cycles=287
SW output: 12 23 0 19
HW output: 12 23 0 19
Expected : 12 23 0 19
Speedup: 5.282 x
>>> CNN v1 DEMO PASSED <<<
```

## Evidence Map

| Stage | Evidence File |
|-------|--------------|
| RTL Sim | `04_Experiments/RTL_Simulation/.../rtl_sim_results.txt` |
| Full-SoC Sim | `04_Experiments/FullSoC_Simulation/.../fullsoc_sim_results.txt` |
| hello_e203 Board | `04_Experiments/.../hello_e203_board_artifacts/` |
| CNN Bitstream | `04_Experiments/.../cnn_sysclk_ila_artifacts/system.bit` |
| CNN ILA | `04_Experiments/.../cnn_sysclk_ila_ila_capture/ila_capture.csv` |
| CNN UART | `04_Experiments/.../cnn_sysclk_ila_ila_capture/uart_output.txt` |
| Timing | `04_Experiments/.../cnn_sysclk_ila_artifacts/system_timing_summary_routed.rpt` |
