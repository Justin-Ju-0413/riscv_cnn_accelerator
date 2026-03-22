# E203/NICE Integration Preparation

This repository now includes a Nuclei-aligned NICE top module at `hw/rtl/acc/cnn_nice_core.v` and an E203-facing harness at `hw/tb/e203_nice_harness.v`.

## What Is Aligned
- Request channel names match the documented NICE form: `nice_req_valid`, `nice_req_ready`, `nice_req_instr`, `nice_req_rs1`, `nice_req_rs2`.
- Response channel includes `nice_rsp_valid`, `nice_rsp_ready`, `nice_rsp_rdat`, and `nice_rsp_err`.
- NICE memory sideband ports are present: `nice_mem_holdup`, `nice_icb_cmd_*`, and `nice_icb_rsp_*`.
- The simulation harness now drives the accelerator through an E203-style boundary instead of instantiating the accelerator core directly in the testbench.

## What Is Intentionally Stubbed
- The accelerator currently uses only register operands and internal PE storage, so `nice_mem_holdup` and `nice_icb_cmd_valid` are tied low.
- `nice_rsp_err` is only used for basic integration guards today: unsupported opcode and unsupported `funct3` return an error response.
- No multicycle compute busy state is modeled yet beyond pending `RSTAT` response ownership.

## Remaining Work Before Real Hummingbird E203 v2 Integration
- Verify exact port list and optional signals against the specific E203 branch you will integrate.
- Confirm instruction decode policy with the SoC-side custom extension enablement.
- Decide whether weights/activations remain register-fed or move to NICE memory transactions.
- Add illegal instruction / bounds checks if the core integration requires defensive behavior.
