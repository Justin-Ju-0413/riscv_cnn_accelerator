# MPhil Long-Term Plan: Data-Movement-Centric RISC-V Edge-AI Coprocessor

> **Revision:** 2026-11-23
>
> **Duration:** 24 months
>
> **Main direction:** unified tile/state management and data movement for RISC-V edge AI
>
> **Starting baseline:** E203 + NICE + 4×4 INT8 PE array + RTL/FullSoC/FPGA sample evidence
>
> **Year-1 target:** one complete journal submission; acceptance is not assumed

## Research positioning

The MPhil should not be framed as making the undergraduate CNN accelerator larger.
The revised research question is:

> Under a fixed compute array and constrained on-chip storage budget, can unified
> tile/state descriptors and software-managed scratchpads reduce host overhead,
> data movement, and end-to-end cycles for tensor and selective-scan operators, and
> where is the crossover relative to adding PEs?

The first paper must establish one causal chain: measured bottleneck, unified
mechanism, controlled implementation, end-to-end evaluation, and resource-aware
design-space conclusion. A collection of new instructions or operators without
that chain is insufficient.

## Year-level roadmap

| Period | Main goal | Research output | Engineering output |
|---|---|---|---|
| Year 1 | Prove or bound H1–H3 and submit the first journal paper | Baseline analysis, mechanism paper, design-space evidence, complete submission | Block/tile movement, shared scratchpad, tiled GEMM, one state-resident scan, Full-SoC and FPGA results |
| Year 2 | Generalize the evaluation and complete the thesis | Thesis, final dataset, optional extension paper or revision | Network-level mapping, robustness tests, artifact package, optional overlap or collaboration integration |

## Quarter milestones

| Quarter | Theme | Milestone |
|---|---|---|
| Q1 | Baseline, novelty, and interface | Bottleneck evidence, literature boundary, frozen descriptor/ABI and golden models |
| Q2 | Unified mechanism | Block/tile movement, tiled GEMM, and state-resident scan pass verification |
| Q3 | End-to-end evidence | Full-SoC, FPGA resource/timing, and initial ablation results complete |
| Q4 | First submission | Design-space conclusions, figures, manuscript, internal review, and journal submission complete |
| Q5 | Network and layer mapping | A bounded network or multi-operator evaluation is defined and mapped |
| Q6 | Generalization | Network/layer Full-SoC and feasible board evidence complete |
| Q7 | Final design space and artifact | Alternative comparison, robustness, and reproducibility package complete |
| Q8 | Thesis and publication closure | Thesis, defense, final submission response or extension, and handoff complete |

## Month-by-month plan

### Month 1: Baseline audit and measurement contract

- Read the FYP codebase, evidence package, current MPhil PoC, and related roadmap.
- Freeze exact accelerator/SoC refs and record tool versions.
- Re-run or review golden, RTL, Full-SoC, and pre-board gates.
- Define load, compute, readback, host-instruction, traffic, and utilization fields.
- Separate historical board evidence from new measurements.

Deliverables:

- Baseline audit and reproducibility note.
- First benchmark record under `docs/benchmarks/records/`.
- One-page statement of H1–H3 and workload scope.

Exit criterion: completed FYP work, existing PoC work, and new MPhil work are
unambiguously separated.

### Month 2: Bottleneck proof and go/no-go decision

- Measure scalar and legacy NICE load/compute/readback cycles.
- Record host and NICE instruction counts and observable data movement.
- Evaluate whether single-word `MLOAD` can improve performance; do not assume it can.
- Review EdgeRV, Gemmini, VTA, XpulpNN, stream-based RISC-V coprocessors, SSM
  accelerators, and CALAS ViM-Q for direct overlap.

Deliverables:

- Bottleneck report with plots and raw logs.
- Updated literature/reproducibility matrix.
- Go/no-go decision for block/tile movement versus a narrower state-residency topic.

Exit criterion: the proposed optimization addresses a measured bottleneck and has
a defensible novelty boundary. If not, stop and revise the topic before RTL work.

