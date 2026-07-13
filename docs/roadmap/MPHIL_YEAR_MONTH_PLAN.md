# MPhil Long-Term Plan: RISC-V/E203 NICE Edge-AI Accelerator

> Duration: 24 months
> Main direction: data-movement-aware RISC-V custom-instruction acceleration for edge AI
> Starting baseline: E203 + NICE + 4x4 INT8 PE array + RTL/FullSoC/FPGA sample validation

## Research Positioning

The MPhil should not be framed as simply making the undergraduate CNN accelerator
larger. The stronger research question is:

> For a resource-constrained RISC-V edge-AI SoC, how do custom instructions,
> on-chip buffering, software mapping, and benchmark methodology jointly affect
> end-to-end CNN acceleration?

This keeps the work close to the existing project while raising it from a
prototype implementation to a research program. The core evidence must remain
measured: correctness, cycle count, memory traffic or load count, FPGA resource
cost, timing, and claim boundary.

## Year-Level Roadmap

| Period | Main Goal | Research Output | Engineering Output |
| --- | --- | --- | --- |
| Year 1 | Rebuild the baseline, define benchmarks, and prove a first data-movement improvement | Literature review, problem formulation, baseline report, first workshop-style result | Reproducible regression flow, benchmark records, reference-model comparison, first buffer/line-buffer prototype |
| Year 2 | Generalize the design, compare alternatives, and write the thesis/paper | Full thesis, conference/journal submission, evaluated design-space comparison | Operator expansion, end-to-end network evaluation, resource/timing/performance dataset, cleaned artifact package |

## Quarter Milestones

| Quarter | Theme | Milestone |
| --- | --- | --- |
| Q1 | Research framing and baseline recovery | Research proposal and reproducible baseline complete |
| Q2 | Benchmark and reference model | Micro-benchmark suite and Python-to-RTL comparison complete |
| Q3 | Data movement prototype | Line buffer or local SRAM-buffer path implemented and measured |
| Q4 | First paper-quality result | Internal report or workshop-style manuscript draft complete |
| Q5 | Operator expansion | Multi-channel, stride/padding, or 1x1 convolution support evaluated |
| Q6 | End-to-end evaluation | Small CNN/LeNet-style end-to-end flow measured with safe claim boundaries |
| Q7 | Design-space comparison | Baseline vs buffer vs optimized variants compared quantitatively |
| Q8 | Thesis and publication closure | Thesis, artifact package, and paper submission completed |

## Month-By-Month Plan

### Month 1: Baseline Audit And Research Scope

- Read the current FYP codebase, evidence package, and `FUTURE_RND_PLAN.md`.
- Freeze a clean baseline branch or tag for MPhil work.
- Re-run or review the existing gates: RTL regression, FullSoC regression, and board evidence.
- Draft a one-page research scope: problem, hypothesis, target workloads, and non-goals.

Deliverables:

- Baseline audit note.
- Initial research proposal outline.
- First benchmark record under `docs/benchmarks/records/`.

Exit criteria:

- The supervisor can see exactly what is already completed and what is new MPhil work.

### Month 2: Literature Review And Taxonomy

- Review RISC-V custom instruction accelerators, RVV/vector baselines, TinyML accelerators, VTA-style accelerator templates, and PULP-like open SoC work.
- Classify related work by compute array, data movement, programmability, memory hierarchy, and evaluation method.
- Identify 3 to 5 comparison dimensions for the thesis.

Deliverables:

- Literature matrix.
- Related-work taxonomy.
- Finalized MPhil title candidate.

Exit criteria:

- The project has a defensible research gap, not just an implementation plan.

### Month 3: Benchmark Methodology

- Define micro-benchmarks: 3x3 convolution, 1x1 convolution, multi-channel convolution, stride/padding case, and small-network case.
- Define reporting fields: correctness, cycles, speedup, load count or memory traffic proxy, LUT/FF/BRAM/DSP, WNS/WHS.
- Decide which claims require RTL, FullSoC, board UART, ILA, or full dataset evidence.

Deliverables:

- Benchmark methodology document.
- Updated benchmark record templates if needed.
- Baseline CPU-only and accelerator-visible measurement plan.

Exit criteria:

- Every future performance number has a standard reporting format.

### Month 4: Reference Model And Golden Data

- Build or clean Python reference models for selected convolution cases.
- Generate fixed test vectors for RTL, software, and board-side runs.
- Add layer-by-layer comparison outputs for later network evaluation.

Deliverables:

- Reference-model scripts.
- Golden input/output dataset.
- First Python-to-current-RTL comparison report.

Exit criteria:

- A failed RTL or board result can be debugged against a known golden reference.

### Month 5: Baseline Reproduction And Automation

- Make the current regression flow easier to replay on the MPhil machine.
- Record the exact tool versions, branch, commit, board, and command sequence.
- Re-measure the current 3x3 convolution baseline without changing claims.

Deliverables:

