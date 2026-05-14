# 2026-04-28 Board Connection Check

## Goal

Start today's board-side work after the FPGA development board was connected.

## Checked From Windows

- Vivado launcher found:
  - `D:\Xilinx\Vivado\2023.2\bin\vivado.bat`
- Main repo status:
  - `riscv_cnn_accelerator`: `codex/a7-bringup-v2-main`
  - clean before today's script/doc additions
- SoC repo status:
  - `e203_hbirdv2`: `codex/a7-bringup-v2-soc`
  - clean

## Vivado Hardware Result

Vivado could start `hw_server` and found a Digilent target:

- `localhost:3121/xilinx_tcf/Digilent/210512180081`

Initial attempt: opening the target failed with:

```text
No devices detected on target localhost:3121/xilinx_tcf/Digilent/210512180081.
```

Interpretation:

- Windows/Vivado can see the USB JTAG adapter.
- The FPGA device is not visible on the JTAG chain yet.
- This usually points to board power, JTAG wiring, board mode/switch setting, or cable seating.

After reconnecting the board, Vivado detected the FPGA successfully:

```text
HW_DEVICES=xc7a100t_0
HW_DEVICE=xc7a100t NAME=xc7a100t_0
CHECK_PASS: xc7a100t_0 detected
```

Updated interpretation:

- FPGA JTAG programming path is now visible.
- The next board blocker is UART/device driver health and the missing local bitstream/image artifacts.

## UART / COM Result

Windows Ports list currently shows only Bluetooth COM ports.

Relevant USB device status:

```text
USB Serial Converter: OK
USB Serial: Error
```

Interpretation:

- The FTDI/Digilent-style JTAG-side USB device is visible.
- The CH340/USB-UART-side device appears with an error state.
- UART evidence cannot be collected until the USB-UART driver/device is healthy and a real COM port appears.

## Earlier Blocker Before GitHub/Windows Flow

Board runtime evidence initially could not start because:

1. Windows UART is not exposing a healthy board COM port.
2. No local `system.bit` was found under the current Windows workspace.
3. The Windows `third_party/nuclei-sdk` directory is empty, so software image artifacts must be rebuilt on Ubuntu or copied back from Ubuntu.

## 2026-04-28 Update After GitHub/Windows Flow

The earlier blocker state changed after the GitHub-managed Windows flow was implemented.

Closed items:

1. `system.bit` was rebuilt locally through Windows Vivado.
2. JTAG detected `xc7a100t_0`.
3. FPGA programming passed.
4. Windows now exposes `USB-SERIAL CH340 (COM11)` with status `OK`.

Still open:

1. UART capture at `COM11`, 115200 baud, returned no text after reprogramming.
2. The next debug target is runtime visibility: reset release, PC activity, UART TX pin activity, and whether the preloaded CNN image starts as expected.

Latest commit pair:

- `riscv_cnn_accelerator`: `b414e36399ba6d301497a9f03341bd7c880ed779`
- `e203_hbirdv2`: `afbf0c4d4ac282166b5be710b9e42d2f672c6e44`

Detailed evidence:

- `BOARD_RUNTIME_EVIDENCE_2026_04_28.md`

## 2026-04-28 ILA Follow-Up

Vivado now associates the generated probes file successfully:

```text
HW_ILAS=hw_ila_1
HW_PROBES=probe_csr_flags probe_mem_bus probe_nice_csr_addr probe_nice_csr_wdata probe_nice_hs probe_pc probe_status
```

However, waveform upload fails:

```text
ILA_UPLOAD_FAILED=ERROR: [Labtools 27-3312] Data read from hw_ila [hw_ila_1] is corrupted. Unable to upload waveform.
ILA_CAPTURE_STATUS=UPLOAD_FAILED
```

After changing the ILA sample clock to `clk_16M`, UART capture is still empty:

```text
UART_CAPTURE_EMPTY_AFTER_ILA_CLOCK_CHANGE
```

Current blocker:

- runtime evidence is blocked by clock/reset/timing/debug-hub reliability, not by GitHub synchronization or missing bitstream generation.

## 2026-04-28 Heartbeat Isolation Follow-Up

Two minimal heartbeat build modes were added and pushed:

- `heartbeat`: MMCM -> `clk_16M` counter, LED, and ILA.
- `heartbeat_direct`: raw `sys_clk` counter, LED, and ILA, bypassing MMCM/reset IP.

Commit pair:

