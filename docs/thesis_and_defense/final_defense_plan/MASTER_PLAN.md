# 2026-04-28 To Final Defense Master Plan

## Current Status

This plan starts from the current graduation design baseline on 2026-04-28.

- RTL/NICE local regression has passed.
- full-SoC SDK simulation has passed with `expected_rstat=19`.
- Davinci Pro A7-100T bitstream and JTAG programming path have been prepared.
- The open engineering item is board-level runtime evidence: UART, LED, ILA, and the soft-core debug path.

## Overall Goal

Finish the project with one consistent evidence chain:

`RTL_PASS -> full-SoC PASS -> hello_e203 board run -> cnn_accel_demo board evidence -> final defense`

## Phase 1: Current Engineering Freeze

- Date: 2026-04-28 to 2026-04-30
- Goal: Freeze the current truth before board-side work continues.
- Tasks:
  - Record active branches and commits.
  - Reconfirm the RTL and full-SoC baseline if Ubuntu is available.
  - Confirm Vivado can still see `xc7a100t_0`.
  - Prepare a current evidence index.
- Output:
  - current status table
  - evidence index
  - risk list
- Success criteria:
  - branch pair is still `codex/a7-bringup-v2-main` and `codex/a7-bringup-v2-soc`
  - simulation evidence remains explainable
  - board-side open items are clearly separated from completed simulation work

## Phase 2: Minimal E203v2 Board Runtime Closure

- Date: 2026-05-01 to 2026-05-05
- Goal: Prove that the E203v2 soft-core can boot a pre-initialized program from the bitstream and print through UART.
- Tasks:
  - Build a minimal `hello_e203` bare-metal app.
  - Generate ELF, Verilog image, ITCM image, and DTCM image.
  - Rebuild `system.bit` with the hello image.
  - Program the FPGA through Vivado.
  - Capture UART, LED, and ILA evidence.
- Output:
  - UART hello screenshot
  - LED status record
  - ILA PC activity screenshot
- Success criteria:
  - UART prints hello or staged boot messages
  - LED reaches the expected stage
  - ILA shows PC changing after reset release

## Phase 3: CNN/NICE Board Validation Closure

- Date: 2026-05-06 to 2026-05-12
- Goal: Run `cnn_accel_demo` on board and collect software/hardware comparison evidence.
- Tasks:
  - Rebuild `cnn_accel_demo.elf`.
  - Generate `cnn_accel_demo.verilog`, `.itcm.verilog`, and `.dtcm.verilog`.
  - Rebuild `system.bit` with the CNN demo image.
  - Capture UART software baseline output.
  - Capture accelerator output.
  - Record cycle count and speedup.
  - Capture ILA NICE handshake evidence.
- Output:
  - UART result screenshot
  - ILA NICE handshake screenshot
  - benchmark table
- Success criteria:
  - software and hardware outputs match
  - `SDK app check passed` appears
  - cycle summary is visible
  - ILA shows NICE request/response or CSR activity

## Phase 4: Thesis Main Writing

- Date: 2026-05-01 to 2026-05-18
- Goal: Complete the thesis draft around the same engineering evidence chain.
- Tasks:
  - Finish Introduction and Related Work.
  - Write System Architecture.
  - Write RTL/NICE design and verification.
  - Write full-SoC SDK integration.
  - Write FPGA bring-up and soft-core debug blocker.
  - Prepare figures and references.
- Output:
  - thesis draft
  - reference table
  - figure list
- Success criteria:
  - thesis does not overstate board progress
  - every technical claim maps to a command, screenshot, waveform, branch, or official reference

## Phase 5: Final Defense Package

- Date: 2026-05-12 to 2026-05-24
- Goal: Prepare the final defense deck, script, QA, and evidence package.
- Tasks:
  - Build final PPT.
  - Write per-page speaker notes.
  - Prepare practical QA.
  - Prepare evidence package.
  - Rehearse 8 to 12 minute version.
  - Prepare a 3 minute short version.
- Output:
  - final PPT
  - final script
  - QA document
  - evidence package
- Success criteria:
  - the presentation can explain what is completed and what remains open
  - evidence supports RTL, full-SoC, board runtime attempt, and debug blocker status

## Fixed Reporting Statement

The project has closed the RTL/NICE and full-SoC simulation baselines. The next work is to close board-level runtime evidence on Davinci Pro A7-100T through UART, LED, and ILA, while keeping the soft-core debug path as the main remaining blocker.