- Reproducible baseline report.
- Toolchain/setup note.
- Confirmed benchmark record for current baseline.

Exit criteria:

- The old FYP baseline can be reproduced or its unreproducible parts are clearly documented.

### Month 6: Data Movement Bottleneck Analysis

- Measure where cycles are spent: software loads, custom instruction issue, compute, result readback, and board/SoC overhead where observable.
- Estimate activation and weight reuse opportunities.
- Choose the first implementation target: line buffer or local activation/weight SRAM buffer.

Deliverables:

- Bottleneck analysis report.
- First design specification for buffering.
- Go/no-go decision for the chosen data-movement path.

Exit criteria:

- The first optimization is justified by measured or analytically estimated bottlenecks.

### Month 7: First Buffer Or Line-Buffer Prototype

- Implement a minimal buffer/line-buffer path in RTL.
- Keep the existing NICE command behavior compatible where possible.
- Add directed tests for normal, boundary, reset, invalid index, and partial-load cases.

Deliverables:

- RTL prototype.
- Directed RTL tests.
- Benchmark records for correctness and cycle impact.

Exit criteria:

- The prototype is functionally correct in RTL and does not break the baseline tests.

### Month 8: FullSoC Integration Of Buffer Prototype

- Connect the prototype to the software-visible flow.
- Update driver or demo code only as much as needed to exercise the new path.
- Compare baseline vs buffered version in FullSoC simulation.

Deliverables:

- FullSoC regression result.
- Software driver/demo update note.
- Baseline-vs-buffer comparison table.

Exit criteria:

- The optimization is visible from software, not only from a standalone RTL testbench.

### Month 9: FPGA Feasibility And Resource Timing

- Synthesize or implement the buffer prototype on the target FPGA flow.
- Record LUT/FF/BRAM/DSP, WNS/WHS, and any timing bottlenecks.
- Decide whether to keep, simplify, or redesign the buffer.

Deliverables:

- FPGA resource/timing report.
- Board-feasibility benchmark record.
- Optimization decision note.

Exit criteria:

- The design has measured hardware cost, not only simulation speedup.

### Month 10: Operator Expansion Prototype

- Add one additional operator mode: recommended first target is multi-channel 3x3 convolution.
- Keep the reference model and RTL/FullSoC comparison aligned.
- Record whether the current instruction interface is still sufficient.

Deliverables:

- Operator expansion prototype.
- Python-to-RTL comparison.
- Interface limitation note.

Exit criteria:

- The project can support at least one CNN case beyond the original 3x3 sample.

### Month 11: First Paper-Style Experiment Package

- Consolidate results from baseline, bottleneck analysis, buffer prototype, and operator expansion.
- Prepare plots/tables for speedup, resources, timing, and claim boundary.
- Identify the strongest story for a workshop or internal seminar.

Deliverables:

- Paper-style experiment package.
- Draft figures and tables.
- Supervisor review deck.

Exit criteria:

- The work has one coherent result story suitable for external feedback.

### Month 12: Year-1 Review And Research Adjustment

- Review whether the main hypothesis is still valid.
- Decide the Year-2 emphasis: deeper buffering, wider operator support, RVV/custom comparison, or portability.
- Write a Year-1 technical report.

Deliverables:

- Year-1 report.
- Updated Year-2 plan.
- Workshop-style manuscript draft if results are strong enough.

Exit criteria:

- The second year starts from evidence, not momentum.

### Month 13: End-To-End Network Plan

- Select a small network target: LeNet-style, TinyCNN, DS-CNN subset, or another supervisor-approved model.
- Define what counts as end-to-end: input layout, all layers, output classification, and dataset/sample scope.
- Prepare reference outputs and quantization assumptions.

Deliverables:

- End-to-end evaluation plan.
- Quantization note.
- Network-level golden data.

Exit criteria:

- Full-network claims have explicit evidence requirements before implementation.

### Month 14: Layer Mapping And Software Flow

- Map each selected network layer onto CPU-only, accelerator-assisted, or unsupported fallback execution.
- Update software flow to call the accelerator where appropriate.
- Record layer-by-layer cycles and correctness.

Deliverables:

- Layer mapping table.
- Software execution flow.
- Layer-level benchmark records.

Exit criteria:

- End-to-end performance can be explained layer by layer.

### Month 15: Network-Level FullSoC Evaluation

- Run the selected network or reduced network in FullSoC simulation.
- Compare CPU-only, accelerator-assisted, and fallback portions.
- Record accuracy only within the tested scope.

Deliverables:

- FullSoC network evaluation report.
- End-to-end cycle breakdown.
- Safe claim statement.

Exit criteria:

- The project can report a network-level result without overclaiming full dataset performance.

### Month 16: Board-Level Network Demonstration

- Move the network or reduced network demo to board-facing execution if feasible.
- Capture UART output and ILA summary for key accelerator activity.
- If full network board execution is too slow or unstable, capture a representative layer/demo and document the boundary.