- `riscv_cnn_accelerator`: `2028fee0a2d98063a987a04df808877a8aa2fe48`
- `e203_hbirdv2`: `bf87a17b923faed0df640b8271631fc145b6b01b`

Results:

```text
heartbeat build: write_bitstream completed successfully
heartbeat ILA: ILA_CAPTURE_STATUS=UPLOAD_FAILED
heartbeat_direct build: write_bitstream completed successfully
heartbeat_direct ILA: ILA_CAPTURE_STATUS=CAPTURED
```

The captured direct-clock CSV shows `probe0_counter` incrementing:

```text
01595fdb
01595fdc
01595fdd
01595fde
```

Updated interpretation:

- JTAG, Vivado programming, raw board `sys_clk`, debug hub, and ILA upload are functional in the direct-clock design.
- The remaining board-side suspect is now narrower: MMCM-derived `clk_16M`, reset release from `reset_sys`, or interactions between that clock/reset path and the CPU design.

Evidence:

- `heartbeat_direct_ila_capture\ila_summary.txt`
- `heartbeat_direct_ila_capture\ila_capture.csv`
- `heartbeat_direct_artifacts\heartbeat_direct_system.bit`
- `heartbeat_direct_artifacts\heartbeat_direct_system.ltx`
- `heartbeat_direct_artifacts\heartbeat_direct_timing_summary_routed.rpt`

## 2026-04-28 MMCM/Reset Isolation Follow-Up

Two additional build modes were added and pushed:

- `heartbeat_mmcm_ledonly`: MMCM `clk_out2` -> `clk_16M` -> `reset_sys` -> LED counter, no ILA.
- `heartbeat_mmcm_dualclk`: MMCM `clk_out1` drives ILA/debug, MMCM `clk_out2` drives the `clk_16M` heartbeat counter, with a mode-specific false path for the intentional CDC observation.

Commit pair:

- `riscv_cnn_accelerator`: `7b30969020caa6eefb9a631ba3989c0ba57797b7`
- `e203_hbirdv2`: `f6610c9cd87c3d4c6961c86269c13b061bb949ed`

Results:

```text
heartbeat_mmcm_ledonly build: write_bitstream completed successfully
heartbeat_mmcm_ledonly timing: WNS=60.386 ns, constraints met
heartbeat_mmcm_ledonly program: PROGRAM_PASS
heartbeat_mmcm_ledonly LED: PASS, visually confirmed blinking on board

heartbeat_mmcm_dualclk build: write_bitstream completed successfully
heartbeat_mmcm_dualclk timing after CDC false path: WNS=27.913 ns, constraints met
heartbeat_mmcm_dualclk program/capture: ILA core and probes detected
heartbeat_mmcm_dualclk ILA: ILA_CAPTURE_STATUS=UPLOAD_FAILED
```

Updated interpretation:

- MMCM/reset-only logic can build, route, and program cleanly.
- The board LED confirms the MMCM `clk_out2` -> `clk_16M` -> `reset_sys` -> counter path is running in hardware.
- The previous dualclk timing failure was a constraint issue from the intentional `clk_16M` -> ILA clock observation path; after constraining it, timing closes.
- ILA upload still fails when the ILA/debug path is clocked from an MMCM output, even with timing met.
- Since `heartbeat_direct` ILA capture succeeds from raw `sys_clk`, the next suspect is the interaction between MMCM-derived clocking and Vivado debug hub/ILA upload, not JTAG or bitstream programming.
- A new `heartbeat_mmcm_sysclk_ila` build mode has been added so the ILA/debug hub stays on raw `sys_clk` while synchronized MMCM/reset/heartbeat status is observed from that debug domain.

Evidence:

- `heartbeat_mmcm_ledonly_artifacts\heartbeat_mmcm_ledonly_system.bit`
- `heartbeat_mmcm_ledonly_artifacts\heartbeat_mmcm_ledonly_timing_summary_routed.rpt`
- `heartbeat_mmcm_dualclk_artifacts\heartbeat_mmcm_dualclk_system.bit`
- `heartbeat_mmcm_dualclk_artifacts\heartbeat_mmcm_dualclk_system.ltx`
- `heartbeat_mmcm_dualclk_artifacts\heartbeat_mmcm_dualclk_timing_summary_routed.rpt`
- `heartbeat_mmcm_dualclk_ila_capture\ila_summary.txt`

