# CityU CALAS MPhil research plan: data-movement-aware RISC-V edge AI

Status: supervisor-ready working proposal
Research branch: `codex/mphil-tensor-scan-20260729`
Target start: September 2026
Expected duration: 24 months

## Proposed title

**Data-Movement-Aware RISC-V Attached Acceleration for Tensor and State-Space Operators at the Edge**

中文：**面向边缘 AI 张量与状态空间算子的 RISC-V 附加式加速与数据搬运协同设计**

## Research position

The verified E203/NICE CNN accelerator is the starting artifact, not the final research
question. It already provides a 4×4 INT8/INT32 PE array, legacy custom instructions,
directed RTL tests, Full-SoC execution, and historical A7-100T UART/ILA evidence. Its
main limitation is that software issues repeated register-load instructions and the
design has no useful on-chip storage hierarchy or general tiled operator interface.

The MPhil project therefore asks:

> On a resource-constrained RISC-V SoC, when does a software-managed scratchpad and
> explicit tiling deliver better end-to-end area efficiency than adding more compute
> units?

The work complements CALAS Vision Mamba and specialized AI accelerators. It focuses
on the lower integration layer: RISC-V attachment, data movement, programmable
mapping, and a reusable tensor/scan substrate. It does not reproduce ViM-Q
quantization or claim a complete Vision Mamba accelerator.

## Hypotheses and measurable contributions

1. Activating the NICE ICB memory path and adding software-managed scratchpads will
   reduce CPU-issued load instructions and end-to-end cycles more efficiently than
   scaling the 4×4 PE array alone.
2. A tiled GEMM core can reuse the existing PE array for 3×3 convolution, 1×1
   convolution, and small matrix multiplication without breaking the undergraduate
   ABI.
3. A small recurrence/scan unit can share the same storage and control plane,
   providing a useful SSM block without duplicating a full specialized Vision Mamba
   pipeline.
4. A capability-discovered NICE v2 prototype can offer a stable software contract
   while remaining explicitly separate from draft RISC-V matrix standards.

Expected artifacts:

- a backward-compatible NICE v2 research ABI;
- parameterized activation, weight, state, and output scratchpads;
- tiled GEMM plus an optional recurrence/scan unit;
- microbenchmarks, network-level mappings, performance counters, and reproducible
  experiment records;
- one primary architecture paper, one optional extension paper, an MPhil thesis,
  and an open artifact.

## Scope and non-goals

The first implementation supports aligned, bounded, single-request ICB reads. Burst
DMA, double buffering, prefetch, and overlap are added only after measurement shows
that the minimal path is useful.

The project does not initially target:

- a complete LLM accelerator;
- a complete compiler stack;
- a second standalone Vision Mamba quantization accelerator;
- a larger PE array without a data-movement result;
- simultaneous FHE or PQC acceleration.

Security may later be evaluated through model integrity, access isolation, or secure
loading, but it is not on the critical path.

## Architecture stages

### Stage A: memory path and storage

- activate the existing NICE ICB memory channel;
- introduce parameterized activation, weight, state, and output scratchpads;
- use software-managed tiling;
- begin with aligned words, bounded lengths, and one outstanding request;
- add prefetch, double buffering, and compute/memory overlap only after an
  evidence-based bottleneck analysis.

### Stage B: unified tensor core

- retain the verified 4×4 INT8 PE array and INT32 accumulation;
- generalize it into tiled GEMM;
- map 3×3 convolution, 1×1 convolution, and small MatMul first;
- add a depthwise block or linear-attention matrix operator next.

### Stage C: state-space connection

- add only a compact recurrence/scan unit;
- evaluate a short-sequence SSM block on A7;
- reserve a complete ViM-tiny experiment for a confirmed, larger laboratory FPGA.

## Evaluation contract

Microbenchmarks:

- original 3×3 convolution;
- 1×1 convolution;
- multi-channel 3×3 convolution;
- tiled GEMM;
- depthwise block;
- short-sequence SSM scan.

Network-level workloads:

- MLPerf Tiny-style ResNet-8/CIFAR-10;
- DS-CNN;
- a ViM/SSM block, not a full model on the current A7-100T.

Compared systems:

- E203 scalar software;
- original NICE CNN accelerator;
- NICE memory/scratchpad revision;
- unified tensor/scan revision.

Recorded metrics:

- correctness and quantization error;
- end-to-end cycles and phase breakdown;
- CPU-issued NICE instruction count;
- bytes moved and PE utilization;
- LUT, FF, BRAM, DSP, Fmax, WNS, and WHS;
- end-to-end latency on a common platform.

RVV and draft IME/VME/AME work are semantic and software-mapping references. Raw
cycle counts are not compared unless the core, memory system, process, and frequency
are equivalent.

## Bridge plan: now to September 2026

| Week | Deliverable | Exit criterion |
|---|---|---|
| 1 | Freeze baseline and measure scalar/legacy NICE phase breakdown | load, compute, and readback cycles recorded |
| 2 | Literature and reproducibility matrix | overlap with CALAS work explicitly bounded |
| 3 | GEMM, convolution, depthwise, and SSM golden microbenchmarks | deterministic tests pass |
| 4 | NICE v2 ABI, scratchpad organization, and ICB verification plan | interface review ready |
| 5 | Minimal ICB read-to-scratchpad RTL proof of concept | directed RTL test passes; legacy 19 tests pass |
| 6 | Proposal, concise presentation, and first experiment plan | supervisor review package ready |

September gate:

- no legacy regression;
- quantitative evidence of the current loading bottleneck;
- at least one `memory → scratchpad → observed result` microbenchmark;
- no new board claim without a fresh Vivado and hardware run.

## MPhil milestones

### Year 1

- M1–M4: reproduce the platform, freeze benchmarks and ABI, select the laboratory
  FPGA;
- M5–M8: complete ICB/scratchpad, tiled GEMM, convolution mapping, and Full-SoC
  validation;
- M9–M12: synthesize on the selected FPGA, run resource/timing ablations, and draft
  the first paper.

Primary paper story: how a NICE memory path and software-managed scratchpad change
end-to-end efficiency for RISC-V edge AI.

### Year 2

- M13–M16: add DS-CNN/linear-attention operators and a small SSM scan;
- M17–M19: complete network-level and ViM-block evaluation;
- M20–M21: compare RVV/matrix-extension semantics and package the reproducible
  artifact;
- M22–M24: final experiments, submission, thesis, defense, and open-source handoff.

## Verification and stop rules

Every hardware change must pass, in order:

1. Python golden model;
2. directed RTL test;
3. the original 19-test RTL regression;
4. Full-SoC execution;
5. synthesis;
6. optional board validation.

Directed verification covers alignment, bounds, invalid bank/operator, tile tails,
reset, mid-operation errors, repeated status reads, overflow/saturation, and memory
timeout.

If a revision does not reduce software load instructions or end-to-end cycles, PE
scaling stops and the scratchpad/tiling policy is revised. If the laboratory platform
is still unknown in September–October 2026, the RTL remains parameterized and the
A7-100T is used only for correctness and small-scale baselines.

## Claim boundaries

- `5.282×` remains the historical 3×3 kernel-test result only.
- `10/10` remains the historical FPGA sample demonstration only.
- This project does not claim complete LeNet-5 acceleration or complete MNIST
  accuracy.
- Existing A7-100T UART/ILA evidence remains historical; this research branch must
  not claim a fresh board run until Vivado and the board are available.