Deliverables:

- Board demo record.
- UART/ILA evidence.
- Board limitation note if needed.

Exit criteria:

- Board evidence is available for the strongest feasible network or layer demonstration.

### Month 17: Design-Space Alternatives

- Compare at least three variants: baseline, buffered version, and one optimized or simplified alternative.
- Optional alternatives: double buffering, wider PE array, pipelined accumulation, or memory-channel prototype.
- Keep comparison dimensions fixed.

Deliverables:

- Design-space comparison matrix.
- Resource/timing/performance plots.
- Recommendation for final architecture.

Exit criteria:

- The thesis can explain why the final design was chosen.

### Month 18: Robustness And Negative Testing

- Expand tests for reset, invalid command, invalid index, partial data, boundary padding, overflow/saturation assumptions, and repeated result reads.
- Check whether the design remains stable across benchmark cases.
- Clean up fragile scripts and undocumented assumptions.

Deliverables:

- Robustness test report.
- Regression checklist.
- Known limitations list.

Exit criteria:

- The final design is not only fast on a happy-path example.

### Month 19: Artifact Cleanup And Reproducibility

- Separate source code, generated artifacts, evidence, and thesis figures.
- Ensure all benchmark records point to commands, logs, and outputs.
- Create a clean reproduction guide for the final design.

Deliverables:

- Artifact package.
- Reproduction guide.
- Final benchmark dataset.

Exit criteria:

- Another reader can reproduce the key tables or understand exactly why a table is archival.

### Month 20: Thesis Chapter Drafting

- Draft introduction, related work, system architecture, methodology, and baseline chapters.
- Freeze terminology and claim boundaries.
- Convert experiment tables into thesis-ready figures.

Deliverables:

- First 60 percent thesis draft.
- Figure/table list.
- Supervisor feedback checklist.

Exit criteria:

- The thesis structure is stable before final experiments.

### Month 21: Final Experiments

- Run final baseline and optimized design measurements.
- Fill any missing resource/timing/performance fields.
- Re-run reference-model comparisons for final reported cases.

Deliverables:

- Final experiment log.
- Final plots/tables.
- Updated artifact package.

Exit criteria:

- No thesis claim depends on an unrecorded experiment.

### Month 22: Paper Submission Draft

- Convert the strongest thesis result into a paper draft.
- Target a realistic venue based on novelty and maturity: workshop, regional conference, embedded systems venue, or open-source artifact venue.
- Prepare abstract, contribution bullets, method, evaluation, and limitations.

Deliverables:

- Paper draft.
- Covering experiment appendix.
- Supervisor-ready submission package.

Exit criteria:

- The paper has a defensible contribution even if it is not top-tier SOTA.

### Month 23: Thesis Finalization

- Complete all thesis chapters.
- Align text with figures, tables, code, and benchmark records.
- Remove unsupported claims and stale numbers.

Deliverables:

- Full thesis draft.
- Claim-audit checklist.
- Final supervisor review version.

Exit criteria:

- Every major claim maps to a benchmark record, code path, or cited source.

### Month 24: Defense, Submission, And Handoff

- Prepare defense slides, Q&A, demo material, and artifact handoff.
- Freeze final code and evidence snapshot.
- Submit thesis and archive future work ideas separately.

Deliverables:

- Final thesis.
- Defense deck and Q&A.
- Final source/evidence package.
- Post-MPhil handoff note.

Exit criteria:

- The project ends with a clean thesis, a reproducible artifact, and a clear next-research boundary.

## Monthly Operating Rhythm

Each month should end with:

- one benchmark record or explicit note explaining why no experiment was run;
- one short progress note covering what changed, what failed, and what is next;
- one supervisor-facing figure, table, or decision summary;
- updated claim boundaries if any result scope changed.

## Risk Branches

| Risk | Trigger | Fallback |
| --- | --- | --- |
| FPGA board flow becomes unreliable | Board runs block progress for more than one month | Use RTL + FullSoC as primary evidence and keep board demo as supporting evidence |
| Buffering adds too much BRAM/timing cost | WNS fails or BRAM cost dominates | Simplify buffer, reduce supported operator scope, or return to software-managed tiling |
| End-to-end network is too large | Full network cannot fit or simulate in time | Use layer-level and reduced-network benchmarks with explicit claim boundaries |
| Novelty looks weak | Optimization is only incremental | Shift contribution toward quantitative design-space methodology and reproducible artifact |
| Toolchain portability is poor | Another machine cannot reproduce flow | Containerize or document exact archival environment and keep reproducibility scope honest |

## Success Definition

The MPhil is successful if it produces:

- a reproducible RISC-V/NICE edge-AI accelerator artifact;
- a measured explanation of data-movement and buffering tradeoffs;
- at least one network-level or multi-operator evaluation beyond the FYP sample;
- a clean thesis with conservative, evidence-backed claims;
- ideally one paper or workshop submission.

