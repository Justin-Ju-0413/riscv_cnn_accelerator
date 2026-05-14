# 2026-04-28 Board Runtime Evidence

## Code Baseline

GitHub is the source-code authority. Windows `Graduation_Design_Library` is the evidence and reporting archive.

Commit pair used for this run:

- `riscv_cnn_accelerator`
  - Branch: `codex/a7-bringup-v2-main`
  - Commit: `b414e36399ba6d301497a9f03341bd7c880ed779`
  - Message: `fpga: prepare windows davinci bitstream flow`
- `e203_hbirdv2`
  - Branch: `codex/a7-bringup-v2-soc`
  - Commit: `afbf0c4d4ac282166b5be710b9e42d2f672c6e44`
  - Message: `fpga: stabilize davinci source management`

## Build Inputs

- SDK app image source:
  - `C:\Users\16084\Documents\New project\riscv_cnn_accelerator\third_party\nuclei-sdk\application\baremetal\cnn_accel_demo`
- Prepared FPGA RTL output:
  - `C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\install\rtl`
- Bitstream output:
  - `C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\davinci_a7_100t\obj\system.bit`
  - Size: `3825891` bytes
  - Timestamp: `2026-04-28 02:31:46`

## Commands And Results

Prepare install RTL:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Prepare-Fpga-Install.ps1
```

Result:

```text
Prepared FPGA install RTL: C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\install\rtl
ITCM: C:/Users/16084/Documents/New project/e203_hbirdv2/fpga/install/rtl/e203/core/cnn_accel_demo.itcm.verilog
DTCM: C:/Users/16084/Documents/New project/e203_hbirdv2/fpga/install/rtl/e203/core/cnn_accel_demo.dtcm.verilog
```

Build bitstream:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -Action bit
```

Result:

```text
VSRCS count: 140
write_bitstream completed successfully
0 Errors encountered
```

JTAG check:

```powershell
& 'D:\Xilinx\Vivado\2023.2\bin\vivado.bat' -nojournal -nolog -mode batch -source scripts\check_vivado_hw.tcl
```

Result:

```text
HW_TARGETS=localhost:3121/xilinx_tcf/Digilent/210512180081
HW_DEVICES=xc7a100t_0
HW_DEVICE=xc7a100t NAME=xc7a100t_0
CHECK_PASS: xc7a100t_0 detected
```

Program FPGA:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Program-Vivado-Bit.ps1 -BitFile "C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\davinci_a7_100t\obj\system.bit"
```

Result:

```text
PROGRAM_PASS: C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\davinci_a7_100t\obj\system.bit
```

UART device check:

```text
USB-SERIAL CH340 (COM11): OK
Available port: COM11
```

UART capture:

```text
COM11, 115200 baud
UART_CAPTURE_EMPTY_AFTER_REPROGRAM
```

## Current Interpretation

Closed:

- GitHub/local code management is aligned on the two active branches.
- Windows Vivado can build the Davinci A7-100T bitstream from the current source flow.
- JTAG detects `xc7a100t_0`.
- FPGA programming passes.
- CH340 UART device is visible as `COM11`.

Open:

- No UART text was captured after programming.
- Next evidence target is ILA or reset/PC/UART-TX debug to determine whether the soft-core starts, stalls, or runs without UART output.

## Next Debug Priority

1. Capture ILA PC activity after programming.
2. Check reset release and clock lock.
3. Probe UART TX activity.
4. If PC moves but UART is silent, debug UART pin, baud rate, and board routing.
5. If PC does not move, debug boot address and ITCM/DTCM preload path.

## ILA Follow-Up

Additional GitHub-managed debug support was added after the first UART-empty result.

Changes under test:

- Added a batch ILA capture helper in `riscv_cnn_accelerator`.
- Reconnected the board ILA sample clock from `probe_core_clk` to stable `clk_16M` in `e203_hbirdv2`.

Command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Capture-Vivado-Ila.ps1
```

Observed result:

```text
PROGRAM_PASS=C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\davinci_a7_100t\obj\system.bit
PROBES_FILE=C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\davinci_a7_100t\obj\davinci_a7_100t.runs\impl_1\system.ltx
HW_ILAS=hw_ila_1
HW_PROBES=probe_csr_flags probe_mem_bus probe_nice_csr_addr probe_nice_csr_wdata probe_nice_hs probe_pc probe_status
ILA_UPLOAD_FAILED=ERROR: [Labtools 27-3312] Data read from hw_ila [hw_ila_1] is corrupted. Unable to upload waveform.
ILA_CAPTURE_STATUS=UPLOAD_FAILED
```

