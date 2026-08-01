# Paired release record

Release records for `env-baseline-2026-07-27` and `mphil-nice-v2-poc-v0.1.0` must include:

- accelerator repository, branch, and immutable commit SHA;
- `e203_hbirdv2` branch and immutable commit SHA;
- the matching tag in both repositories;
- CI run links and the exact commands run from a clean checkout;
- Full-SoC, Vivado, UART, JTAG, ILA, and board status as `passed`, `failed`, or `not run`;
- explicit scope exclusions from [`showcase/README.md`](showcase/README.md).

Do not fill the final SHAs until the stacked baseline and PoC PRs are merged. Never move an existing tag to correct a record; publish a new patch version instead.
