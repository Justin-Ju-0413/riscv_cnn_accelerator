# Pre-SDK Checklist

Use this checklist before installing Nuclei SDK or the RISC-V toolchain.

## 1. Hardware Boundary
- [x] NICE request/response top module exists: `hw/rtl/acc/cnn_nice_core.v`
- [x] SoC-facing wrapper exists: `hw/rtl/soc_wrapper/e203_cnn_nice_soc_wrap.v`
- [x] E203-style harness exists: `hw/tb/e203_nice_harness.v`
- [x] Illegal opcode and unsupported `funct3` return an error response

## 2. Functional Verification
- [x] Local RTL simulation passes through `./Project_Manager.sh run_hw`
- [x] Response backpressure is covered in the testbench
- [x] Weight and activation loading are independently verified

## 3. Software Preparation
- [x] Custom instruction header exists: `sw/inc/custom_insn.h`
- [x] Firmware demo uses `CLEAR/WLOAD/DLOAD/COMP/RSTAT`
- [x] SDK environment template exists: `sw/build/sdk_env.sh.template`
- [x] SDK project skeleton exists: `sw/sdk_project/`
- [ ] Cross toolchain installed
- [ ] Nuclei SDK installed

## 4. Integration Decisions Still Required
- [ ] Confirm exact E203 branch and board/SoC target
- [ ] Decide whether activations/weights stay register-fed or move to NICE ICB fetches
- [ ] Decide firmware loading flow: simulation memory, on-chip SRAM, or FPGA image
- [ ] Confirm trap/illegal-instruction policy expected by the target SoC
- [x] Decision matrix template exists: `INTEGRATION_DECISIONS.md`
- [x] Post-install execution playbook exists: `POST_SDK_PLAYBOOK.md`

## 5. Local Command
Run:
```bash
./Project_Manager.sh precheck
```
