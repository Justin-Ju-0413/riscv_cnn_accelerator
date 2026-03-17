# Integration Decision Matrix

Use this file to lock down decisions before wiring the accelerator into a real
Hummingbird E203 v2 codebase and before enabling the Nuclei SDK build flow.

## 1. E203 Source Baseline
Status: pending

- Decision: choose the exact `e203_hbirdv2` repository/tag/branch.
- Why it matters: NICE port lists, optional sideband signals, and BSP names can
  differ across branches or vendor snapshots.
- Current recommendation: freeze a single upstream baseline before any SoC edits.
- Record here:
  - Repository URL:
  - Branch or tag:
  - Commit hash:

## 2. Board / SoC Target
Status: pending

- Decision: select the real target board or simulation SoC variant.
- Why it matters: startup files, linker scripts, memory map, and SDK board
  configuration depend on this choice.
- Current recommendation: choose one primary bring-up target first.
- Record here:
  - Board / target name:
  - Clock assumptions:
  - Memory map source:

## 3. Operand Delivery Path
Status: pending

- Option A: register-fed NICE instructions
  - Pros: simplest bring-up, easiest debug, minimal RTL churn
  - Cons: poor bandwidth scaling for larger tensors
- Option B: NICE ICB memory fetches
  - Pros: scalable data movement model, closer to real accelerator use
  - Cons: requires command/rsp sequencing, memory protection, and more RTL
- Current recommendation: start with Option A for first silicon-quality hookup,
  then move to Option B only after SoC integration is stable.
- Record here:
  - Chosen option:
  - Reason:

## 4. Firmware Loading Flow
Status: pending

- Option A: simulation-preloaded memory
- Option B: on-chip SRAM execution
- Option C: FPGA image / flash-based load path
- Current recommendation: simulation-preloaded memory first, then SRAM, then FPGA.
- Record here:
  - Chosen first-step flow:
  - Follow-up flow:

## 5. Illegal Instruction Policy
Status: partially prepared

- Current repo behavior:
  - unsupported opcode -> `nice_rsp_err=1`
  - unsupported `funct3` -> `nice_rsp_err=1`
- Decision still required:
  - whether the SoC integration expects trapping behavior elsewhere
  - whether bounds checks on `rs2[1:0]` should be silent-ignore or error-return
- Current recommendation: preserve explicit `nice_rsp_err` signaling and align
  final trap behavior with the selected E203 baseline.
- Record here:
  - Final policy:
  - Owner module:

## 6. SDK Toolchain Triplet
Status: pending

- Decision: confirm the exact cross-toolchain prefix delivered with the chosen SDK.
- Current placeholder: `riscv64-unknown-elf-`
- Record here:
  - Toolchain prefix:
  - GCC version:

## Exit Criterion
This file is ready when every `Status: pending` section has concrete values.
