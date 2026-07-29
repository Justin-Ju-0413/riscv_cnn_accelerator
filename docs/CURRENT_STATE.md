# Current State

> **Version**: V2.1 | **Updated**: 2026-07-29 | **Owner**: Justin JU

## Purpose

This is the engineering and research session-recovery file. It records the
validated FYP baseline, the first MPhil data-movement proof of concept, the
current development environment, and the next measurable gate.

## Current Snapshot

| Item | Value |
|------|-------|
| Engineering baseline | `codex/env-baseline-20260727` |
| MPhil research branch | `codex/mphil-tensor-scan-20260729` |
| Paired SoC research branch | `codex/mphil-tensor-scan-20260729-soc` |
| Lifecycle | FYP engineering and defense closed |
| Validated platform | Hummingbird E203 + NICE + Davinci Pro A7-100T |
| Immediate task | Full-SoC v2 memory microbenchmark and cycle breakdown |
| Research direction | data-movement-aware tensor + small SSM scan substrate |

The default `main` branches remain historical/default lines. They are not being
merged with the active engineering branches in this maintenance cycle.

## Repository Locations

| Role | Current clean WSL2 path |
|------|-------------------------|
| Accelerator | `/home/gstar/workspaces/riscv/riscv_cnn_accelerator` |
| SoC | `/home/gstar/workspaces/riscv/e203_hbirdv2` |

The older `/home/gstar/Desktop` repositories are retained as recovery copies.
Do not reset or delete them until the clean clones and GitHub PRs have been
verified.

## Closed Technical Baseline

- E203/NICE request-response integration is locked.
- The software-visible command path is `CFG/CLEAR/WLOAD/DLOAD/COMP/RSTAT`.
- The accelerator uses INT8 weights/activations, INT32 accumulation, and a 4x4
  output-stationary PE array.
- RTL and software-driven FullSoC regressions have recorded passing evidence.
- A7-100T programming, UART output, and ILA capture were completed.
- The NICE `rs2` index-capture bug was fixed in the E203 decoder and
  board-regressed on 2026-05-09.

## MPhil Proof of Concept

The 2026-07-29 research branch adds a backward-compatible NICE v2 prototype:

- funct7 `0–5` and `custom_insn.h` remain unchanged;
- `CAP=6` reports ABI `2.0`, 16 words per implemented bank, and capability bits;
- `MLOAD=8` performs one aligned ICB read into an activation or weight
  scratchpad;
- `MSTAT=11` provides self-checking scratchpad readback;
- command/response backpressure, ICB errors, reset invalidation, and timeouts
  are checked;
- `MCFG=7`, `MEXEC=9`, and `MSTORE=10` are reserved and return an error.

This is not yet DMA, tiled GEMM, convolution execution, or an SSM accelerator.
The memory path has been executed in the standalone directed harness; Full-SoC
regression currently proves legacy compatibility only.

## Recorded Evidence

| Evidence | Recorded result |
|----------|-----------------|
| Original RTL regression | `19/19` passed and `TB_PASS` |
| NICE v2 directed RTL | `16/16` passed and `NICE_V2_PASS` |
| Python tensor/scan golden | `7/7` passed |
| Lightweight SoC | `LIGHT_PASS` |
| FullSoC regression | `7/7` passed |
| Current Full-SoC completion | `PHASE4_PASS`, `RSTAT=19` |
| Current pre-board sweep | `PREBOARD_PASS` |
| Historical dot-product closure | `RSTAT=320` |
| Minimal CNN v1 FullSoC result | `expected_rstat = 19` |
| 3x3 convolution-kernel cycle test | `1516 / 287 = 5.282x` |
| FPGA sample demonstration | `10/10` samples |
| FPGA timing after NICE fix | WNS `13.512 ns`, WHS `0.056 ns` |
| Board result | UART reported `CNN v1 DEMO PASSED`; ILA captured |

The `5.282x` result is limited to the recorded 3x3 convolution-kernel cycle
test. The `10/10` result is limited to the recorded FPGA sample demonstration.
Neither value proves full LeNet-5 acceleration or full MNIST accuracy.

## Current Host Environment

| Tool | Current state |
|------|---------------|
| Ubuntu | 24.04 on WSL2 |
| RISC-V GCC | 14.2.1 under `/home/gstar/Desktop/gcc/bin` |
| RISC-V debugger | `gdb-multiarch` 15.1 |
| OpenOCD | 0.12.0 |
| Icarus Verilog | 12.0 |
| GNU Make | 4.3 |
| Python | 3.12 |
| Vivado | Not discovered on the current Windows host |
| Board serial/JTAG | Not connected during the 2026-07-27 audit |

Run `bash scripts/check_dev_env.sh` before starting a regression. The legacy
toolchain GDB is not used because it requires `libtinfo.so.5`, which Ubuntu
24.04 no longer provides.

## Immediate Gate

1. Add a Full-SoC SDK microbenchmark that runs `CAP → MLOAD → MSTAT`.
2. Record scalar and legacy NICE load/compute/readback cycles and instruction
   counts.
3. Measure bytes moved and compare register-load traffic with the minimal
   scratchpad path.
4. Freeze `MCFG` tile fields only after those measurements.
5. Implement the smallest tiled GEMM that reuses the verified 4×4 PE array.

Vivado programming and a physical board rerun are optional for this gate. If
they are not run, record them as `not run`, not as failures.

## Remaining Research Gaps

- No complete LeNet-5 end-to-end accelerator timing result.
- No full board-side MNIST accuracy run.
- No line buffer, DMA, burst transfer, double buffering, or compute/memory
  overlap.
- The NICE memory channel has only standalone aligned single-word coverage; no
  Full-SoC v2 software execution has been recorded yet.
- No automatic compiler mapping or RVV comparison baseline.
- No tiled GEMM, network-level accelerator, or hardware SSM scan unit yet.

## Reading Order

1. `docs/roadmap/MPHIL_TENSOR_SSM_RESEARCH_PLAN_2026.md`
2. `docs/roadmap/NICE_V2_ABI_AND_ICB_POC.md`
3. `docs/roadmap/LITERATURE_REPRODUCIBILITY_MATRIX_2026.md`
4. `docs/design_history/source_baselines/ENGINEERING_BASELINES.md`
5. `docs/benchmarks/README.md`

Update this file whenever the active baseline, blocker, or next gate changes.
