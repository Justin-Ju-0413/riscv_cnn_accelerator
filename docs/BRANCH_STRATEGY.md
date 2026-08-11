# Branch and Release Strategy

> Snapshot date: 2026-08-12 (Asia/Shanghai)

The FYP is complete. `main` is the maintained landing branch in both public
repositories. Reproducibility is expressed through immutable, same-name Release
tags; older engineering branches remain available as historical snapshots.

## Maintained Entry

| Repository | Branch | Role | Daily development |
|---|---|---|---|
| `riscv_cnn_accelerator` | `main` | Documentation, CI, and release navigation | Maintenance only |
| `e203_hbirdv2` | `main` | Documentation, CI, and release navigation | Maintenance only |

## Reproducible Paired Releases

| Milestone | Accelerator tag | SoC tag | Claim boundary |
|---|---|---|---|
| Recovered FYP environment | `env-baseline-2026-07-27` | `env-baseline-2026-07-27` | Minimal CNN v1 and recorded pre-board gates |
| MPhil NICE v2 PoC | `mphil-nice-v2-poc-v0.1.0` | `mphil-nice-v2-poc-v0.1.0` | Bounded `CAP`/`MLOAD`/`MSTAT` experiment |

CI must compare and test matching tags. It must not validate a Release tag
against a mutable branch. Historical failed Release workflow runs from
2026-08-01 used that flawed branch-selection pattern; the same-name tag pairs
themselves contain matching `cnn_nice_core.v` files.

## Retained Branches

- `codex/a7-bringup-v2-main` ↔ `codex/a7-bringup-v2-soc`: retained A7-100T
  engineering snapshot.
- `codex/env-baseline-20260727` ↔ `codex/env-baseline-20260727-soc`: retained
  environment-recovery work branches.
- `codex/mphil-tensor-scan-20260729` ↔
  `codex/mphil-tensor-scan-20260729-soc`: retained MPhil PoC work branches.
- Other `codex/*`, `bringup_v1`, `local-work-backup`, and persona branches are
  retained for traceability until a separately approved cleanup.

No retained branch is deleted, rewritten, or promoted by this policy. Before
new engineering work, create a new branch from the intended immutable milestone
and document its exact paired ref.

## Claim Boundaries

- `5.282x` refers only to the recorded 3x3 convolution-kernel cycle test.
- `10/10` refers only to the recorded FPGA sample demonstration.
- The MPhil PoC does not claim tiled GEMM, DMA, `MEXEC`, `MSTORE`, complete
  Vision Mamba, or full MNIST acceleration.
- Vivado, UART, JTAG, ILA, and physical-board results are not current unless a
  new evidence package explicitly revalidates them.
