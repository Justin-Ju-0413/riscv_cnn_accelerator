# Changelog

All notable project updates are recorded here.

## Version V1.7

- Date: 2026-03-21
- Added:
  - a portable `nuclei-sdk` patch export for the local E203-safe startup and SDK demo changes
  - a reusable `scripts/apply_nuclei_sdk_phase3_patch.sh` helper
  - a one-command `scripts/run_sdk_fullsoc_regression.sh` recovery/regression entry
  - `docs/PHASE4_RECOVERY.md` to document collaborator recovery flow
- Changed:
  - `CURRENT_STATE.md` now points to the Phase 4 recovery entry and current pushed repo heads
  - roadmap focus moved from closed Phase 3 work into engineering cleanup
- Fixed:
  - removed the last major ambiguity around the local-only nested `nuclei-sdk` state by exporting it into the main repository
- Current blocker:
  - Phase 5 still lacks visible FTDI/JTAG hardware `0403:6010` and a locked `SERIAL_DEV` UART path on this machine; `openocd` is now installed

## Version V1.6

- Date: 2026-03-20
- Added:
  - Phase 2 safety cases are now covered in both the mock harness and the
    official lightweight E203 NICE chain
- Changed:
  - `tb_cpu_mock.v` now uses the official NICE `xspec + funct7` encoding
  - `tb_e203_nice_light.v` now checks repeated `RSTAT`, invalid load index,
    partial-load `COMP`, illegal instruction cases, and reset cleanup
- Fixed:
  - removed the stale pre-`V1.5` instruction encoding from the mock safety
    suite
  - locked a reusable Phase 2 validation baseline across both repositories
- Current blocker:
  - no Phase 2 blocker remains on the current request/response-only NICE scope

## Version V1.5

- Date: 2026-03-20
- Added:
  - official NICE encoding now documented as `xd/xs1/xs2 + funct7`
- Changed:
  - CNN NICE instruction encoding aligned with official E203 NICE semantics
  - full-SoC patch overlay rewritten to use the corrected encoding
- Fixed:
  - resolved the full-SoC `WLOAD rs2` visibility issue caused by treating
    bits `[14:12]` as `funct3`
  - restored official full-SoC `RSTAT=320`
- Current blocker:
  - no Phase 1 blocker remains for the three target observations

## Version V1.4

- Date: 2026-03-20
- Added:
  - [CURRENT_STATE.md](/home/gstar/Desktop/riscv_cnn_accelerator/CURRENT_STATE.md) as the compressed session-recovery entry
  - unified version-management rule for future pushes
- Changed:
  - document structure simplified into `CURRENT_STATE.md`, `INTEGRATION_ROADMAP.md`, and `PROGRESS.md`
  - official E203 bring-up now uses a lightweight NICE smoke test plus a full-SoC diagnostic wrapper
- Fixed:
  - synchronized `cnn_nice_core` load-data latch fix into the main RTL tree
  - aligned local simulator baseline with official `iverilog 12.0` requirement
- Current blocker:
  - official full-SoC E203/NICE path still shows stale `nice_req_rs2` during `WLOAD`
  - lightweight official NICE chain already passes `RSTAT=320`
