# Thesis Task Board

## Current Priority

Start the thesis in parallel with weekly development. The first draft should be evidence-driven, not perfect.

## Week 1: Thesis Skeleton and Literature

- Status: Not started
- Goal: Build the thesis outline and collect core references.
- Tasks:
  - Create final chapter outline.
  - Collect RISC-V, E203/NICE, CNN accelerator, FPGA accelerator, and OpenOCD/GDB references.
  - Write the first version of Chapter 1 and Chapter 2 notes.
- Output:
  - Chapter outline
  - reference list
  - related work summary table

## Week 2: Architecture and RTL Chapter

- Status: Not started
- Goal: Explain the system and RTL work clearly.
- Tasks:
  - Draw system architecture diagram.
  - Explain NICE request/response path.
  - Explain CNN accelerator PE/PE array/controller.
  - Use `run_hw` evidence to support RTL verification.
- Output:
  - Chapter 3 draft
  - Chapter 4 draft
  - RTL evidence figure list

## Week 3: Full-SoC and FPGA Chapter

- Status: Not started
- Goal: Explain SDK/full-SoC integration and board bring-up status.
- Tasks:
  - Explain SDK build and image split.
  - Explain full-SoC simulation.
  - Explain Davinci Pro A7-100T board preparation.
  - Write the soft-core debug blocker honestly.
- Output:
  - Chapter 5 draft
  - Chapter 6 draft
  - full-SoC evidence figure list

## Week 4: Full Draft and Revision

- Status: Not started
- Goal: Connect all chapters into one thesis draft.
- Tasks:
  - Complete conclusion and future work.
  - Check figures, citations, and terminology.
  - Align thesis wording with the final defense story.
- Output:
  - full thesis draft
  - missing evidence list
  - advisor review version

## Fixed Technical Claims

- RTL/NICE local simulation has passed.
- Full-SoC simulation has passed with `expected_rstat=19`.
- Board-level software debug remains open.
- The current blocker is the soft-core debug path, not the RTL algorithm path.

