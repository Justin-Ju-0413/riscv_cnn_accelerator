# Debug Options Comparison

## Goal

Find the most practical way to close CPU software debug on Davinci Pro A7-100T.

## Option A: Independent OpenOCD-Compatible Soft-JTAG Adapter

### Idea

Use a dedicated debug adapter that OpenOCD can recognize directly, then connect it to the CPU debug path.

### Strengths

- Most direct route for `OpenOCD + GDB`.
- Better suited for `load ELF`, `break main`, and step debug.
- Easier to explain as a debug-tool limitation rather than an RTL issue.

### Risks

- Requires compatible hardware.
- Requires pinout and connection confirmation.
- May still need board-level signal verification.

### Short-Term Suitability

High. This is the recommended first path.

## Option B: BSCANE2-Based Debug Bridge

### Idea

Use Xilinx BSCANE2 to route JTAG/debug access through the FPGA fabric.

### Strengths

- Can integrate debug access into the FPGA design.
- Useful if the board does not expose a convenient external debug path.
- Keeps PTD04-related workflow relevant.

### Risks

- Higher RTL integration complexity.
- More difficult to debug if both the bridge and CPU debug path are uncertain.
- Not ideal as the first short-term path before the basic debug requirement is proven.

### Short-Term Suitability

Medium. Keep it as a later route.

## Recommendation

Try the independent OpenOCD-compatible debug adapter first. It is the cleaner short-term path for validating CPU software debug. Keep BSCANE2 as the backup or future integration plan.

## Decision For Next Week

- Primary direction: independent OpenOCD-compatible debug adapter
- Backup direction: BSCANE2-based bridge
- Do not redefine the blocker as RTL timing or full-SoC simulation until evidence points there.
