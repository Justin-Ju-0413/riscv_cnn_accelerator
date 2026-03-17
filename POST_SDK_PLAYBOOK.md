# Post-SDK Playbook

Run this only after the Nuclei SDK and cross toolchain are installed.

## 1. Environment
1. Copy `sw/build/sdk_env.sh.template` to `sw/build/sdk_env.sh`.
2. Update `NUCLEI_SDK_ROOT`, `RISCV_GCC_ROOT`, and `CROSS_COMPILE`.
3. Source the file:

```bash
source sw/build/sdk_env.sh
```

## 2. Lock Project Settings
1. Open `INTEGRATION_DECISIONS.md`.
2. Fill in the actual E203 baseline, board, operand path, and toolchain triplet.
3. Update `sw/sdk_project/config/project.mk` with the real board/core values.

## 3. First SDK Build Bring-Up
1. Copy `sw/sdk_project/Makefile.template` to `sw/sdk_project/Makefile`.
2. Adjust `SDK_MAKEFILE` if your installed SDK uses a different path.
3. Build the SDK app from `sw/sdk_project/`.
4. Confirm that `application/main.c` still exercises:
   - `ACC_CLEAR`
   - `ACC_WLOAD`
   - `ACC_DLOAD`
   - `ACC_COMP`
   - `ACC_RSTAT`

## 4. First SoC Wiring Step
1. Use `hw/rtl/soc_wrapper/e203_cnn_nice_soc_wrap.v` as the SoC integration boundary.
2. Connect NICE request/response signals first.
3. Keep NICE ICB sideband tied off until register-fed bring-up passes.
4. Only after that, decide whether to replace register-fed operand loading with ICB fetches.

## 5. First Regression Set
Run these in order:

```bash
./Project_Manager.sh precheck
./Project_Manager.sh run_hw
```

Then run the first SDK build in `sw/sdk_project/`.

## 6. Expected Early Failures
- Missing SDK variables
- Wrong board name in `project.mk`
- Wrong toolchain prefix
- SDK Makefile path mismatch
- SoC branch port mismatch against the chosen E203 baseline
