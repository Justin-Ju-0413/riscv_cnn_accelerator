# Day 3-4: hello_e203 Board Validation Closure

Date: 2026-04-30

## Result: SUCCESS

hello_e203 runs on Davinci Pro A7-100T FPGA with full evidence chain:
MROM → ITCM → hello_e203 → UART output

## UART Output

```
hello_e203: boot
hello_e203: uart ok
hello_e203: loop
```

## ILA Evidence

| Probe | Value | Meaning |
|-------|-------|---------|
| PC | 0x800000a0-0x800000be | Executing in ITCM |
| mem_cmd_addr | 0x10012008 | GPIOA access (set_stage LED) |
| uart_tx_edge_seen | 1 | UART TX activity detected |
| gpio17_oe | 1 | GPIO17 configured for UART TX |

## Four Root Causes Fixed

| # | Root Cause | File | Fix | Scope |
|---|-----------|------|-----|-------|
| 1 | `qout_r <= #1 dnxt` in sirv_gnrl_dffs.v | sirv_gnrl_dffs.v | Remove #1 transport delay | Simulation only (iverilog) |
| 2 | ITCM hex byte-level format vs 64-bit BRAM | Convert-VerilogHex.ps1 | Pack 4 bytes → 32-bit LE, 2×32→64-bit | Sim + Board |
| 3 | DTCM hex byte-level format vs 32-bit BRAM | Convert-VerilogHex.ps1 | Pack 4 bytes → 32-bit LE | Sim + Board |
| 4 | `E203_FORCE_BOOTROM_BOOT` not globally visible | prologue.tcl | `set_property verilog_define` | Board (Vivado) |

## Key Technical Discoveries

1. **probe_ifu_* monitors ITCM path only**: MROM boot goes through BIU → system memory bus.
   Fixed by switching probes to monitor system memory bus (probe_mem_cmd/ready/rsp).

2. **vivado $readmemh reads hex words, not bytes**: objcopy -O verilog produces byte-level hex,
   but both iverilog and Vivado $readmemh interpret each whitespace-separated token as a full
   memory word. For 64-bit ITCM, each word is 16 hex digits. For 32-bit DTCM, 8 hex digits.

3. **sirv_aon_wrapper.v has no `include "e203_defines.v"`**: The `ifdef E203_FORCE_BOOTROM_BOOT`
   in this file is invisible to Vivado's file-scope macro processing. Fixed by adding global
   verilog_define in prologue.tcl.

4. **Simulation confirmed board behavior exactly**: The iverilog simulation reproduced the
   PC=0 behavior identically, enabling rapid root cause analysis.

## Repos & Commits

- e203_hbirdv2: `codex/a7-bringup-v2-soc` @ `c20ce47`
- riscv_cnn_accelerator: `codex/a7-bringup-v2-main` @ `d817dc0`

## Evidence Path

```
04_Experiments/Board_BringUp/2026-04-28_board_connection_check/
├── hello_e203_board_artifacts/
│   ├── system.bit
│   ├── system.ltx
│   ├── ila_capture.csv
│   ├── ila_summary.txt
│   ├── uart_output.txt
│   └── conclusion.txt
├── bootvec_sysclk_ila_artifacts/
└── bootvec_sysclk_ila_ila_capture/
```

## Next: Day 5 CNN/NICE Board Validation

cnn_accel_demo binary needs rebuild from source with Nuclei SDK.
Infrastructure ready: RISC-V GCC + SDK on Ubuntu, Convert-VerilogHex.ps1 for ITCM/DTCM.
