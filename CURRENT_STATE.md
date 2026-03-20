# Current State

## Purpose

Single compressed state file for session recovery and low-overhead context
loading.

## Goal

Integrate the CNN NICE accelerator into `e203_hbirdv2` completely and safely.

## Version

- Current version: `V1.6`

## Active Phase

- Phase: `Phase 3`
- Objective: start software-path closure on top of the locked `V1.6` safety
  baseline

## Repositories

- Main repo:
  - path: `/home/gstar/Desktop/riscv_cnn_accelerator`
  - branch: `bringup_v1`
  - head: `6f3e9e2`
- SoC repo:
  - path: `/home/gstar/Desktop/e203_hbirdv2`
  - branch: `cnn_bringup_v1`
  - head: `efb46d7`
  - remotes:
    - `origin` -> `git@github.com:Justin-Ju-0413/e203_hbirdv2.git`
    - `upstream` -> `https://github.com/riscv-mcu/e203_hbirdv2.git`

## Verified

- Main project checks pass:
  - `./Project_Manager.sh gen_model`
  - `./Project_Manager.sh run_hw`
  - `./Project_Manager.sh precheck`
- Official full-SoC simulator baseline is now aligned with repo guidance:
  - local `iverilog` upgraded to `12.0`
  - direct official `vvp.exec` runs now advance into the patch window
- Full-SoC environment fixes are in place:
  - stable `vsim` path handling
  - no empty `+PATCHCASE=`
  - ASCII-path-only rule for official `iverilog/vvp`
- Lightweight official-chain smoke test passes:
  - official `e203_exu_nice -> e203_subsys_nice_core -> cnn_nice_core` path
  - `req_ready` low while busy
  - `RSTAT=320`
- Phase 2 mock-harness safety checks now pass under the corrected official NICE
  encoding:
  - `normal_path`
  - `negative_values`
  - `boundary_values`
  - `invalid_index`
  - `comp_without_full_load`
  - `rstat_without_comp`
  - `busy_blocks_new_req`
  - `rstat_repeat_read`
  - `illegal_funct7`
  - `illegal_opcode`
  - `reset_clears_state`
- The official lightweight chain now also covers selected Phase 2 cases:
  - repeated `RSTAT`
  - invalid load index
  - `COMP` before full load
  - illegal `funct7`
  - illegal opcode
  - reset clears state
- Real integration bug fixed:
  - `cnn_nice_core` now latches `load_data_q` and `load_vec_sel_q`
  - fix mirrored to both repos

## Phase 2 Result

- Phase 2 is complete on the current request/response-only NICE scope.
- The integration now has:
  - Phase 1 full-SoC closure
  - Phase 2 mock-harness safety coverage
  - Phase 2 official lightweight-chain safety coverage
- No new RTL blocker was found while closing Phase 2.

## Execution Entry Points

- Fast gate:
  - [run_nice_light.sh](/home/gstar/Desktop/e203_hbirdv2/tb/run_nice_light.sh)
  - `bash /home/gstar/Desktop/e203_hbirdv2/tb/run_nice_light.sh`
- Full-SoC wrapper:
  - [run_nice_patch.sh](/home/gstar/Desktop/e203_hbirdv2/vsim/run_nice_patch.sh)
  - `bash /home/gstar/Desktop/e203_hbirdv2/vsim/run_nice_patch.sh`
  - default testcase is now the smaller `rv32ui-p-simple`

## Key Files

- Main RTL fix:
  - [cnn_nice_core.v](/home/gstar/Desktop/riscv_cnn_accelerator/hw/rtl/acc/cnn_nice_core.v)
- SoC RTL fix:
  - [cnn_nice_core.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/cnn_nice_core.v)
- SoC integration wrapper:
  - [e203_subsys_nice_core.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/e203_subsys_nice_core.v)
- Full-SoC observability:
  - [tb_top.v](/home/gstar/Desktop/e203_hbirdv2/tb/tb_top.v)
- Overlay program:
  - [nice_dot320_patch.verilog](/home/gstar/Desktop/e203_hbirdv2/tb/nice_dot320_patch.verilog)

## Next Focus

- Keep `run_nice_light.sh` as the fast regression gate.
- Keep `run_nice_patch.sh` as the official full-SoC diagnostic entry.
- Move into software-path closure:
  - install/verify the Nuclei software build path
  - drive `CLEAR/WLOAD/DLOAD/COMP/RSTAT` from software instead of TB-only flows
  - compare hardware-visible results against `sw_reference_dot()`

## Compression Rules

- Read this file first in future sessions.
- Read `INTEGRATION_ROADMAP.md` only for long-range planning.
- Read `PROGRESS.md` only for dated history.
- Avoid loading multiple large docs unless the task explicitly needs them.
