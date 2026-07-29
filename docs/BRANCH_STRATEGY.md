# Branch Strategy

> Snapshot date: 2026-04-11 (Asia/Hong_Kong)

This document defines the branch roles shared by `riscv_cnn_accelerator` and
`e203_hbirdv2`. The goal is to keep a clear two-layer structure:

- a stable formal line for reporting, recovery, and stage delivery
- a current active development line for ongoing A7-100T / Route-A bring-up work

## Current Branch Roles

| Repository | Branch | Role | Continue daily development | Paired branch |
|------------|--------|------|----------------------------|---------------|
| `riscv_cnn_accelerator` | `main` | Historical default line | No | `e203_hbirdv2:master` |
| `riscv_cnn_accelerator` | `bringup_v1` | Stable formal line | Limited to stability, docs, and stage summaries | `e203_hbirdv2:cnn_bringup_v1` |
| `riscv_cnn_accelerator` | `codex/a7-bringup-v2-main` | Current active development line | Yes | `e203_hbirdv2:codex/a7-bringup-v2-soc` |
| `e203_hbirdv2` | `master` | Historical default line | No | `riscv_cnn_accelerator:main` |
| `e203_hbirdv2` | `cnn_bringup_v1` | Stable formal line | Limited to stability, docs, and stage summaries | `riscv_cnn_accelerator:bringup_v1` |
| `e203_hbirdv2` | `codex/a7-bringup-v2-soc` | Current active development line | Yes | `riscv_cnn_accelerator:codex/a7-bringup-v2-main` |

## Branch Snapshot

| Repository | Branch | Role | Recent commit date | Recent commit title | Continue daily development | Paired branch |
|------------|--------|------|--------------------|---------------------|----------------------------|---------------|
| `riscv_cnn_accelerator` | `main` | Historical default line | 2026-03-26 | `docs: reorganize project docs and unify v1.9 package` | No | `e203_hbirdv2:master` |
| `riscv_cnn_accelerator` | `bringup_v1` | Stable formal line | 2026-03-27 | `Simplify project documentation structure` | Limited | `e203_hbirdv2:cnn_bringup_v1` |
| `riscv_cnn_accelerator` | `codex/a7-bringup-v2-main` | Current active development line | 2026-04-10 | `freeze: finalize A7 route-a v2.0 snapshot` | Yes | `e203_hbirdv2:codex/a7-bringup-v2-soc` |
| `e203_hbirdv2` | `master` | Historical default line | 2025-08-06 | `doc: add information about wechat group (#31)` | No | `riscv_cnn_accelerator:main` |
| `e203_hbirdv2` | `cnn_bringup_v1` | Stable formal line | 2026-03-26 | `Add Davinci A7-35T FPGA shell` | Limited | `riscv_cnn_accelerator:bringup_v1` |
| `e203_hbirdv2` | `codex/a7-bringup-v2-soc` | Current active development line | 2026-04-10 | `fpga: add A7-100T route-a bring-up baseline` | Yes | `riscv_cnn_accelerator:codex/a7-bringup-v2-main` |

## Cross-Repository Branch Mapping

The expected paired branch relationships are:

- `bringup_v1` ↔ `cnn_bringup_v1`
- `codex/a7-bringup-v2-main` ↔ `codex/a7-bringup-v2-soc`
- `main` ↔ `master`

When one repository is checked out on a stable or active line, the other
repository should normally be checked out on the matching paired line.

## Usage Rules

- Do not treat `main` or `master` as the current engineering entry point.
- Use the stable formal lines for stable documentation cleanup, reporting,
  baseline restoration, and stage summaries.
- Use the active development lines for the live A7-100T / Route-A bring-up
  stream, including UART, LED, and ILA evidence-chain work.
- Avoid mixing experimental work directly into the stable formal lines unless
  the work has already been validated and is being packaged for reporting.
- Keep both repositories aligned by updating the paired stable or active
  branches together when documenting a shared milestone.

## Upgrade Path Recommendation

Do not create new `v2` baseline branches yet unless both repositories have
settled and the active Route-A line is serving as the de facto stable baseline.

When the current active line is stable enough, promote it by cutting:

- `codex/a7-bringup-v2-main` -> `bringup_v2`
- `codex/a7-bringup-v2-soc` -> `cnn_bringup_v2`

This keeps `v1` as the formal historical milestone while leaving the active
branch free for further bring-up work until the snapshot is truly ready.

## Future Branch Naming Recommendations

Use branch names that expose three things as early as possible:

- layer or role, such as `stable`, `active`, or `experiment`
- target, such as `a7-100t-route-a`, `uart-ila`, or `bringup`
- version or milestone, such as `v2` or `v2_1`

For paired branches across the two repositories, keep the same shared prefix
and let only the repository-role suffix differ when necessary.

Recommended examples:

- `stable/bringup-v2-main` and `stable/bringup-v2-soc`
- `active/a7-100t-route-a-v2-main` and `active/a7-100t-route-a-v2-soc`
- `experiment/uart-ila-evidence-v2-main` and `experiment/uart-ila-evidence-v2-soc`
