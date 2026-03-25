# Vivado/FPGA Handoff

> **Version**: V1.7 | **Updated**: 2026-03-24 | **Owner**: Justin JU

## Purpose

Lock the official FPGA handoff boundary for the current CNN-integrated
`e203_hbirdv2` baseline.

This document is intentionally narrower than the board bring-up plan.
It defines what Vivado/FPGA work should consume, and what should stay
unchanged from the validated SoC integration.

## Current Recommendation

Do not start FPGA work from local bring-up testbenches.

The current formal handoff path is:

- official SoC top: [e203_soc_top.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/soc/e203_soc_top.v)
- official subsystem NICE boundary:
  [e203_subsys_nice_core.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/e203_subsys_nice_core.v)
- integrated CNN co-unit RTL:
  [cnn_nice_core.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/cnn_nice_core.v)
- official FPGA board shell:
  [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/src/system.v)
  or
  [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/mcu200t/src/system.v)
  or [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/ddr200t/src/system.v)

## Handoff Structure

The FPGA design hierarchy is not just `e203_soc_top`.
The official board flow wraps the SoC with a board shell named `system`.

Current hierarchy:

1. `system`
   - board-specific FPGA wrapper
   - MMCM, reset IP, IOBUFs, package pins, JTAG pins, QSPI pins
2. `e203_soc_top`
   - official SoC top-level product boundary
   - exposes clocks, reset-related pads, JTAG pads, GPIO, QSPI, PMU pads
3. `e203_subsys_top` and below
   - E203 subsystem implementation
4. `e203_subsys_nice_core`
   - formal CNN NICE attachment point
5. `cnn_nice_core`
   - integrated accelerator implementation

## Top Module To Use In Vivado

For FPGA work, the practical board top module is `system`, not `e203_soc_top`.

Use one of these depending on the board target:

- Davinci A7-35T shell:
  [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/src/system.v)
- MCU200T shell:
  [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/mcu200t/src/system.v)
- DDR200T shell:
  [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/ddr200t/src/system.v)

The reusable SoC top under that shell is:

- [e203_soc_top.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/soc/e203_soc_top.v)

The FuseSoC-style source manifest also confirms the SoC-side top is
`e203_soc_top`:

- [e203_soc.core](/home/gstar/Desktop/e203_hbirdv2/e203_soc.core)

## Clock And Reset Assumptions

The official FPGA shell already fixes the basic clock and reset policy.
Do not invent a new one unless the board target changes.

Observed current assumptions:

- board high-speed input clock: `CLK100MHZ`
- board low-speed input clock: `CLK32768KHZ`
- FPGA shell MMCM derives `clk_16M`
- `e203_soc_top` receives `hfextclk=clk_16M`
- `e203_soc_top` receives `lfextclk=CLK32768KHZ`
- reset gating in the shell is currently `ck_rst = fpga_rst & mcu_rst`
- shell feeds `io_pads_aon_erst_n_i_ival(ck_rst)` into the SoC

Implication:

- FPGA work should preserve the current 16 MHz SoC clock assumption first
- reset behavior should stay compatible with the official shell before any tuning
- if later board timing work requires a new MMCM setup, that is an FPGA-stage
  change in `system.v`, not a SoC/NICE integration change

## Memory Initialization Strategy

Current validated software flow is simulation-first, not bitstream-first.
That means the validated image preparation path today is:

- build SDK ELF
- emit `.verilog`
- split into `.itcm` and `.dtcm`
- load memories in RTL simulation through testbench helpers

Relevant files:

- [run_sdk_fullsoc_regression.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh)
- [split_sdk_verilog.sh](/home/gstar/Desktop/e203_hbirdv2/tb/split_sdk_verilog.sh)
- [run_nice_patch.sh](/home/gstar/Desktop/e203_hbirdv2/vsim/run_nice_patch.sh)

For real FPGA work, do not assume this same memory-loading mechanism survives unchanged.
The FPGA-stage owner must choose one of these execution models explicitly:

- JTAG download of ELF during debug
- flash/QSPI boot image
- BRAM/ROM pre-initialization inside the Vivado build flow

Recommended first FPGA-stage choice:

- keep software loading out of the bitstream problem initially
- use JTAG + OpenOCD + GDB to load the ELF first
- postpone flash boot packaging until after first hardware execution works

This recommendation is consistent with the current board-prep baseline:

- [openocd_evalsoc.cfg](/home/gstar/Desktop/riscv_cnn_accelerator/third_party/nuclei-sdk/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg)

## Files That Should Enter Vivado Unchanged First

These files should be treated as the first locked baseline for Vivado import.
If FPGA work fails, prefer changing the board shell or constraints first,
not these files.

SoC integration files to keep unchanged first:

- [e203_soc_top.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/soc/e203_soc_top.v)
- [e203_subsys_top.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/e203_subsys_top.v)
- [e203_subsys_main.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/e203_subsys_main.v)
- [e203_subsys_nice_core.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/e203_subsys_nice_core.v)
- [cnn_nice_core.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/cnn_nice_core.v)

Build-manifest file to keep aligned with the RTL set:

- [e203_soc.core](/home/gstar/Desktop/e203_hbirdv2/e203_soc.core)

Board-shell files that are expected to absorb FPGA-specific work:

- [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/mcu200t/src/system.v)
- [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/src/system.v)
- [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/ddr200t/src/system.v)
- [nuclei-config.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/constrs/nuclei-config.xdc)
- [nuclei-master.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/constrs/nuclei-master.xdc)
- [nuclei-config.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/mcu200t/constrs/nuclei-config.xdc)
- [nuclei-master.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/mcu200t/constrs/nuclei-master.xdc)
- [nuclei-config.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/ddr200t/constrs/nuclei-config.xdc)
- [nuclei-master.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/ddr200t/constrs/nuclei-master.xdc)

## Official Build Entry

The official FPGA flow is already scripted.
Do not build an ad-hoc Vivado project first.

Primary entry files:

- [fpga/README.md](/home/gstar/Desktop/e203_hbirdv2/fpga/README.md)
- [common.mk](/home/gstar/Desktop/e203_hbirdv2/fpga/common.mk)
- [Makefile](/home/gstar/Desktop/e203_hbirdv2/fpga/mcu200t/Makefile)
- [Makefile](/home/gstar/Desktop/e203_hbirdv2/fpga/ddr200t/Makefile)

Observed flow shape:

1. `make install FPGA_NAME=<board>`
   - copies `rtl/e203` into an install tree
   - copies board `system.v`
   - injects `` `define FPGA_SOURCE `` into `${CORE}_defines.v`
2. `make bit FPGA_NAME=<board>`
   - runs Vivado batch flow to generate `obj/system.bit`
3. `make mcs FPGA_NAME=<board>`
   - packages `obj/system.mcs`

## What Is Already Validated Before Vivado

These points are already closed before FPGA work starts:

- local RTL regression passes
- official lightweight NICE regression passes
- SDK-driven full-SoC software path passes
- pre-board verification gate passes:
  [run_preboard_verification.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_preboard_verification.sh)
- formal CNN-to-E203 integration boundary is documented:
  [E203_FORMAL_INTEGRATION.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/E203_FORMAL_INTEGRATION.md)

## What Vivado Work Should Not Re-Decide

The FPGA stage should not reopen these already-settled decisions unless there is
new evidence of incompatibility:

- NICE instruction encoding
- request/response-only integration scope
- non-`RSTAT` completion responses
- software-visible command sequence `CLEAR/WLOAD/DLOAD/COMP/RSTAT`
- expected full-SoC result `RSTAT=320`

## Recommended Next Action

The next concrete step after this document is:

1. keep `davinci_a7_35t` as the default first shell target
2. confirm whether the real board manual requires pin or clock changes before the first bitstream attempt
3. inspect the chosen `system.v` and XDC files for any board-specific pin or clock mismatch
4. run the local shell-aware checker:
   - `bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/check_phase5_board_env.sh`
5. print the exact first-run commands:
   - `bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/print_fpga_bringup_commands.sh`
6. only then decide whether a first `make setup` or `make bit` attempt is worth doing

Until that target is locked, keep the current work at the formal integration and
pre-board verification level.