UART after the ILA clock change:

```text
UART_CAPTURE_EMPTY_AFTER_ILA_CLOCK_CHANGE
```

Interpretation:

- The `.ltx` association issue is closed: Vivado sees `hw_ila_1` and all seven expected probes.
- The remaining issue is not just a serial-terminal problem. ILA waveform upload fails with corrupted data even with the ILA clock moved to `clk_16M`.
- The next likely debug axis is board clock/reset/timing/debug-hub integrity:
  - routed timing report says timing requirements are not met
  - reset and MMCM lock should be observed externally or exposed through a simpler debug path
  - a minimal LED/reset/clock heartbeat bitstream may be needed before relying on CPU/ILA evidence

## Heartbeat Isolation Follow-Up

New commit pair:

- `riscv_cnn_accelerator`
  - Commit: `2028fee0a2d98063a987a04df808877a8aa2fe48`
  - Message: `fpga: add davinci heartbeat build modes`
- `e203_hbirdv2`
  - Commit: `bf87a17b923faed0df640b8271631fc145b6b01b`
  - Message: `fpga: add davinci heartbeat debug tops`

Build commands:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -BuildMode heartbeat -Action bit
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -BuildMode heartbeat_direct -Action bit
```

Results:

```text
heartbeat: write_bitstream completed successfully
heartbeat_direct: write_bitstream completed successfully
heartbeat_direct route timing: WNS positive
```

Programming and ILA capture for `heartbeat_direct`:

```text
PROGRAM_PASS=C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\davinci_a7_100t\obj\system.bit
HW_ILAS=hw_ila_1
HW_PROBES=probe0_counter probe1_reset probe2_inputs probe3_zero probe4_zero probe5_jtag probe6_status
ILA_CAPTURE_STATUS=CAPTURED
```

CSV evidence shows the raw `sys_clk` counter increments sample by sample:

```text
01595fdb
01595fdc
01595fdd
01595fde
01595fdf
```

Artifact archive:

- `heartbeat_direct_ila_capture\ila_summary.txt`
- `heartbeat_direct_ila_capture\ila_capture.csv`
- `heartbeat_direct_artifacts\heartbeat_direct_system.bit`
- `heartbeat_direct_artifacts\heartbeat_direct_system.ltx`
- `heartbeat_direct_artifacts\heartbeat_direct_impl_runme.log`
- `heartbeat_direct_artifacts\heartbeat_direct_timing_summary_routed.rpt`
- `heartbeat_direct_artifacts\heartbeat_direct_route_status.rpt`

Updated conclusion:

- Board JTAG/programming is good.
- Raw board clock and debug hub/ILA upload are good.
- The CPU/UART path should not be debugged further until the MMCM-derived `clk_16M` and reset release path are proven with observable signals.

## MMCM/Reset Isolation Follow-Up

New commit pair:

- `riscv_cnn_accelerator`
  - Commit: `7b30969020caa6eefb9a631ba3989c0ba57797b7`
  - Message: `fpga: add mmcm heartbeat build modes`
- `e203_hbirdv2`
  - Commit: `f6610c9cd87c3d4c6961c86269c13b061bb949ed`
  - Message: `fpga: add davinci mmcm heartbeat diagnostics`

Build commands:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -BuildMode heartbeat_mmcm_ledonly -Action bit
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -BuildMode heartbeat_mmcm_dualclk -Action bit
```

Observed results:

```text
heartbeat_mmcm_ledonly: write_bitstream completed successfully
heartbeat_mmcm_ledonly timing: WNS=60.386 ns, constraints met
heartbeat_mmcm_ledonly program: PROGRAM_PASS
heartbeat_mmcm_ledonly LED: PASS, visually confirmed blinking on board

heartbeat_mmcm_dualclk: write_bitstream completed successfully
heartbeat_mmcm_dualclk timing after CDC false path: WNS=27.913 ns, constraints met
heartbeat_mmcm_dualclk program: PROGRAM_PASS
heartbeat_mmcm_dualclk HW_ILAS=hw_ila_1
heartbeat_mmcm_dualclk HW_PROBES=probe0_dbg_counter probe1_reset probe2_inputs probe3_clk16_edges probe4_zero probe5_jtag probe6_status
heartbeat_mmcm_dualclk ILA_UPLOAD_FAILED=ERROR: [Labtools 27-3312] Data read from hw_ila [hw_ila_1] is corrupted. Unable to upload waveform.
heartbeat_mmcm_dualclk ILA_CAPTURE_STATUS=UPLOAD_FAILED
```

