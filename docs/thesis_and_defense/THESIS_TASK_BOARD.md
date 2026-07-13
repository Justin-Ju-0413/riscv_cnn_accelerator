# Thesis Task Board

## Current Priority

Continue final thesis cleanup for the 华工 SCUT v8 submission package. The user
clarified on 2026-05-22 that the intended thesis is the SCUT v8 version under
`../../../graduation-design-library/13_SCUT_Submission_Package/`, not the
CityU/FYP LaTeX thesis. Current work is consistency, render/export, and
submission-package alignment.

## Week 1: Thesis Skeleton and Literature

- Status: Completed
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

- Status: Completed
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

- Status: Completed
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

- Status: In progress
- Goal: Connect all chapters into one thesis draft.
- Tasks:
  - Complete conclusion and future work.
  - Check figures, citations, and terminology.
  - Align thesis wording with the final defense story.
- Output:
  - current SCUT v8 submission DOCX candidate:
    `../../../graduation-design-library/13_SCUT_Submission_Package/SCUT_本科毕业设计论文_巨嘉兴_格式修订版_v8_去AI化处理版.docx`
  - current SCUT v8 rendered PDF:
    `../../../graduation-design-library/13_SCUT_Submission_Package/SCUT_本科毕业设计论文_巨嘉兴_格式修订版_v8_去AI化处理版.pdf`
  - SCUT v8 render QA:
    `../../../tmp/scut_v8_quai_render/`
  - thesis progress summary:
    `../../../graduation-design-library/03_Documents/Thesis_Materials/THESIS_PROGRESS_SUMMARY_2026-05-22.md`
- Current note:
  - SCUT v8 去AI版 DOCX rendered successfully on macOS; LibreOffice output is
    39 A4 pages.
  - Spot-check confirmed the cover has `微电子学院` and `杨文`.
  - The separate `thesis_latex/` pipeline was repaired earlier, but it is not
    the current SCUT v8 thesis stream. Do not use `main_final.pdf` or
    `FYP_FINAL.docx` as the 华工 v8 final thesis unless the user explicitly asks
    to migrate content between versions.

## Fixed Technical Claims

- RTL/NICE local simulation has passed.
- Full-SoC simulation has passed with `expected_rstat=19`.
- Board-level software debug remains open.
- The current blocker is the soft-core debug path, not the RTL algorithm path.
- FPGA board evidence supports a 10-image sample demonstration; full MNIST
  accuracy must remain scoped to the Python/reference-model validation flow.
- `5.282x` must remain scoped to the current 3x3 convolution-kernel cycle test,
  not full LeNet-5 end-to-end acceleration.