Raw `sys_clk` ILA diagnostic build:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -BuildMode heartbeat_mmcm_sysclk_ila -Action bit
```

Result:

```text
heartbeat_mmcm_sysclk_ila build: write_bitstream completed successfully
heartbeat_mmcm_sysclk_ila timing: WNS=13.887 ns, constraints met
heartbeat_mmcm_sysclk_ila program/capture: PROGRAM_PASS, ILA_CAPTURE_STATUS=CAPTURED
heartbeat_mmcm_sysclk_ila sys_clk evidence: probe0_sysclk_counter 01640b7d -> 01640f7c
heartbeat_mmcm_sysclk_ila clk_16M evidence: probe3_clk16_edges 0000e3da -> 0000e3dd
heartbeat_mmcm_sysclk_ila reset evidence: probe1_reset=c, probe6_status=4
```

Evidence:

- `heartbeat_mmcm_sysclk_ila_artifacts\`
- `heartbeat_mmcm_sysclk_ila_ila_capture\ila_summary.txt`
- `heartbeat_mmcm_sysclk_ila_ila_capture\ila_capture.csv`

Updated interpretation:

- Raw `sys_clk` ILA/debug hub upload works while observing synchronized MMCM/reset/`clk_16M` state.
- MMCM locked and `reset_sys` released on hardware.
- The previous upload corruption is specific to the MMCM-clocked ILA/debug path, not the MMCM heartbeat path and not JTAG/programming.

## Full SoC Raw `sys_clk` ILA Diagnostic

New baseline commit pair:

- `riscv_cnn_accelerator`: `f75e04a6969ecbfd0fa2eb2b4055670a6785bc50`
- `e203_hbirdv2`: `3ea17fbbfba7f0ce600ea8c5500bdf7b7de418df`

Build command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -BuildMode soc_sysclk_ila -Action bit
```

Result:

```text
soc_sysclk_ila build: write_bitstream completed successfully
soc_sysclk_ila timing: WNS=13.515 ns, WHS=0.058 ns, no failing endpoints
soc_sysclk_ila program/capture: PROGRAM_PASS, ILA_CAPTURE_STATUS=CAPTURED
soc_sysclk_ila probes: probe0_pc probe1_reset_uart probe2_liveness probe3_pc_activity probe4_nice_csr probe5_nice_hs probe6_mem_status
soc_sysclk_ila reset/UART evidence: probe1_reset_uart=d
soc_sysclk_ila PC activity evidence: probe3_pc_activity 000ed645 -> 000ed671
soc_sysclk_ila sampled PC: probe0_pc observed 00000000 and 00000002
soc_sysclk_ila liveness evidence: probe2_liveness observed 0 and 4
soc_sysclk_ila NICE evidence: probe5_nice_hs=4
soc_sysclk_ila memory status evidence: probe6_mem_status observed 1, 3, and 5
```

Evidence:

- `soc_sysclk_ila_artifacts\`
- `soc_sysclk_ila_ila_capture\ila_summary.txt`
- `soc_sysclk_ila_ila_capture\ila_capture.csv`

Updated interpretation:

- Full SoC raw `sys_clk` ILA/debug upload is reliable on board.
- `probe1_reset_uart=d` means `sys_rst_n=1`, synchronized `mmcm_locked=1`, synchronized `reset_periph=0`, and sampled UART TX high.
- The PC activity counter increments and `probe2_liveness` shows PC-change events, while the sampled PC bus only exposed `00000000`/`00000002` in this capture, so the next debugging step should treat activity/handshake counters as the reliable liveness indicators and avoid over-interpreting one asynchronous PC bus snapshot.
- Reset release is not the blocker. Next analysis should focus on boot/PC visibility, memory bus activity, NICE handshake, UART TX behavior, and whether the PC probe wiring represents the intended architectural PC.

Day 1 follow-up conclusion:

- `probe_pc` is traced to `e203_ifu_ifetch.pc_r` through `e203_core.inspect_pc`.
- This is IFU fetch-side inspect PC, not commit-stage PC.
- `probe0_pc=00000000/00000002` should be treated as limited IFU PC sampling evidence.
- Day 2 should add fetch/ITCM request-response counters, UART TX edge counter, reset-release status, halt/cgstop status, and a real trap/exception indicator if available.

## CPU Boot Diagnostic Raw `sys_clk` ILA

Diagnostic build mode:

- `soc_bootdiag_sysclk_ila`

Build command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -BuildMode soc_bootdiag_sysclk_ila -Action bit
```

