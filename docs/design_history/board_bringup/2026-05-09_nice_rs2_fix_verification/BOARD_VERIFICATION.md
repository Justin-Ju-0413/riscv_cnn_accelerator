# NICE rs2 Index Capture Fix — Board Verification (2026-05-09)

## Fix Applied

**Problem**: E203 IFU skipped rs2 index capture for NICE instructions when
rs2 field = x0 (index 0).  The NICE rs2 field encodes accelerator vector
index (0-3), not a GPR number.  When index=0, rs2 field = 5'b00000,
decoder misinterpreted as "rs2=x0 → no rs2 needed".

**RTL Fix**: `e203_exu_decode.v:688` — moved rv32_rs2_x0 gating outside
the nice_op ternary so NICE instructions always capture rs2.

**Software Fix**: `custom_insn.h` — explicit uint32_t cast for index
operand in WLOAD/DLOAD macros.

## FPGA Build

- Build Mode: `cnn_sysclk_ila`
- Commit: `1d60972` (e203_hbirdv2), `ba847db` (riscv_cnn_accelerator)
- Timing: WNS=13.512ns, WHS=0.056ns — PASS
- 0 errors, 0 unrouted nets

## Board Verification

- Board: Digilent Davinci Pro A7-100T (210512180081)
- Program: PASS
- ILA: hw_ila_1 captured (4-bit NICE handshake stable at idle)
- UART: CNN v1 DEMO PASSED, speedup 5.282x, HW/SW/Expected all match

## Result

Fix verified safe — no regression in accelerator functionality.
The fix addresses a latent hardware bug; current firmware (compiled with
-O2) does not trigger the bug because GCC allocates non-x0 registers for
the index operand.
