# Current State

## Purpose

Single compressed state file for session recovery and low-overhead context
loading.

## Goal

Integrate the CNN NICE accelerator into `e203_hbirdv2` completely and safely.

## Version

- Current version: `V1.5`

## Active Phase

- Phase: `Phase 1`
- Objective: close official SoC bring-up and lock the corrected NICE encoding
- Required full-SoC observations:
  - `NICE_REQ`
  - `req_ready` low while busy
  - `RSTAT=320`

## Repositories

- Main repo:
  - path: `/home/gstar/Desktop/riscv_cnn_accelerator`
  - branch: `bringup_v1`
  - head: `2f1e9fe`
- SoC repo:
  - path: `/home/gstar/Desktop/e203_hbirdv2`
  - branch: `cnn_bringup_v1`
  - head: `2d9b346`
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
- Real integration bug fixed:
  - `cnn_nice_core` now latches `load_data_q` and `load_vec_sel_q`
  - fix mirrored to both repos

## Current Blocker

- The blocker is no longer simulator runtime.
- Official full-SoC `iverilog 12.0` now reaches the injected NICE program and
  prints real `NICE_REQ`/`NICE_RSP` activity.
- The previously observed `WLOAD rs2` issue was traced to an ISA mismatch:
  - the project had treated bits `[14:12]` as free `funct3`
  - official E203 NICE uses bits `[14:12]` as `xd/xs1/xs2`
  - custom operation selection must therefore move into `funct7`
- After re-encoding the CNN NICE ISA and updating the full-SoC patch, the
  official full-SoC path now reproduces the three target observations:
  - `NICE_REQ`
  - `req_ready` low while busy
  - `RSTAT=320`

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
- Carry the corrected NICE encoding through the remaining software-side macros,
  docs, and SDK-side usage.
- Clean up temporary debug probes in `tb_top.v` once the new baseline is locked.
- Move from Phase 1 closure into the next integration step instead of
  re-debugging the datapath.

## Compression Rules

- Read this file first in future sessions.
- Read `INTEGRATION_ROADMAP.md` only for long-range planning.
- Read `PROGRESS.md` only for dated history.
- Avoid loading multiple large docs unless the task explicitly needs them.