Artifact archive:

- `heartbeat_mmcm_ledonly_artifacts\heartbeat_mmcm_ledonly_system.bit`
- `heartbeat_mmcm_ledonly_artifacts\heartbeat_mmcm_ledonly_impl_runme.log`
- `heartbeat_mmcm_ledonly_artifacts\heartbeat_mmcm_ledonly_timing_summary_routed.rpt`
- `heartbeat_mmcm_dualclk_artifacts\heartbeat_mmcm_dualclk_system.bit`
- `heartbeat_mmcm_dualclk_artifacts\heartbeat_mmcm_dualclk_system.ltx`
- `heartbeat_mmcm_dualclk_artifacts\heartbeat_mmcm_dualclk_impl_runme.log`
- `heartbeat_mmcm_dualclk_artifacts\heartbeat_mmcm_dualclk_timing_summary_routed.rpt`
- `heartbeat_mmcm_dualclk_ila_capture\ila_summary.txt`

Updated conclusion:

- `heartbeat_direct` proves raw `sys_clk` + ILA upload is functional.
- `heartbeat_mmcm_ledonly` proves MMCM/reset heartbeat can build, meet timing, program, and visibly blink the board LED.
- `heartbeat_mmcm_dualclk` proves MMCM-output-clocked ILA is detectable, but upload still corrupts even when the design meets timing.
- The next technical step should avoid relying on an MMCM-clocked ILA for CPU evidence; use raw `sys_clk` debug observation or fix the Vivado debug hub clocking path before returning to CPU/UART.

## Raw `sys_clk` ILA For MMCM/Reset State

New diagnostic build mode added after LED confirmation:

- `heartbeat_mmcm_sysclk_ila`: MMCM `clk_out2` still drives the `clk_16M` heartbeat/reset path, while ILA/debug hub is clocked by raw `sys_clk`.
- The ILA observes synchronized `mmcm_locked`, `reset_periph`, LED, heartbeat toggle, heartbeat edge count, and sampled high heartbeat counter bits from the raw `sys_clk` domain.
- A mode-specific false path constrains the intentional `clk_16M` -> `sys_clk` CDC observation path.

Build command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -BuildMode heartbeat_mmcm_sysclk_ila -Action bit
```

Build result:

```text
heartbeat_mmcm_sysclk_ila: write_bitstream completed successfully
heartbeat_mmcm_sysclk_ila timing: WNS=13.887 ns, constraints met
```

Artifact archive:

- `heartbeat_mmcm_sysclk_ila_artifacts\heartbeat_mmcm_sysclk_ila_system.bit`
- `heartbeat_mmcm_sysclk_ila_artifacts\heartbeat_mmcm_sysclk_ila_system.ltx`
- `heartbeat_mmcm_sysclk_ila_artifacts\heartbeat_mmcm_sysclk_ila_impl_runme.log`
- `heartbeat_mmcm_sysclk_ila_artifacts\heartbeat_mmcm_sysclk_ila_timing_summary_routed.rpt`
- `heartbeat_mmcm_sysclk_ila_artifacts\heartbeat_mmcm_sysclk_ila_route_status.rpt`
- `heartbeat_mmcm_sysclk_ila_ila_capture\ila_summary.txt`
- `heartbeat_mmcm_sysclk_ila_ila_capture\ila_capture.csv`

Runtime capture result:

```text
heartbeat_mmcm_sysclk_ila ILA: ILA_CAPTURE_STATUS=CAPTURED
probe0_sysclk_counter: 01640b7d -> 01640f7c
probe3_clk16_edges: 0000e3da -> 0000e3dd
probe1_reset=c
probe6_status=4
```

Interpretation:

- The raw `sys_clk` ILA/debug hub path can program, trigger, upload, and export CSV while observing MMCM/reset state.
- `probe1_reset=c` means `sys_rst_n=1`, synchronized `mmcm_locked=1`, synchronized `reset_periph=0`, and sampled LED state `0`.
- `probe6_status=4` independently shows `mmcm_locked=1`, `reset_periph=0`, and LED sample `0`.
- `probe3_clk16_edges` increments inside the capture window, proving `clk_16M` heartbeat activity is visible from the raw `sys_clk` debug domain.

## Full SoC Raw `sys_clk` ILA Diagnostic

New diagnostic build mode:

- `soc_sysclk_ila`: full SoC runs from MMCM-generated `clk_16M`, while ILA/debug hub runs from raw `sys_clk`.
- CPU/SoC state is sampled or summarized in the `clk_16M` domain, then synchronized into raw `sys_clk` before connecting to ILA probes.
- A mode-specific XDC constrains the intentional `clk_16M` -> `sys_clk` diagnostic CDC and the advanced timer low-speed-clock-as-data synchronizer endpoints.

Build command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -BuildMode soc_sysclk_ila -Action bit
```

