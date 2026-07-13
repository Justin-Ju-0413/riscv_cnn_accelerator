# Future R&D Plan: RISC-V/E203 NICE CNN Accelerator

> Status: post-FYP continuation plan
> Baseline platform: Hummingbird E203 + NICE + A7-100T
> Scope: turn the validated prototype into a reproducible, extensible, and measurable edge-AI acceleration platform.

## Current Baseline

The current project baseline has closed the core prototype loop:

- E203/NICE integration is available through the request/response path.
- The software-visible command set is `CFG/CLEAR/WLOAD/DLOAD/COMP/RSTAT`.
- The accelerator uses INT8 activations/weights with INT32 accumulation.
- The compute core is a 4x4 PE array using an output-stationary style.
- RTL simulation, FullSoC simulation, and FPGA sample validation have evidence.
- Current result claims remain bounded:
  - `5.282x` only describes the current 3x3 convolution-kernel benchmark.
  - `10/10` only describes the current FPGA board sample demonstration.

This plan starts from that baseline. It does not treat line buffer, DMA, full
LeNet-5 acceleration, full MNIST board accuracy, or larger PE arrays as already
completed work.

For a longer MPhil execution schedule, use
`docs/roadmap/MPHIL_YEAR_MONTH_PLAN.md`.

## Phase 1: Baseline Reproducibility

Goal: make the current prototype easy to replay before changing the design.

Deliverables:

- Keep `scripts/run_preboard_verification.sh` as the pre-board gate.
- Keep `scripts/run_sdk_fullsoc_regression.sh` as the FullSoC software-driven gate.
- Add benchmark records under `docs/benchmarks/records/` for every meaningful run.
- Record CPU-only cycles, accelerator cycles, speedup, resources, timing, and board logs in the same format.
- Preserve the current claim boundaries in every report.

Acceptance criteria:

- RTL regression passes.
- FullSoC NICE regression passes.
- CNN v1 board or captured UART evidence matches expected output.
- Benchmark record includes enough data to reproduce the run or explain why a field is not available.

## Phase 2: Data Movement And On-Chip Buffering

Goal: reduce register-operand transfer overhead without destabilizing the
current NICE integration boundary.

Candidate tracks:

- Lightweight line buffer for sliding-window reuse.
- Weight and activation SRAM buffers near the PE array.
- NICE memory-channel research path for later memory-side access.

Default priority:

1. Add a minimal line buffer or local activation/weight buffer.
2. Validate it against the Python/reference model and RTL testbench.
3. Measure whether fewer software-visible loads produce real cycle savings.
4. Defer DMA-like transfer until the simpler buffered path is proven.

Acceptance criteria:

- Existing `CFG/CLEAR/WLOAD/DLOAD/COMP/RSTAT` behavior remains compatible.
- New buffering behavior has directed RTL tests for normal, boundary, and invalid cases.
- Cycle reduction is reported together with LUT/FF/BRAM/DSP and WNS/WHS impact.

## Phase 3: Operator And Network Expansion

Goal: move from a single 3x3 convolution sample toward a fuller CNN inference
path while keeping numerical evidence traceable.

Planned expansion:

- Multi-channel convolution.
- Stride and padding variants.
- 1x1 convolution.
- Layer-by-layer LeNet-5 data layout and quantization checks.
- Reference-model-to-RTL and reference-model-to-board output comparison.

Acceptance criteria:

- Each new operator has a Python/reference-model case and an RTL or FullSoC case.
- Quantization assumptions are documented before reporting accuracy.
- LeNet-5 board claims stay sample-scoped until a full dataset flow exists.

## Phase 4: Microarchitecture Optimization

Goal: improve throughput only when the cost can be measured and justified.

Optimization candidates:

- PE utilization analysis across kernel sizes and channel counts.
- Pipelined accumulation.
- Double buffering between load and compute.
- Output reuse and partial-sum scheduling.
- Larger PE array variants after the 4x4 baseline is fully characterized.

Acceptance criteria:

- Every optimization is compared against the 4x4 baseline.
- Reports include function correctness, cycle savings, resource growth, and timing closure.
- Changes that increase resource cost without measurable cycle benefit are not promoted.

## Phase 5: Engineering And Portability

Goal: make the project easier to reuse, audit, and port.

Deliverables:

- Clear boundary between E203/NICE modifications, accelerator RTL, software driver, tests, and board scripts.
- Updated hardware interface documentation and instruction-encoding notes.
- Minimal software API examples for each supported operation.
- Board bring-up guide that records UART, ILA, bitstream, timing, and resource evidence.
- Optional portability study for another FPGA board or SoC integration environment.

Acceptance criteria:

- A new collaborator can run the documented regression flow before reading old chat history.
- Source, evidence, and generated reports remain separated.
- Portability claims are backed by an actual build, simulation, or board run.

## Claim Rules

- Do not report full LeNet-5 acceleration until end-to-end network timing is measured.
- Do not report full MNIST board accuracy until a full board-side dataset flow exists.
- Do not present line buffer, DMA, NICE memory-channel transfer, or larger PE arrays as completed before implementation and validation.
- Always separate simulation evidence, board sample evidence, and full-dataset evidence.
