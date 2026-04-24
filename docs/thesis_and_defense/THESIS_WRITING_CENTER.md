# Thesis Writing Center

This folder is the main workspace for the graduation thesis.

## Writing Goal

The thesis should describe one clear engineering story:

RISC-V E203 soft-core + NICE custom instruction interface + CNN accelerator + RTL simulation + full-SoC verification + FPGA bring-up preparation.

The current honest status is:

- RTL/NICE local simulation is closed.
- SDK build and full-SoC simulation are closed.
- Davinci Pro A7-100T board programming environment has been prepared.
- Soft-core software debug on board is still the main blocker.

## Suggested Chapter Structure

1. Introduction
   - Background of CNN acceleration and RISC-V extensibility.
   - Project goal and engineering scope.
   - Main contribution: an integrated and reproducible RISC-V CNN accelerator flow.

2. Related Work
   - CNN accelerator architectures.
   - FPGA-based neural network acceleration.
   - RISC-V custom instruction and coprocessor approaches.
   - E203/NICE-based embedded SoC development.

3. System Architecture
   - E203 processor and SoC baseline.
   - NICE instruction path.
   - CNN accelerator top-level structure.
   - Software and hardware interaction flow.

4. RTL Design and Verification
   - PE and PE array design.
   - CNN NICE core behavior.
   - Controller and instruction decoding.
   - Local RTL regression evidence: `[TB_PASS]`, normal path result `320`, error handling cases.

5. Full-SoC Integration and Verification
   - SDK application build.
   - ITCM/DTCM image split.
   - Full-SoC simulation flow.
   - Key evidence: `expected_rstat=19` and `[PHASE4_PASS]`.

6. FPGA Bring-Up and Debug
   - Davinci Pro A7-100T environment.
   - Vivado/programming preparation.
   - Current soft-core debug blocker.
   - PTD04 programming status and OpenOCD/GDB limitation.

7. Conclusion and Future Work
   - Completed simulation and integration baseline.
   - Remaining board-level debug work.
   - Possible improvements: debug bridge, UART/LED/ILA evidence, performance evaluation.

## Daily Writing Rule

- Write from existing evidence first.
- Do not overstate board-level progress.
- Every technical claim should map to one of these evidence types:
  - command result
  - waveform or screenshot
  - source branch and commit
  - design diagram
  - official specification or paper

## Main Inputs

- `..\01_Project_Overview`
- `..\02_Source_Repos`
- `..\04_Experiments`
- `..\05_Presentation`
- `..\06_References`

