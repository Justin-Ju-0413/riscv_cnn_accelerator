# 2026-04-23 Full-SoC Baseline Rerun

## Status

Pending. Ubuntu SSH was not reachable during the setup pass on Windows.

## Command To Run

```bash
cd ~/Desktop/riscv_cnn_accelerator
bash scripts/run_sdk_fullsoc_regression.sh
```

## Expected Evidence

- `expected_rstat = 19`
- `[NICE_RSP] ... rdat=19 err=0`
- `[NICE_SUMMARY] ... expected_rstat=19`
- `[PHASE4_PASS] sdk build, image split, and full-SoC regression passed`

## Where To Save Results

Save terminal screenshots and logs in this folder.
