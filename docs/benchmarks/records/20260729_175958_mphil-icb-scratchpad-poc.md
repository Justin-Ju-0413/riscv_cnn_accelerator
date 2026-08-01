# Benchmark Record: MPhil ICB-to-scratchpad proof of concept

> Created: 2026-07-29 17:59:58 +0800
> Accelerator branch: `codex/mphil-tensor-scan-20260729`
> Accelerator implementation commit: `f3f4753`
> SoC branch: `codex/mphil-tensor-scan-20260729-soc`
> SoC implementation commit: `0a42ff9`

## Scope

- Experiment: establish a backward-compatible NICE v2 research baseline.
- Platform: Ubuntu 24.04 WSL2, E203/NICE, Icarus Verilog.
- Design change: `CAP`, aligned single-word ICB `MLOAD`, two parameterized
  scratchpad banks, `MSTAT` readback, and timeout/error handling.
- Compatibility target: preserve legacy funct7 `0–5` and the existing SDK
  demonstration.

## Environment

| Tool | Version / path |
| --- | --- |
| Ubuntu | 24.04 on WSL2 |
| RISC-V GCC | 14.2.1, `/home/gstar/Desktop/gcc/bin/riscv64-unknown-elf-gcc` |
| GDB | `gdb-multiarch` 15.1 |
| OpenOCD | 0.12.0 |
| Icarus Verilog | 12.0 |
| GNU Make | 4.3 |
| Python | 3.12.3 |
| Git | 2.43.0 |
| Vivado | not run / not available in this session |
| Physical A7-100T | not connected |

## Commands

```bash
./Project_Manager.sh run_mphil_golden
./Project_Manager.sh run_hw_v2
./Project_Manager.sh run_hw

SOC_DIR=/home/gstar/workspaces/riscv/e203_hbirdv2 \
SDK_DIR=/home/gstar/workspaces/riscv/riscv_cnn_accelerator/third_party/nuclei-sdk \
bash scripts/run_sdk_fullsoc_regression.sh

SOC_DIR=/home/gstar/workspaces/riscv/e203_hbirdv2 \
SDK_DIR=/home/gstar/workspaces/riscv/riscv_cnn_accelerator/third_party/nuclei-sdk \
bash scripts/run_preboard_verification.sh

/home/gstar/Desktop/gcc/bin/riscv64-unknown-elf-gcc \
  -O2 -march=rv32imac -mabi=ilp32 -I sw/inc \
  -c sw/nice_v2_compile_smoke.c -o /tmp/nice_v2_compile_smoke.o
```

## Correctness

| Item | Result |
| --- | --- |
| Python GEMM/CONV/depthwise/SSM golden tests | `7/7`, PASS |
| NICE v2 directed RTL | `16/16`, `NICE_V2_PASS` |
| Original RTL regression | `19/19`, `TB_PASS` |
| Lightweight SoC | `LIGHT_PASS` |
| Full-SoC legacy SDK | `PHASE4_PASS`, final `RSTAT=19` |
| Complete pre-board sweep | `PREBOARD_PASS` |
| NICE v2 C wrapper compile smoke | PASS |

The directed v2 test covers capability discovery, command backpressure and
stability, activation/weight loads, readback, alignment, reserved selector
bits, ICB error propagation, command timeout, response timeout, reserved
commands, and reset invalidation.

## Current Performance Evidence

No new performance number is claimed in this record. The test establishes
correctness and backward compatibility.

| Metric | Value |
| --- | --- |
| CPU-only cycles | not measured in this run |
| Legacy load/compute/readback breakdown | next experiment |
| NICE v2 end-to-end cycles | not measured in Full-SoC |
| CPU-issued NICE instruction reduction | not yet measured |
| Bytes moved / PE utilization | not yet measured |
| Speedup | no claim |

## Hardware Cost

| Metric | Value |
| --- | --- |
| LUT / FF / BRAM / DSP | not synthesized |
| Fmax / WNS / WHS | not run |
| Vivado | not run |
| Board UART / ILA | not run |

## Verified and Unverified Boundaries

This record proves:

- deterministic golden semantics for the first tensor/scan microbenchmarks;
- standalone `memory → scratchpad → MSTAT` behavior for aligned single-word
  ICB reads;
- explicit error and timeout behavior in the directed harness;
- backward compatibility of the legacy RTL and software-driven Full-SoC path.

This record does not prove:

- a Full-SoC SDK execution of `CAP/MLOAD/MSTAT`;
- burst DMA, prefetch, double buffering, or compute/memory overlap;
- tiled GEMM, generalized convolution, depthwise execution, or hardware SSM
  scan;
- synthesis, timing closure, a fresh Vivado build, or a fresh board result;
- complete LeNet-5 acceleration, complete MNIST accuracy, or complete Vision
  Mamba acceleration.

Historical claim limits remain unchanged:

- `5.282×` applies only to the recorded 3×3 convolution-kernel cycle test.
- `10/10` applies only to the recorded FPGA sample demonstration.
