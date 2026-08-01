#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RECORD_DIR="${ROOT_DIR}/docs/benchmarks/records"

usage() {
  cat <<'EOF'
Usage:
  scripts/new_benchmark_record.sh short-name

Example:
  scripts/new_benchmark_record.sh line-buffer-smoke
EOF
}

slug="${1:-}"
if [[ -z "${slug}" || "${slug}" == "-h" || "${slug}" == "--help" ]]; then
  usage
  exit 0
fi

safe_slug="$(printf '%s' "${slug}" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-')"
safe_slug="${safe_slug#-}"
safe_slug="${safe_slug%-}"
if [[ -z "${safe_slug}" ]]; then
  echo "[BENCHMARK_ERROR] short-name must contain at least one ASCII letter or digit" >&2
  exit 1
fi

mkdir -p "${RECORD_DIR}"

stamp="$(date +%Y%m%d_%H%M%S)"
record_path="${RECORD_DIR}/${stamp}_${safe_slug}.md"

branch="$(git -C "${ROOT_DIR}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
commit="$(git -C "${ROOT_DIR}" rev-parse --short HEAD 2>/dev/null || echo unknown)"

cat > "${record_path}" <<EOF
# Benchmark Record: ${safe_slug}

> Created: $(date '+%Y-%m-%d %H:%M:%S %z')
> Branch: ${branch}
> Commit: ${commit}

## Scope

- Experiment:
- Platform: E203 + NICE + A7-100T
- Flow: RTL / FullSoC / board UART / board ILA / full network
- Design change:

## Commands

\`\`\`bash
# Paste the exact commands used for this run.
\`\`\`

## Correctness

| Item | Value |
| --- | --- |
| Expected output | TBD |
| Actual output | TBD |
| Pass/fail | TBD |
| Reference model compared | TBD |

## Performance

| Metric | Value |
| --- | --- |
| CPU-only cycles | TBD |
| Accelerator cycles | TBD |
| Speedup | TBD |
| Benchmark scope | TBD |

## Hardware Cost

| Metric | Value |
| --- | --- |
| LUT | TBD |
| FF | TBD |
| BRAM | TBD |
| DSP | TBD |
| WNS | TBD |
| WHS | TBD |

## Logs And Artifacts

- UART log:
- ILA summary:
- Simulation log:
- Bitstream or build report:

## Claim Boundary

- This record proves:
- This record does not prove:
- Full LeNet-5 / full MNIST claim allowed: no

EOF

echo "[BENCHMARK_RECORD] ${record_path}"
