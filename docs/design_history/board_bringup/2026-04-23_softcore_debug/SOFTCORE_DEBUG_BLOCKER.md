# Davinci Pro A7-100T Soft-Core Debug Blocker

## Current Conclusion

The project is not currently blocked by RTL simulation or full-SoC simulation. The main blocker is the board-side soft-core debug path on Davinci Pro A7-100T.

## What Is Already Working

- Local RTL regression has passed before with `[TB_PASS]`.
- Software-driven full-SoC regression has passed before with `expected_rstat = 19`.
- The board-side environment has advanced to bring-up.
- `PTD04 + Vivado` is treated as the FPGA programming path.

## What Is Not Closed Yet

- CPU software debug is not closed.
- `OpenOCD + GDB` is not yet a reliable flow.
- The current setup has not closed:
  - loading ELF through GDB
  - breaking at `main`
  - stepping through CPU software
  - observing stable CPU-side software execution through the debug path

## Why This Matters

The current accelerator has already been verified at:

- module level: local RTL regression
- system simulation level: full-SoC regression

The next real milestone is board-side execution evidence. Without a working soft-core debug path, it is difficult to load, control, and inspect CPU-side software execution on the FPGA.

## Practical Next Step

The recommended next action is to evaluate a dedicated OpenOCD-compatible debug adapter first. This is likely the fastest way to close CPU software debug. A BSCANE2-based bridge can remain a later integration direction if the direct debug adapter path is not enough.

## Reporting Sentence

At this stage, the project is no longer mainly blocked by RTL or full-SoC simulation. The key blocker has shifted to board-side soft-core debugging on the Davinci Pro A7-100T.