Result:

```text
soc_bootdiag_sysclk_ila build: write_bitstream completed successfully
soc_bootdiag_sysclk_ila timing: WNS=13.337 ns, WHS=0.039 ns, no failing endpoints
soc_bootdiag_sysclk_ila program/capture: PROGRAM_PASS, ILA_CAPTURE_STATUS=CAPTURED
soc_bootdiag_sysclk_ila probes: probe0_pc probe1_reset_uart probe2_liveness probe3_pc_activity probe4_nice_csr probe5_nice_hs probe6_mem_status
soc_bootdiag_sysclk_ila reset/UART evidence: probe1_reset_uart=d
soc_bootdiag_sysclk_ila PC activity evidence: probe3_pc_activity 000f79d9 -> 000f7a05
soc_bootdiag_sysclk_ila IFU/ITCM direct counters: probe4_nice_csr=00000000
soc_bootdiag_sysclk_ila UART evidence: probe5_nice_hs=4
soc_bootdiag_sysclk_ila reset/halt evidence: probe6_mem_status=4
```

Evidence:

- `soc_bootdiag_sysclk_ila_artifacts\`
- `soc_bootdiag_sysclk_ila_ila_capture\ila_summary.txt`
- `soc_bootdiag_sysclk_ila_ila_capture\ila_capture.csv`
- `..\..\08_Todo_And_Notes\2026-04-28_To_Final_Defense_Plan\DAY2_CPU_BOOT_DIAGNOSTIC_ILA_2026_04_29.md`

Updated interpretation:

- Reset is released and MMCM is locked on hardware.
- Raw `sys_clk` ILA/debug upload is still reliable in the full SoC diagnostic design.
- No cgstop/debug halt was observed.
- UART TX stayed idle high and no UART TX edge was captured.
- IFU inspect PC activity continued, but direct IFU-to-ITCM request/response counters were zero in this capture.
- Next step is `hello_e203` with explicit software stage markers; if UART remains silent, first check boot address, preload, and UART initialization.

## hello_e203 Raw `sys_clk` ILA Attempt

Diagnostic build mode:

- `hello_sysclk_ila`

Result:

```text
hello_e203 _start: 0x80000000
hello_sysclk_ila build: write_bitstream completed successfully
hello_sysclk_ila timing: WNS=14.204 ns, WHS=0.060 ns, no failing endpoints
hello_sysclk_ila program/capture: PROGRAM_PASS, ILA_CAPTURE_STATUS=CAPTURED
hello_sysclk_ila reset/UART evidence: probe1_reset_uart=d
hello_sysclk_ila PC activity evidence: probe3_pc_activity 000e5182 -> 000e51ae
hello_sysclk_ila IFU/ITCM direct counters: probe4_nice_csr=00000000
hello_sysclk_ila UART/GPIO17 evidence: probe5_nice_hs=4
```

Evidence:

- `hello_sysclk_ila_artifacts\`
- `hello_sysclk_ila_ila_capture\ila_summary.txt`
- `hello_sysclk_ila_ila_capture\ila_capture.csv`
- `..\..\08_Todo_And_Notes\2026-04-28_To_Final_Defense_Plan\DAY3_HELLO_E203_PRELOAD_AND_BLOCKER_2026_04_29.md`

Updated interpretation:

- The hello image and timing-clean bitstream are reproducible.
- Board programming and raw `sys_clk` ILA upload remain reliable.
- `hello_e203` execution is not proven: UART/GPIO17 stayed idle and direct IFU-to-ITCM counters stayed at zero.
- Next step is a narrower boot-vector diagnostic that exposes `pc_rtvec`, IFU request address, MROM response, and ITCM response.

## Immediate Fix Checklist

1. Replug the USB-UART cable.
2. Fix the CH340/USB Serial driver if Device Manager still shows an error.
3. Rebuild or copy a fresh `system.bit` into the current workspace.
4. Rerun:

```powershell
& 'D:\Xilinx\Vivado\2023.2\bin\vivado.bat' -nojournal -nolog -mode batch -source 'C:\Users\16084\Documents\New project\riscv_cnn_accelerator\scripts\check_vivado_hw.tcl'
```

## Success Criteria For Next Attempt

- Vivado prints `CHECK_PASS: xc7a100t_0 detected`.
- Device Manager shows a real non-Bluetooth COM port for board UART.
- A fresh `system.bit` is available or rebuilt before programming.