### Month 3: Descriptor, ABI, and benchmark methodology

- Define tile/state descriptor fields, alignment, bounds, tails, completion, and
  memory-ordering semantics.
- Freeze the minimum `MCFG`/`MEXEC`/`MSTORE` behavior needed for evaluation.
- Select tiled GEMM, one convolution shape, and one short selective-scan block.
- Define baseline and ablation configurations before implementation.

Deliverables:

- Descriptor/ABI review document.
- Benchmark methodology and reporting template.
- Resource-normalization plan for PE-scaling comparisons.

Exit criterion: all planned performance numbers have a standard measurement and
claim format, and the interface is implementable without a compiler project.

### Month 4: Golden models and verification plan

- Build deterministic Python references for GEMM, convolution, and selective scan.
- Generate fixed inputs, outputs, tiling cases, state shapes, and tail cases.
- Define directed RTL tests for descriptors, block movement, state lifetime, reset,
  errors, and output ordering.

Deliverables:

- Golden-model scripts and datasets.
- Python-to-current-RTL comparison report.
- Verification matrix linked to each descriptor field.

Exit criterion: any later RTL or Full-SoC failure can be checked against a known
reference and an explicit contract.

### Month 5: Bounded block/tile movement and scratchpad

- Extend the single-word PoC to bounded block or tile transfers.
- Implement only the activation, weight, output, and state storage required by the
  selected workloads.
- Preserve legacy funct7 `0–5` and existing regression behavior.
- Measure immediate cycle, instruction, resource, and timing effects.

Deliverables:

- Block/tile movement RTL and wrappers.
- Directed RTL and legacy regression results.
- Initial block-versus-register-load comparison.

Exit criterion: the new memory path is correct in RTL and has a measurable system
level motivation; otherwise simplify or stop the mechanism.

### Month 6: Minimal tiled GEMM on the existing PE array

- Implement the smallest tiled GEMM using the verified 4×4 PE array.
- Map the selected convolution case through the same descriptor/storage path.
- Implement minimum `MCFG`, `MEXEC`, and `MSTORE` behavior without speculative
  features.

Deliverables:

- Tiled GEMM/convolution prototype.
- Golden and directed RTL results.
- Initial Full-SoC software-visible execution record.

Exit criterion: tensor execution is software-visible and does not break the legacy
ABI or original regression.

### Month 7: State-resident selective scan

- Implement one short-sequence scan using the shared state storage and control path.
- Keep state resident across tokens where valid and measure writebacks avoided.
- Compare against a non-resident or software-managed state baseline.
- Record additional area, storage, and timing costs.

Deliverables:

- Selective-scan RTL and golden comparison.
- State-residency benchmark record.
- Unified-versus-separate control/storage cost analysis.

Exit criterion: H2 is supported, rejected, or explicitly bounded by evidence; no
complete Vision Mamba claim is required.

### Month 8: Full-SoC integration and end-to-end evidence

- Integrate tensor and scan paths into the Full-SoC software flow.
- Measure end-to-end cycles and load/compute/readback decomposition.
- Run all golden, directed RTL, legacy, and Full-SoC regressions.
- Preserve logs and exact commits for every compared configuration.

Deliverables:

- Reproducible Full-SoC comparison table.
- Software driver/wrapper note.
- Updated claim boundary and unresolved-issue list.

Exit criterion: improvements are visible end to end, not only in standalone RTL.

### Month 9: FPGA resource and timing evaluation

- Synthesize or implement the selected configurations on the available FPGA flow.
- Record LUT, FF, BRAM, DSP, Fmax, WNS, and WHS.
- Compare the unified design against legacy and ablated versions.
- Run physical board tests only when the full evidence chain is available.

Deliverables:

- FPGA resource/timing report.
- Board-feasibility record or an explicit `not run` statement.
- Keep/simplify/redesign decision for the shared storage mechanism.

Exit criterion: performance claims have corresponding hardware-cost evidence.

### Month 10: Design-space exploration and hypothesis closure

