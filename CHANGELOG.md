# Changelog

All notable project updates are recorded here.

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
