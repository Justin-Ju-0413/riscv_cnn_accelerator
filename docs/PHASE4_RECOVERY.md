# Phase 4 Recovery And Regression Flow

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## Goal

Make the current Phase 3 closure reproducible without relying on hidden local state.

## What Phase 4 Packages

- A portable SDK patch export:
  - [patches/nuclei-sdk-phase3-e203-safe.patch](/home/gstar/Desktop/riscv_cnn_accelerator/patches/nuclei-sdk-phase3-e203-safe.patch)
- A helper to apply that patch to a clean `nuclei-sdk` checkout:
  - [scripts/apply_nuclei_sdk_phase3_patch.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/apply_nuclei_sdk_phase3_patch.sh)
- A one-command regression entry that rebuilds the SDK app and runs the official full-SoC E203 simulation:
  - [scripts/run_sdk_fullsoc_regression.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh)

## Required Local Layout

- Main repo:
  - `/home/gstar/Desktop/riscv_cnn_accelerator`
- SoC repo:
  - `/home/gstar/Desktop/e203_hbirdv2`
- Official Nuclei GNU toolchain:
  - default expected path: `/home/gstar/Desktop/gcc`
- Nested SDK checkout under the main repo:
  - `/home/gstar/Desktop/riscv_cnn_accelerator/third_party/nuclei-sdk`

The scripts support overrides through `SDK_DIR`, `SOC_DIR`, and `RISCV_GCC_ROOT` if another machine uses different absolute paths.

## Recovery Procedure On A Fresh Machine

1. Clone the two repositories.
2. Place or clone `nuclei-sdk` at `third_party/nuclei-sdk`.
3. Place the official Nuclei GNU toolchain at `/home/gstar/Desktop/gcc`, or export `RISCV_GCC_ROOT` to the actual location.
4. Run:

```bash
bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh
```

The runner will:
- apply the portable SDK patch if needed
- rebuild `cnn_accel_demo.elf`
- regenerate `cnn_accel_demo.verilog`
- split the image into ITCM/DTCM payloads
- launch the official E203 full-SoC simulation
- fail if `RSTAT=320` is not observed

## Expected Pass Signals

A passing run should show both of the following in the final log:

```text
[NICE_RSP] ... rdat=320 err=0
[NICE_SUMMARY] ... rstat_320_seen=1
```

Validated locally on 2026-03-21. The runner also prints:

```text
[PHASE4_PASS] sdk build, image split, and full-SoC regression passed
```

## Notes

- The local `third_party/nuclei-sdk` repository still has its own independent git history.
- The exported patch is the Phase 4 portability bridge for that nested repository state.
- `run_nice_light.sh` remains the fast gate for RTL/NICE smoke testing.
- `run_nice_patch.sh` remains the underlying official full-SoC wrapper used by the Phase 4 regression script.
