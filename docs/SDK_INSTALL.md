# SDK Installation Notes

## Installed In This Workspace
- Nuclei SDK source cloned into `third_party/nuclei-sdk`
- Current local SDK commit: `2fd229c`
- SDK-side setup template added at `third_party/nuclei-sdk/setup_config.sh.template`

## Important Version Note
- The cloned SDK README states that recent SDK releases require Nuclei Studio or
  Nuclei tools `2025.02`.
- It also states that for 2023.10 and later tools, the GCC prefix changed from
  `riscv-nuclei-elf-` to `riscv64-unknown-elf-`.

## What Is Still Not Installed
- Nuclei RISC-V toolchain
- OpenOCD/QEMU/Nuclei model bundle
- Nuclei Studio IDE, if you choose the IDE-based route

## Official Tool Requirement
- The SDK quick-start documentation says SDK `0.8.0` and later require Nuclei Studio
  or Nuclei Toolchain/OpenOCD/QEMU `2025.02`.
- The same docs note that since toolchain `2023.10`, the expected GNU prefix is
  `riscv64-unknown-elf-`.

## Local Helper
To stage this project as a Nuclei SDK baremetal application after the toolchain is ready:

```bash
chmod +x sw/build/install_sdk_app.sh
./sw/build/install_sdk_app.sh
```

This copies the prepared demo into:

```text
third_party/nuclei-sdk/application/baremetal/cnn_accel_demo
```
