# Formal E203 Integration

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## Goal

Define which files and flows now represent the formal CNN-to-E203 integration,
and separate them from bring-up-only diagnostics.

## Formal Integration Boundary

The formal SoC-side integration is now the official `e203_hbirdv2` NICE path:

- CPU/NICE path terminates at:
  - [e203_subsys_nice_core.v](${SOC_DIR}/rtl/e203/subsys/e203_subsys_nice_core.v)
- CNN accelerator implementation lives at:
  - [cnn_nice_core.v](${SOC_DIR}/rtl/e203/subsys/cnn_nice_core.v)

This means the CNN accelerator is not attached through an external patch shim at runtime.
It is instantiated directly in the official subsystem NICE integration module.

## Formal Integration Files

Official SoC repository files that now define the integrated path:

- [e203_subsys_nice_core.v](${SOC_DIR}/rtl/e203/subsys/e203_subsys_nice_core.v)
  - formal subsystem boundary between E203 NICE and the CNN co-unit
- [cnn_nice_core.v](${SOC_DIR}/rtl/e203/subsys/cnn_nice_core.v)
  - integrated accelerator RTL used by the official SoC path
- [tb_top.v](${SOC_DIR}/tb/tb_top.v)
  - full-SoC observability and ITCM/DTCM image loading support
- [run_nice_light.sh](${SOC_DIR}/tb/run_nice_light.sh)
  - official lightweight regression entry for NICE-path checks
- [run_nice_patch.sh](${SOC_DIR}/vsim/run_nice_patch.sh)
  - official full-SoC simulation wrapper used by the software-driven flow
- [split_sdk_verilog.sh](${SOC_DIR}/tb/split_sdk_verilog.sh)
  - image preparation helper for SDK-generated `.verilog` payloads

Project repository files that define the portable integration baseline:

- [cnn_nice_core.v](../hw/rtl/acc/cnn_nice_core.v)
  - project-local accelerator RTL mirror
- [e203_cnn_nice_soc_wrap.v](../hw/rtl/soc_wrapper/e203_cnn_nice_soc_wrap.v)
  - project-local reference wrapper for the intended SoC hookup shape
- [run_sdk_fullsoc_regression.sh](../scripts/run_sdk_fullsoc_regression.sh)
  - portable software-driven full-SoC regression entry
- [run_preboard_verification.sh](../scripts/run_preboard_verification.sh)
  - one-command pre-board verification gate
- [nuclei-sdk-phase3-e203-safe.patch](../patches/nuclei-sdk-phase3-e203-safe.patch)
  - portable export of the local SDK startup/demo adjustments

## Bring-Up Or Diagnostic Files

These files are still useful, but they are not the formal SoC integration boundary:

- [tb_cpu_mock.v](../hw/tb/tb_cpu_mock.v)
  - local regression testbench for accelerator protocol behavior
- [e203_nice_harness.v](../hw/tb/e203_nice_harness.v)
  - local harness for project-side RTL simulation
- [run_nice_patch.sh](${SOC_DIR}/vsim/run_nice_patch.sh)
  - still a diagnostic wrapper even though it is part of the official full-SoC simulation flow
- plusarg-based observability in [tb_top.v](${SOC_DIR}/tb/tb_top.v)
  - useful for debug, not part of the hardware product boundary

## Current Locked Integration Scope

The formally validated integration scope is still limited to:

- request/response-only NICE operation
- no active ICB memory fetch path
- operand loading through `WLOAD/DLOAD`
- software-issued `CLEAR/WLOAD/DLOAD/COMP/RSTAT`
- final result readback through `RSTAT`

This is already a valid formal integration state for the current project version.
It is not yet the final board product state.

## What Counts As Done Before FPGA Work

Before moving into Vivado/FPGA engineering, the integration should be treated as
formally complete when all of the following stay true:

- the official subsystem still instantiates `cnn_nice_core` directly
- the project-side RTL mirror stays behaviorally aligned with the SoC-side copy
- [run_preboard_verification.sh](../scripts/run_preboard_verification.sh) passes
- the software-driven full-SoC flow still reaches `RSTAT=320`

## What Still Belongs To The Next Stage

These are not integration-definition tasks anymore. They belong to later FPGA or
board work:

- Vivado project hookup
- FPGA top-level clock/reset wiring
- memory/IP replacement or inference issues under Vivado
- bitstream generation
- OpenOCD attach to real hardware
- UART log capture from the board

## Recommended Next Step

With the formal integration boundary now explicit, the next useful task is to
prepare the Vivado/FPGA handoff inputs:

- identify the expected FPGA top module
- identify clock/reset assumptions
- identify memory initialization strategy
- identify which SoC files must enter the Vivado project unchanged
