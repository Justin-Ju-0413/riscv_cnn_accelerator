# Integration Roadmap

## Goal

Integrate the CNN NICE accelerator into `e203_hbirdv2` completely and safely,
with a flow that is reproducible across devices and maintainable across future
iterations.

## Document Roles

- `INTEGRATION_ROADMAP.md`: long-range phases and exit criteria
- `CURRENT_STATE.md`: compressed current snapshot, execution entry points, and
  latest conclusions
- `PROGRESS.md`: dated progress log only

## Repository Roles

- `riscv_cnn_accelerator`: main project for algorithm, RTL, verification,
  software scaffolding, and planning docs
- `e203_hbirdv2` fork: official SoC integration workspace for actual E203
  source modifications and bring-up verification

## Phase Overview

### Phase 1: SoC Minimum Closure

Goal:
- Prove the official `e203_hbirdv2` NICE integration path works end-to-end.

Exit criteria:
- The official SoC path can reproducibly show:
  - `NICE_REQ`
  - `req_ready` low while busy
  - `RSTAT=320`

### Phase 2: Interface Safety Validation

Goal:
- Prove the integration is controlled, not just accidentally functional.

Exit criteria:
- NICE timing, reset behavior, and error paths are checked in SoC context.

### Phase 3: Software Path Closure

Goal:
- Replace testbench-only triggering with a software-driven flow.

Exit criteria:
- Software can drive `CLEAR/WLOAD/DLOAD/COMP/RSTAT` and compare against
  `sw_reference_dot()`.

### Phase 4: Project Engineering Cleanup

Goal:
- Make the project easier to maintain, transfer, and report.

Exit criteria:
- Another machine or collaborator can recover the current state with minimal
  ambiguity.

### Phase 5: Board Bring-Up Preparation

Goal:
- Prepare for later hardware board validation.

Exit criteria:
- Dependencies, debug hooks, and simulation-to-board gaps are clearly defined.

## Current Phase Focus

- Active phase: `Phase 5`
- Current detailed status and execution flow: see
  [CURRENT_STATE.md](/home/gstar/Desktop/riscv_cnn_accelerator/CURRENT_STATE.md)
- Phase 5 board-prep entry for this phase: see
  [PHASE5_BOARD_PREP.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE5_BOARD_PREP.md)
- Recovery/regression baseline inherited from Phase 4: see
  [PHASE4_RECOVERY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE4_RECOVERY.md)

## Collaboration Rule

After each completed task:

1. Update [PROGRESS.md](/home/gstar/Desktop/riscv_cnn_accelerator/PROGRESS.md).
2. Commit the milestone to the relevant repository when we are ready to save it.
3. Revisit this roadmap and select the next smallest useful step.
