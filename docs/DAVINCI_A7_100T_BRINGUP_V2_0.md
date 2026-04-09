# Davinci Pro A7-100T Bring-Up V2.0

> Version: `V2.0`  
> Updated: `2026-04-10`

## Scope

This document captures the currently verified A7-100T board bring-up state
after the first Route A implementation pass.

The near-term target is no longer "GDB first". The active priority is:

1. prove `cnn_accel_demo` really runs on the board
2. collect UART, LED, and ILA evidence
3. keep `PTD04 + BSCANE2` as a later debug-chain research track

## Verified Facts

- Board target: `davinci_a7_100t`
- FPGA part: `xc7a100tfgg484-2`
- Board clock pin: `sys_clk -> R4`
- Board reset pin: `sys_rst_n -> U7`
- UART pins:
  - `uart_rxd -> E14`
  - `uart_txd -> D17`
- Soft-JTAG GPIO pins:
  - `mcu_TCK -> D16`
  - `mcu_TMS -> E13`
  - `mcu_TDI -> E16`
  - `mcu_TDO -> F14`
- LED0 pin:
  - `led0 -> V9`
  - official bank voltage requires `LVCMOS15`

## What Is Already Working

### Software

Fresh software artifacts have been rebuilt successfully:

- `third_party/nuclei-sdk/application/baremetal/cnn_accel_demo/cnn_accel_demo.elf`
- `third_party/nuclei-sdk/application/baremetal/cnn_accel_demo/cnn_accel_demo.verilog`
- `third_party/nuclei-sdk/application/baremetal/cnn_accel_demo/cnn_accel_demo.itcm.verilog`
- `third_party/nuclei-sdk/application/baremetal/cnn_accel_demo/cnn_accel_demo.dtcm.verilog`

`sw/sdk_project/nuclei_app/main.c` now emits fixed UART milestones:

- `boot`
- `main`
- `accel cfg`
- `start`
- `done`
- `result`

### FPGA

The A7-100T shell now builds a fresh bitstream with Route A changes included:

- `E:\riscv-workspace\repos\e203_hbirdv2\fpga\davinci_a7_100t\obj\system.bit`

This bitstream now includes:

- program image pre-initialized into ITCM/DTCM
- UART runtime milestones
- LED0 stage indication
- a runtime ILA for CPU and NICE activity

### Hardware Download

`PTD04 + Vivado Hardware Manager` has already been confirmed to:

- see the board's `xc7a100t`
- program FPGA bitstreams successfully

## Current Route A Design

### Program Delivery

`cnn_accel_demo.verilog` is split by `tb/split_sdk_verilog.sh`, then consumed by
the FPGA install flow as:

- `cnn_accel_demo.itcm.verilog`
- `cnn_accel_demo.dtcm.verilog`

The FPGA memory wrappers now load these images during synthesis.

### Runtime Observability

Three independent observation paths are now prepared:

1. UART
2. LED0
3. Vivado ILA

Current ILA probe groups include:

- PC progression
- memory command/response activity
- NICE CSR write phase
- NICE request/response handshake
- core status bits

## Current Blockers

The current blocker is no longer bitstream generation.

The next blockers are board evidence collection tasks:

- lock the actual UART COM port on Windows
- verify UART stage prints on real hardware
- arm ILA and confirm CPU forward progress plus NICE handshake activity
- confirm LED0 reaches the later software stage

## Route B Status

`PTD04` is currently confirmed only for FPGA native JTAG download.

Two later CPU-debug options remain:

1. add `BSCANE2` and bridge the Xilinx JTAG chain into the CPU debug path
2. use a separate OpenOCD-compatible soft-JTAG adapter

Route B is not allowed to block Route A evidence collection this week.

## Immediate Next Steps

1. Reprogram the board with the latest `system.bit`
2. Connect board UART and identify the Windows COM port
3. Capture the UART milestones
4. Use Vivado Hardware Manager to arm and inspect the ILA
5. Confirm whether execution reaches `done` and `result`