- Sweep scratchpad capacity, tile dimensions, operator shapes, and scan sequence
  length within feasible bounds.
- Compare against at least one PE-scaling configuration under an explicit equal or
  approximate resource budget.
- Construct performance-versus-resource Pareto plots for tensor and SSM workloads.
- Identify where buffering or residency wins, loses, or has negligible effect.

Deliverables:

- Design-space matrix and raw dataset.
- Pareto figures and crossover analysis.
- H1–H3 conclusion table with supporting evidence.

Exit criterion: the paper has a generalizable result rather than a single speedup.

### Month 11: Paper experiment package and internal review

- Consolidate motivation, mechanism, evaluation, related-work separation, and
  limitations.
- Freeze the main tables and figures, including the Pareto/crossover figure.
- Audit every claim against code, logs, benchmark records, and cited sources.
- Review the paper narrative with the supervisor and relevant CALAS collaborators.

Deliverables:

- Complete paper-style experiment appendix.
- Draft manuscript and supervisor review deck.
- Claim-audit and reproducibility checklists.

Exit criterion: one coherent paper story is ready for external journal submission
without relying on future functionality.

### Month 12: Submission and Year-2 adjustment

- Select a journal by topic fit, evidence requirements, and current indexing rules.
- Complete internal review, formatting, artifact links, and submission.
- Record submission as a milestone without implying acceptance.
- Decide Year-2 priorities from H1–H3 results and reviewer/supervisor feedback.

Deliverables:

- Submitted manuscript and submission record.
- Year-1 technical report.
- Evidence-based Year-2 plan.

Exit criterion: the first paper is submitted and the second year starts from
measured results rather than accumulated features.

### Month 13: Bounded network-level plan

- Select a small network or multi-operator sequence approved by the supervisor.
- Define input layout, layer coverage, fallback execution, output, and dataset scope.
- Reuse CALAS model or golden-data assets only under explicit collaboration and
  attribution boundaries.

Deliverables: network evaluation plan, mapping table, and golden data.

Exit criterion: network claims and evidence requirements are fixed before new RTL.

### Month 14: Layer mapping and software flow

- Map layers to scalar, legacy NICE, unified tensor/state, or fallback execution.
- Record layer-level correctness, cycles, instructions, and traffic.
- Keep compiler automation optional and subordinate to the research question.

Deliverables: software flow, layer mapping, and layer-level benchmark records.

Exit criterion: end-to-end behavior can be explained layer by layer.

### Month 15: Network-level Full-SoC evaluation

- Run the selected network, reduced network, or multi-operator flow in Full-SoC.
- Compare scalar, accelerator-assisted, and fallback portions.
- Report accuracy only within the tested dataset and model scope.

Deliverables: Full-SoC report, cycle breakdown, and conservative claim statement.

Exit criterion: the project has a network-level result without overclaiming full
model or dataset performance.

### Month 16: Feasible board demonstration

- Move the strongest feasible network, layer, or SSM block to the board.
- Capture UART/ILA evidence where relevant.
- If physical execution is unavailable, retain Full-SoC evidence and record the
  board as not run rather than failed.

Deliverables: board record or limitation note, with fresh evidence only.

Exit criterion: the strongest feasible demonstration has an explicit evidence
boundary.

### Month 17: Final design-space alternatives

- Compare baseline, unified buffer, and one justified alternative such as double
  buffering or PE scaling.
- Keep comparison dimensions and workloads fixed.
- Explain why the final architecture is selected.

Deliverables: final comparison matrix and resource/timing/performance plots.

Exit criterion: the thesis justifies the final design rather than merely describing
its implementation.

### Month 18: Robustness and negative testing

- Test reset, invalid descriptors, invalid indices, partial tiles, state lifetime,
  overflow/saturation assumptions, timeout, repeated reads, and output ordering.
- Clean fragile scripts and undocumented assumptions.

Deliverables: robustness report, regression checklist, and known-limitations list.

Exit criterion: the design is evaluated beyond happy-path examples.