Build result:

```text
soc_sysclk_ila: write_bitstream completed successfully
soc_sysclk_ila timing: WNS=13.515 ns, WHS=0.058 ns, no failing endpoints
```

Runtime capture result:

```text
soc_sysclk_ila ILA: ILA_CAPTURE_STATUS=CAPTURED
probe0_pc: observed 00000000 and 00000002
probe1_reset_uart: d
probe2_liveness: observed 0 and 4
probe3_pc_activity: 000ed645 -> 000ed671
probe5_nice_hs: 4
probe6_mem_status: observed 1, 3, and 5
```

Artifact archive:

- `soc_sysclk_ila_artifacts\soc_sysclk_ila_system.bit`
- `soc_sysclk_ila_artifacts\soc_sysclk_ila_system.ltx`
- `soc_sysclk_ila_artifacts\soc_sysclk_ila_impl_runme.log`
- `soc_sysclk_ila_artifacts\soc_sysclk_ila_timing_summary_routed.rpt`
- `soc_sysclk_ila_artifacts\soc_sysclk_ila_route_status.rpt`
- `soc_sysclk_ila_ila_capture\ila_summary.txt`
- `soc_sysclk_ila_ila_capture\ila_capture.csv`

Interpretation:

- The full SoC can be observed through raw `sys_clk` ILA with successful upload, so the earlier MMCM-clocked ILA corruption is avoided.
- Reset is released in hardware: `sys_rst_n=1`, `mmcm_locked=1`, and `reset_periph=0`.
- UART TX sampled high during this window.
- PC activity and bus/NICE summaries show activity, but the sampled PC bus only exposed `00000000`/`00000002`; follow-up should verify PC probe wiring and boot/PC visibility before drawing architectural conclusions from `probe0_pc`.

## CPU Boot Diagnostic Raw `sys_clk` ILA

New diagnostic build mode:

- `soc_bootdiag_sysclk_ila`: full SoC runs from MMCM-generated `clk_16M`, ILA/debug hub runs from raw `sys_clk`, and CPU boot state is summarized through CDC-safe diagnostic counters and sticky flags.

Build command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-Vivado-Fpga.ps1 -BuildMode soc_bootdiag_sysclk_ila -Action bit
```

Build result:

```text
soc_bootdiag_sysclk_ila: write_bitstream completed successfully
soc_bootdiag_sysclk_ila timing: WNS=13.337 ns, WHS=0.039 ns, no failing endpoints
```

Runtime capture result:

```text
soc_bootdiag_sysclk_ila ILA: ILA_CAPTURE_STATUS=CAPTURED
probe0_pc: observed 00000000 and 00000002
probe1_reset_uart: d
probe2_liveness: 0
probe3_pc_activity: 000f79d9 -> 000f7a05
probe4_nice_csr: 00000000
probe5_nice_hs: 4
probe6_mem_status: 4
```

Artifact archive:

- `soc_bootdiag_sysclk_ila_artifacts\soc_bootdiag_sysclk_ila_system.bit`
- `soc_bootdiag_sysclk_ila_artifacts\soc_bootdiag_sysclk_ila_system.ltx`
- `soc_bootdiag_sysclk_ila_artifacts\soc_bootdiag_sysclk_ila_impl_runme.log`
- `soc_bootdiag_sysclk_ila_artifacts\soc_bootdiag_sysclk_ila_timing_summary_routed.rpt`
- `soc_bootdiag_sysclk_ila_artifacts\soc_bootdiag_sysclk_ila_route_status.rpt`
- `soc_bootdiag_sysclk_ila_ila_capture\ila_summary.txt`
- `soc_bootdiag_sysclk_ila_ila_capture\ila_capture.csv`

Interpretation:

- `probe1_reset_uart=d` means `sys_rst_n=1`, `mmcm_locked=1`, `reset_periph=0`, and sampled UART TX high.
- `probe6_mem_status=4` means reset release was observed, with no core cgstop and no debug halt.
- UART TX stayed idle high and no TX edge was captured.
- Direct IFU-to-ITCM request/response counters were zero in this capture, while the PC activity counter still increased.
- The next branch should be a minimal `hello_e203` image with explicit stage markers, then boot/preload/UART diagnosis if the board remains silent.
