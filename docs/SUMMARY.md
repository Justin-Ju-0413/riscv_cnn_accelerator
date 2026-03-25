# Work Delivery Summary

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## Latest Document Package

Date: 2026-03-26

Version: V1.9

What was updated:

- Added a phase-organized project history document.
- Added a standing collaboration rules file for future user requirements.
- Unified the core documentation set under one version.
- Reorganized summary, current-state, index, and quick-start responsibilities.

Affected docs:

- `SUMMARY.md`
- `CURRENT_STATE.md`
- `PHASE_HISTORY.md`
- `PROJECT_INDEX.md`
- `PROJECT_RULES.md`
- `PROGRESS.md`
- `QUICKSTART.md`

## Current Delivery Status

**Branch**: `bringup_v1`

The project has advanced from a NICE dot-product closure baseline to a minimal
CNN v1 delivery baseline with board-prep automation and clearer documentation
structure.

## Delivered Technical Scope

### RTL And Interface

- 16-lane INT8 NICE compute path is stable.
- `CLEAR/WLOAD/DLOAD/COMP/RSTAT` remains the locked software-visible command set.
- `CFG` support for hardware ReLU is documented in the current delivery baseline.
- Interface safety coverage includes reset, invalid command, invalid index,
  busy-time blocking, and repeated `RSTAT`.

### Software And SoC

- SDK app, firmware, and demo path are aligned to the current minimal CNN v1 flow.
- Python golden, software reference, and SoC-visible data flow have been aligned.
- CPU-only and accelerator-visible comparison output are integrated into the
  current software baseline.

### Board-Prep Automation

- Full pre-board verification is scripted.
- Board environment checking is scripted.
- First-run FPGA command printing is scripted.
- Vivado/FPGA handoff boundaries are documented for the next stage.

## Current Verification Conclusion

The following gates are documented as passing on the current delivery baseline:

- `./Project_Manager.sh run_hw`
- `bash scripts/run_sdk_fullsoc_regression.sh`
- `bash scripts/run_preboard_verification.sh`
- `bash scripts/check_phase5_board_env.sh`

Current result baselines:

- Historical software-driven SoC closure: `RSTAT=320`
- Current minimal CNN v1 flow: `expected_rstat = 19`

## Current Remaining Gaps

The project is no longer blocked on RTL or SoC integration. The remaining work
is board-facing:

- `vivado` is not yet confirmed on this machine
- FTDI/JTAG hardware is not yet visible
- `SERIAL_DEV` is not yet locked
- the real board target is not yet finally confirmed
- no bitstream-backed board run has been closed

## Recommended Reading

- Start with [QUICKSTART.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/QUICKSTART.md)
- Read [CURRENT_STATE.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/CURRENT_STATE.md) for current truth
- Read [PHASE_HISTORY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE_HISTORY.md) for project history by phase
- Read [PROJECT_RULES.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PROJECT_RULES.md) for standing requirements
