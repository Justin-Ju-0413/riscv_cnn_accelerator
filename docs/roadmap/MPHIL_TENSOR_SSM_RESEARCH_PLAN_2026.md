# CityU CALAS MPhil research plan: data-movement-centric RISC-V edge AI

- Status: revised working proposal for supervisor review
- Revision date: 2026-11-23
- Research branch: `codex/mphil-data-movement-20261123`
- Engineering baseline: `mphil-nice-v2-poc-v0.1.0` and its paired SoC tag
- Target start: September 2026
- Expected duration: 24 months

## Proposed MPhil title

**A Data-Movement-Centric RISC-V Coprocessor Architecture for Edge Tensor and State-Space Computing**

中文：**面向边缘张量与状态空间计算的 RISC-V 数据搬运中心型协处理器架构**

The change from "data-movement-aware" to "data-movement-centric" is intentional:
data movement is the object of study, not merely an implementation consideration.
"Coprocessor architecture" also keeps the work at the RISC-V/NICE integration layer
and distinguishes it from a standalone Vision Mamba accelerator.

### First-paper working title

**Unified Tile-and-State Management for Data-Movement-Efficient RISC-V Edge AI Coprocessing**

This is a candidate contribution framing, not a claim of priority. A complete
literature review must precede any "first" or "novel" claim.

## Research position

The verified E203/NICE CNN accelerator is the starting artifact, not the final
research contribution. It provides a 4×4 INT8/INT32 PE array, legacy custom
instructions, directed RTL tests, Full-SoC execution, and historical A7-100T
UART/ILA evidence. Its main limitation is that software repeatedly issues
register-load instructions, while the design lacks a useful on-chip storage
hierarchy and a general tiled operator interface.

The MPhil project therefore asks:

> Under a fixed compute array and constrained on-chip storage budget, can a unified
> tile/state descriptor and software-managed scratchpad reduce host control overhead,
> data movement, and end-to-end cycles for both tensor operators and selective scan,
> and where is the crossover relative to adding more PEs?

The project belongs to digital IC, SoC, computer architecture, and reconfigurable
computing. Its value must be established through end-to-end measurements and
resource-normalized design-space evidence, not peak TOPS or standalone kernel
speedup alone.

## Related-work and novelty boundary

RISC-V custom instructions, scratchpads, DMA, and tiled GEMM are individually well
established. Work such as Gemmini, VTA, XpulpNN, EdgeRV, and configurable
instruction-controlled RISC-V coprocessors means that the following are not
sufficient contributions by themselves:

- adding another custom RISC-V ABI;
- attaching a scratchpad or DMA engine;
- demonstrating that an accelerator outperforms scalar E203 software;
- implementing tiled GEMM without a new interface, mechanism, or measured design rule.

SSM/Mamba acceleration provides a more focused opportunity because recurrent state,
element-wise traffic, intermediate tensors, and linear layers impose different
dataflow requirements. However, another standalone Mamba accelerator is also not
the objective. The candidate contribution is the software-visible mechanism that
allows regular tensor tiles and recurrence-dependent SSM state to share a RISC-V
attached storage and movement path.

## Hypotheses

### H1: data-movement improvement

With the PE count unchanged, bounded block/tile transfers, software-managed tiling,
and scratchpad residency will reduce host-issued instructions and end-to-end cycles
relative to the legacy register-load path. A single-word `MLOAD` is a correctness
proof only and is not expected to establish this hypothesis.

### H2: unified tensor/state substrate

A common descriptor, scratchpad organization, and control plane can serve GEMM,
convolution, and a short selective-scan block with less duplicated control and
storage than separate tensor and SSM data paths. The area and timing cost of this
generality must be reported.

### H3: buffering-versus-compute crossover

For a given operator shape, tile size, sequence length, and resource budget, there
is a measurable region in which additional buffering or residency is preferable to
additional PEs, and another region in which it is not. A negative or mixed result
is scientifically valid if the boundary is measured and explained.

## Expected contributions

1. **Measurement and problem formulation:** a reproducible phase breakdown of the
   scalar and legacy NICE paths, including host instructions, data movement,
   compute, readback, and utilization.
2. **Unified tile/state mechanism:** a backward-compatible NICE v2 extension with
   explicit tile/state descriptors, bounded block movement, shared scratchpads,
   and state-resident execution.