### Month 19: Artifact cleanup and reproducibility

- Separate source, generated files, logs, evidence, and thesis figures.
- Link every benchmark record to commands, refs, and outputs.
- Create a clean reproduction guide.

Deliverables: artifact package, reproduction guide, and final benchmark dataset.

Exit criterion: another reader can reproduce the main tables or identify exactly
which results are archival.

### Month 20: Thesis chapter drafting

- Draft introduction, related work, baseline, mechanism, methodology, and design
  space chapters.
- Freeze terminology and claim boundaries.
- Convert experiment records into thesis-ready figures.

Deliverables: approximately 60% thesis draft and supervisor feedback checklist.

Exit criterion: the thesis structure is stable before final experiments.

### Month 21: Final experiments and submission response

- Fill missing resource/timing/performance fields and rerun final comparisons.
- Respond to journal reviews if available; do not delay thesis evidence collection
  while waiting for reviews.

Deliverables: final experiment log, updated artifact, and revision plan if needed.

Exit criterion: no thesis claim depends on an unrecorded experiment.

### Month 22: Optional extension paper or revision

- Convert a genuinely new Year-2 result into an extension paper, or prioritize the
  first-paper revision.
- Do not split incremental features into a weak second publication.

Deliverables: extension draft or first-paper revision package.

Exit criterion: publication work remains distinct, defensible, and subordinate to
thesis completion.

### Month 23: Thesis finalization

- Complete all chapters and align text, figures, tables, code, and records.
- Remove unsupported claims and stale numbers.
- Complete the claim-audit checklist.

Deliverables: full thesis draft and final supervisor-review version.

Exit criterion: every major claim maps to evidence or a cited source.

### Month 24: Defense, submission, and handoff

- Prepare defense slides, Q&A, demo material, and exit presentation.
- Freeze final code and evidence snapshots.
- Submit the thesis and archive future-work ideas separately.

Deliverables: final thesis, defense deck, final source/evidence package, and handoff
note.

Exit criterion: the project ends with a defensible thesis, reproducible artifact,
and clear next-research boundary.

## Monthly operating rhythm

Each month should end with:

- one benchmark record or an explicit reason no experiment was run;
- one short progress note covering changes, failures, and next actions;
- one supervisor-facing figure, table, or decision summary;
- updated hypothesis status and claim boundaries where needed.

## Risk branches

| Risk | Trigger | Fallback |
|---|---|---|
| No meaningful movement bottleneck | M2 profiling does not support H1 | Narrow to SSM state residency or change workload before new RTL |
| Single-word or block loads are slower | Host cycles or end-to-end latency regress | Stop PE scaling; revise transfer granularity, tiling, or descriptor semantics |
| Unified mechanism is too general | Area/timing/control cost exceeds benefit | Reduce descriptor fields or report the boundary instead of hiding the cost |
| SSM block is too large | Current platform cannot fit or simulate it | Use a shorter block and prohibit full-model claims |
| Buffering dominates BRAM/timing | WNS fails or BRAM cost dominates | Simplify storage, reduce operator scope, or retain software-managed tiling |
| Novelty is weak | Related-work review finds the same mechanism | Shift to measured crossover/design-space methodology or abandon the duplicated mechanism |
| Board flow blocks progress | Hardware work blocks progress for one month | Use RTL + Full-SoC as primary evidence and board work as supporting evidence |
| Toolchain portability is poor | Another machine cannot reproduce results | Containerize or document the exact archival environment and narrow claims |
| Journal review extends beyond plan | No decision by thesis finalization | Continue thesis completion; submission must not be treated as acceptance |

## Success definition

The MPhil is successful if it produces:

- a reproducible RISC-V/NICE edge-AI coprocessor artifact;
- a measured explanation of data movement, state residency, buffering, and PE
  scaling tradeoffs;
- one coherent journal submission in Year 1 without assuming acceptance;
- at least one network-level or multi-operator evaluation beyond the FYP sample;
- a defensible thesis with conservative, evidence-backed claims and a clean handoff.
