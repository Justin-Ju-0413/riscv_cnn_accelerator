# Branch Strategy

> Snapshot date: 2026-07-27 (Asia/Shanghai)

This snapshot reflects the branches that actually exist on GitHub. The
accelerator and SoC default branches have diverged from the validated
engineering branches, so this maintenance cycle does not merge or force-update
either `main`.

## Current Branches

| Repository | Branch | Role | Use for new engineering work |
|------------|--------|------|------------------------------|
| `riscv_cnn_accelerator` | `main` | Default historical line | No |
| `riscv_cnn_accelerator` | `bringup_v1` | Retained stable milestone | Recovery/reporting only |
| `riscv_cnn_accelerator` | `codex/a7-bringup-v2-main` | Validated FYP engineering baseline | Yes |
| `e203_hbirdv2` | `main` | Default/upstream-oriented line | No |
| `e203_hbirdv2` | `codex/a7-bringup-v2-soc` | Validated paired SoC baseline | Yes |

The former SoC branches `master` and `cnn_bringup_v1` no longer exist on the
remote and must not be used in setup instructions.

## Active Pair

- Accelerator: `codex/a7-bringup-v2-main`
- SoC: `codex/a7-bringup-v2-soc`

These branches contain the A7-100T bring-up, CNN/NICE board evidence, and NICE
`rs2` decoder fix. Keep them paired whenever a change affects both
repositories.

## Maintenance Branches

The 2026-07-27 reproducibility update uses:

- `riscv_cnn_accelerator:codex/env-baseline-20260727`
- `e203_hbirdv2:codex/env-baseline-20260727-soc`

Each branch targets its corresponding active engineering branch through a
Draft PR. Neither PR targets `main`.

## Rules

- Do not merge or force-update either `main` as part of a documentation or
  environment-maintenance change.
- Do not re-create removed branches merely to match old documentation.
- Keep RTL/API changes out of reproducibility-only branches.
- Stage explicit files; do not include generated Vivado, simulation, UART, or
  ILA artifacts unless they are intentional benchmark evidence.
- Preserve the claim boundaries documented in `CURRENT_STATE.md`.
- After the environment baseline is reproducible, create a new research branch
  for Attention/MatMul or Vision Mamba work rather than extending this
  maintenance branch indefinitely.

## Future Promotion

Promotion of the active branches to new stable/default branches is a separate
release task. It requires a reviewed cross-repository diff, a complete
regression run, and an explicit decision about the diverged `main` commits.