3. **Design-space evidence:** ablations over scratchpad capacity, tile shape,
   operator shape, sequence length, and PE scaling under documented resource
   constraints.
4. **Reproducible artifact:** golden models, RTL and Full-SoC tests, software
   wrappers, benchmark records, synthesis results, and conservative claim
   boundaries.

Expected long-term artifacts are one primary journal submission, an optional
extension paper, an MPhil thesis, and an open artifact. Submission is the Year-1
target; publication acceptance is not treated as a controllable milestone.

## Architecture plan

### A. Descriptor and software contract

Retain legacy funct7 `0–5` and the completed `CAP`/`MLOAD`/`MSTAT` proof of concept.
Define the smallest useful `MCFG`/`MEXEC`/`MSTORE` path only after profiling.

A descriptor should make the following explicit where applicable:

- operator and precision;
- base address, shape, stride, and tile dimensions;
- scratchpad bank and region;
- state dimensions and residency lifetime;
- tail behavior, alignment, bounds, and error handling;
- completion, memory ordering, and output writeback semantics.

Manual C wrappers or intrinsics are sufficient for the first paper. A complete
compiler or LLVM lowering flow is deferred.

### B. Block movement and shared storage

- Activate the NICE ICB memory path already exercised by the PoC.
- Extend single-word correctness coverage to bounded block or tile transfers.
- Parameterize activation, weight, output, and state storage as required by the
  selected workloads.
- Keep the number of outstanding operations and bank organization minimal until
  measurements justify additional complexity.
- Report both performance gains and BRAM/LUT/timing costs.

Burst DMA, prefetch, double buffering, and compute/memory overlap are not part of
the first-paper minimum viable contribution.

### C. Tiled tensor execution

- Retain the verified 4×4 INT8 PE array and INT32 accumulation for the primary
  design; do not make PE enlargement the main contribution.
- Implement the smallest tiled GEMM that reuses the verified array.
- Map small MatMul and either 3×3 or 1×1 convolution first.
- Keep PE scaling as a comparison variant, not as the main engineering deliverable.

### D. State-resident selective scan

- Implement one compact short-sequence selective-scan/SSM block.
- Keep recurrent state resident across tokens where the model permits it.
- Measure state writebacks, intermediate traffic, host instructions, and cycles.
- Reuse the shared descriptor and storage path rather than constructing a second
  standalone Vision Mamba pipeline.

A complete ViM-tiny deployment is a later collaboration option, not a Year-1
paper requirement.

## First-paper scope

The first submission should contain one mechanism and a complete causal evidence
chain.

Required workloads:

- tiled GEMM;
- 3×3 or 1×1 convolution;
- one short-sequence selective-scan/SSM block.

Required compared systems:

1. E203 scalar software;
2. legacy NICE CNN accelerator;
3. NICE with bounded block movement and scratchpad;
4. NICE with unified tile/state management;
5. a PE-scaling comparison under an explicitly documented equal or approximate
   resource budget.

Required metrics:

- correctness against golden references;
- end-to-end cycles and load/compute/readback breakdown;
- retired host instructions and NICE command count;
- bytes moved, state writebacks, and PE utilization where observable;
- LUT, FF, BRAM, DSP, Fmax, WNS, and WHS;
- resource-normalized performance and an explicit account of imperfect area
  matching.

The intended central figure is a performance-versus-resource Pareto comparison
that identifies where GEMM, convolution, and SSM benefit from buffering or PE
scaling. Every performance claim must include its workload and resource context.

Deferred from the first paper:

- a complete Vision Mamba or LLM accelerator;
- dynamic quantization or APoT algorithm development;
- a complete compiler stack;
- full-network MNIST/LeNet accuracy claims;
- security, PQC, or FHE extensions;
- raw cycle comparisons across unequal cores, memory systems, processes, or
  frequencies.

## CALAS collaboration and separation

The topic directly connects to CALAS RISC-V architecture, software/hardware
co-design, embedded systems, and FPGA AI hardware. It also connects methodologically
to instruction-level fusion in RISC-V ASIP work and to the SSM dataflow challenges
studied by ViM-Q.

The separation from ViM-Q must remain explicit:

- this project studies the E203/NICE software-visible interface, host overhead,
  scratchpad organization, and data movement;
- ViM-Q's quantization algorithms and dedicated end-to-end Vision Mamba engines are
  not reproduced as this project's contribution;
- ViM-Q may provide models, golden data, workload guidance, or a later integration
  target through collaboration;
- this project does not claim that a shared substrate outperforms a dedicated
  accelerator without a controlled experiment.

Security is optional and should only be added if a natural research question such
as state isolation or model integrity emerges; it is not required for CALAS fit.

## Twelve-month first-submission plan

| Months | Deliverable | Exit criterion |
|---|---|---|
| M1–M2 | Reproduce baseline and profile scalar/legacy NICE paths | Load, compute, readback, instruction, and traffic evidence establishes whether the bottleneck is real |
| M3–M4 | Freeze descriptor, ABI, workloads, and golden models | Interface and benchmark review package is complete |
| M5–M6 | Implement bounded block movement, scratchpad, and minimal tiled GEMM | Golden, directed RTL, legacy regression, and initial Full-SoC tests pass |
| M7 | Implement one state-resident short-sequence scan | State residency produces measured software/traffic differences |
| M8 | Complete Full-SoC integration | End-to-end results and cycle decomposition are reproducible |
| M9 | Run FPGA synthesis and resource/timing measurements | Resource, Fmax, WNS, and WHS records are complete |
| M10 | Run ablations and PE/buffering design-space experiments | H1–H3 are accepted, rejected, or bounded with evidence |
| M11–M12 | Produce figures, draft, review internally, and submit | Every major claim maps to code, logs, and benchmark records |

M2 is a go/no-go gate. If profiling does not identify a meaningful data-movement
bottleneck, the project must narrow to state residency or select another workload
rather than continuing to add hardware without evidence.

## Year-2 plan

- M13–M16: select and map a small network; extend Full-SoC and board-facing
  evaluation with explicit fallback boundaries.
- M17–M19: compare buffering, PE scaling, and one optional optimization such as
  double buffering; strengthen robustness and reproducibility.
- M20–M21: draft thesis chapters and complete final experiments; respond to the
  first submission if reviews are available.
- M22–M24: prepare an extension paper if justified, finalize the thesis, complete
  the defense, and hand off the open artifact.

## Publication and degree boundary

The Year-1 objective is a complete journal submission, not guaranteed acceptance.
Conference work may supplement the research but does not replace a journal
submission when the stated target is SCI/SCIE.

The official CityU EE MPhil requirements should be checked against the current
student guidebook and supervisor expectations. Journal submission or acceptance
must not be treated as a substitute for coursework, a defensible thesis, the oral
examination, and the required exit presentation.

## Verification and stop rules

Every hardware change must pass, in order:

1. Python golden model;
2. directed RTL test;
3. the original 19-test RTL regression;
4. Full-SoC execution;
5. synthesis;
6. optional board validation.

Directed verification covers alignment, bounds, invalid bank/operator, tile tails,
state lifetime, reset, mid-operation errors, repeated status reads,
overflow/saturation, memory timeout, and output ordering.

Stop or revise the design when:

- block movement does not reduce host instructions or end-to-end cycles;
- buffering costs dominate BRAM or timing without a compensating system benefit;
- the unified descriptor adds substantial complexity but fails to cover both tensor
  and scan workloads cleanly;
- the SSM block cannot fit the current platform, in which case a shorter block is
  used and no full-model claim is made;
- the novelty review shows that the proposed mechanism duplicates prior work.

If the laboratory FPGA platform remains unconfirmed, keep the RTL parameterized
and use A7-100T only for correctness and small-scale baselines.

## Claim boundaries

- `5.282×` remains the historical 3×3 kernel-test result only.
- `10/10` remains the historical FPGA sample demonstration only.
- The project does not claim complete LeNet-5 acceleration or complete MNIST
  accuracy without new end-to-end evidence.
- Existing A7-100T UART/ILA evidence remains historical; a new board claim requires
  a fresh Vivado and hardware run.
- The existing `CAP`/`MLOAD`/`MSTAT` PoC proves a bounded memory path and backward
  compatibility, not DMA, tiled GEMM, network acceleration, or SSM execution.
- No novelty, publication acceptance, or graduation outcome is claimed in advance.
