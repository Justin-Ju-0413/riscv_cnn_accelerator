# Phase History

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## Purpose

This is the phase-organized history of the CNN accelerator project. It is the
main entry for understanding what was completed in each phase and what evidence
closed that phase.

## Phase 1: SoC Minimum Closure

**Goal**

Prove the official `e203_hbirdv2` NICE integration path works end-to-end.

**Completed work**

- Integrated the CNN NICE accelerator into the official E203 SoC path.
- Corrected the custom instruction interpretation to the E203 NICE `funct7` path.
- Established the basic request/response-only NICE integration scope.
- Closed the first full SoC functional loop around the accelerator datapath.

**Key outputs**

- Formal SoC integration baseline in the E203 fork
- Stable `CLEAR/WLOAD/DLOAD/COMP/RSTAT` command path
- Early delivery and integration documents

**Validation**

- Full SoC flow can reproducibly observe NICE activity.
- Historical closure result recorded as `RSTAT=320`.

**Phase result**

Phase 1 proved the accelerator was not just locally correct, but actually wired
into the official E203 SoC path.

## Phase 2: Interface Safety Validation

**Goal**

Prove the NICE integration is controlled and protocol-safe, not merely
accidentally functional.

**Completed work**

- Added busy, result-valid, gated compute, gated `RSTAT`, and invalid-index checks.
- Expanded the mock and official lightweight regressions for error paths and reset.
- Verified repeated `RSTAT`, partial-load compute blocking, invalid opcode/funct7,
  invalid index, busy-time request blocking, and reset-clears-state behavior.

**Key outputs**

- Hardened NICE-side RTL boundary
- Expanded regression coverage in local and official lightweight environments
- Version milestone promoted to `V1.6`

**Validation**

- Interface-safety cases passed in both local and official E203-aligned flows.

**Phase result**

Phase 2 locked the accelerator/E203 protocol boundary and removed ambiguity
around legal and illegal command behavior.

## Phase 3: Software Path Closure

**Goal**

Replace testbench-driven triggering with a software-driven path through the
official SDK environment.

**Completed work**

- Restored and aligned the Nuclei SDK flow for the project.
- Added or aligned software reference and demo paths.
- Rebuilt the app and regenerated ITCM/DTCM images from the ELF.
- Verified that software can drive `CLEAR/WLOAD/DLOAD/COMP/RSTAT` end-to-end.

**Key outputs**

- `cnn_accel_demo` software path
- Reproducible full-SoC regression entry
- Software-driven closure result `RSTAT=320`

**Validation**

- The official full-SoC E203 simulation executes the command sequence from
  software and reaches the expected result.

**Phase result**

Phase 3 closed the gap between hardware-only validation and real software-driven
execution on the E203 SoC platform.

## Phase 4: Project Engineering Cleanup

**Goal**

Make the validated baseline recoverable, transferable, and easier to continue
on another machine or by another collaborator.

**Completed work**

- Exported the nested `nuclei-sdk` delta into a portable patch.
- Added a one-command SDK-to-full-SoC regression flow.
- Documented the recovery procedure and collaboration baseline.
- Consolidated the project documents for handoff and reporting.

**Key outputs**

- [PHASE4_RECOVERY.md](PHASE4_RECOVERY.md)
- Portable SDK patch and recovery scripts
- Cleaned and more reproducible collaborator workflow

**Validation**

- Another checkout can be recovered with the documented patch and regression
  flow.
- Full-SoC regression remains the proof gate after recovery.

**Phase result**

Phase 4 converted the working baseline into an engineering artifact that can be
replayed and shared instead of relying on hidden local state.

## Phase 5: Board Bring-Up Preparation

**Goal**

Prepare the already-validated simulation flow for real FPGA board execution.

**Completed work**

- Locked the software-facing board path to `evalsoc + nuclei_fpga_eval + n300 + ilm`.
- Established board-prep scripts and environment checks.
- Installed and verified `openocd`.
- Defined the formal Vivado/FPGA handoff boundary.
- Extended the project from dot-product closure toward a minimal CNN v1 baseline.
- Added board-oriented command generation and pre-board verification flow.

**Key outputs**

- [PHASE5_BOARD_PREP.md](PHASE5_BOARD_PREP.md)
- [VIVADO_FPGA_HANDOFF.md](VIVADO_FPGA_HANDOFF.md)
- Current delivery summary and board-prep entry scripts

**Validation**

- `run_preboard_verification.sh` passes.
- `run_sdk_fullsoc_regression.sh` passes.
- `check_phase5_board_env.sh` passes with the expected missing external
  dependencies called out.
- Current minimal CNN v1 result baseline is `expected_rstat = 19`.

**Open gaps**

- Real board target still needs to be locked against actual hardware.
- `vivado` availability has not been confirmed.
- FTDI/JTAG visibility and UART path are still missing.
- No real bitstream-backed board run has been completed yet.

**Phase result**

Phase 5 has a closed pre-board software and documentation baseline, but the
project has not yet crossed the final board-execution boundary.

## Version Milestones

| Version | Meaning |
|---------|---------|
| `V1.5` | NICE encoding correction and formal SoC integration stabilization |
| `V1.6` | Interface-safety validation completed |
| `V1.7` | Phase 1-5 board-prep baseline documented |
| `V1.8` | Minimal CNN v1 delivery summary added |
| `V1.9` | Phase-organized history and collaboration rules added; core docs unified |

## How To Use This Document

- Read this file to understand project history by phase.
- Read [CURRENT_STATE.md](CURRENT_STATE.md) for the current truth.
- Read [PROGRESS.md](PROGRESS.md) for date-by-date detail.
