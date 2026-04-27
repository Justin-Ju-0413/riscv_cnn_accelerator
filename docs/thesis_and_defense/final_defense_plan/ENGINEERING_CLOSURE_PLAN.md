# Engineering Closure Plan

## Goal

Close the minimum engineering loop from software image to FPGA runtime evidence.

## Stage A: Freeze Current Baseline

Commands on Ubuntu:

```bash
cd ~/Desktop/riscv_cnn_accelerator
./Project_Manager.sh run_hw
bash scripts/run_sdk_fullsoc_regression.sh
```

Expected results:

- `[TB_PASS] mock NICE regression completed`
- `expected_rstat=19`
- `[PHASE4_PASS] sdk build, image split, and full-SoC regression passed`

## Stage B: hello_e203 Board Runtime Test

Purpose:

- Verify CPU boot, ITCM initialization, UART path, reset release, and LED stage marker before running CNN/NICE.

Build flow:

```bash
cd ~/Desktop/riscv_cnn_accelerator
SDK_APP=hello_e203 ./Project_Manager.sh install_sdk_app
cd third_party/nuclei-sdk/application/baremetal/hello_e203
make clean all CORE=n300 DOWNLOAD=ilm
make hello_e203.verilog CORE=n300 DOWNLOAD=ilm
~/Desktop/e203_hbirdv2/tb/split_sdk_verilog.sh hello_e203.verilog
```

Bitstream flow:

```bash
cd ~/Desktop/e203_hbirdv2/fpga/davinci_a7_100t
make clean
make bit SDK_APP_VERILOG=/home/gstar/Desktop/riscv_cnn_accelerator/third_party/nuclei-sdk/application/baremetal/hello_e203/hello_e203.verilog
```

Expected evidence:

- UART prints `hello_e203` or staged boot messages.
- LED0 reaches the pass stage.
- ILA shows PC movement after reset.

## Stage C: cnn_accel_demo Board Runtime Test

Purpose:

- Verify software baseline, accelerator call, result comparison, cycle count, and speedup on board.

Build flow:

```bash
cd ~/Desktop/riscv_cnn_accelerator
SDK_APP=cnn_accel_demo ./Project_Manager.sh install_sdk_app
cd third_party/nuclei-sdk/application/baremetal/cnn_accel_demo
make clean all CORE=n300 DOWNLOAD=ilm
make dasm CORE=n300 DOWNLOAD=ilm
make cnn_accel_demo.verilog CORE=n300 DOWNLOAD=ilm
~/Desktop/e203_hbirdv2/tb/split_sdk_verilog.sh cnn_accel_demo.verilog
```

Bitstream flow:

```bash
cd ~/Desktop/e203_hbirdv2/fpga/davinci_a7_100t
make clean
make bit SDK_APP_VERILOG=/home/gstar/Desktop/riscv_cnn_accelerator/third_party/nuclei-sdk/application/baremetal/cnn_accel_demo/cnn_accel_demo.verilog
```

Expected evidence:

- UART prints software reference output.
- UART prints accelerator output.
- Outputs match expected values.
- Cycle summary appears.
- ILA shows NICE CSR or request/response activity.

## Debug Priority

If UART is silent:

1. Check reset release.
2. Check whether Vivado programmed the latest `system.bit`.
3. Check `e203_fpga_mem_init.vh`.
4. Check ILA PC movement.
5. Check UART COM port and baud rate.

If UART works but CNN does not:

1. Recheck `run_hw`.
2. Recheck full-SoC regression.
3. Compare UART result with `expected_rstat=19`.
4. Inspect NICE handshake in ILA.

