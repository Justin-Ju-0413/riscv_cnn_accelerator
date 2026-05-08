#ifndef CUSTOM_INSN_H
#define CUSTOM_INSN_H

#include <stdint.h>

/*
 * RISC-V Custom0 Instruction Definitions (Opcode: 0x0b)
 * NICE uses bits [14:12] as xd/xs1/xs2, not a free funct3 field.
 * Format: .insn r opcode, xspec, funct7, rd, rs1, rs2
 */

#define ACC_X_NONE  0
#define ACC_X_RS2   1
#define ACC_X_RS1   2
#define ACC_X_RS1RS2 3
#define ACC_X_RD    4

#define ACC_FN_WLOAD 0
#define ACC_FN_DLOAD 1
#define ACC_FN_COMP  2
#define ACC_FN_RSTAT 3
#define ACC_FN_CLEAR 4
#define ACC_FN_CFG   5

#define ACC_CFG_RELU_EN (1u << 0)

// 1. WLOAD: Load weight data to hardware.
// xspec = xs1|xs2, funct7 = 0
// NOTE: rs2 encodes the vector index (0-3), not a GPR.  GCC's "r" constraint
// already excludes x0 from the allocatable set, but the E203 IFU also has a
// hardware bug where rs2=x0 skips ir_rs2idx capture (fixed in decode RTL).
#define ACC_WLOAD(data, index) \
    __asm__ __volatile__(".insn r 0x0b, %c0, %c1, x0, %2, %3" : : "i"(ACC_X_RS1RS2), "i"(ACC_FN_WLOAD), "r"(data), "r"((uint32_t)(index)))

// 2. DLOAD: Load activation data to hardware.
// xspec = xs1|xs2, funct7 = 1
// Same rs2 encoding note as WLOAD above.
#define ACC_DLOAD(data, index) \
    __asm__ __volatile__(".insn r 0x0b, %c0, %c1, x0, %2, %3" : : "i"(ACC_X_RS1RS2), "i"(ACC_FN_DLOAD), "r"(data), "r"((uint32_t)(index)))

// 3. COMP: Trigger parallel convolution calculation.
// xspec = none, funct7 = 2
#define ACC_COMP() \
    __asm__ __volatile__(".insn r 0x0b, %c0, %c1, x0, x0, x0" : : "i"(ACC_X_NONE), "i"(ACC_FN_COMP))

// 4. RSTAT: Read 32-bit accumulated result from hardware.
// xspec = xd, funct7 = 3
#define ACC_RSTAT(rd) \
    __asm__ __volatile__(".insn r 0x0b, %c1, %c2, %0, x0, x0" : "=r"(rd) : "i"(ACC_X_RD), "i"(ACC_FN_RSTAT))

// 5. CLEAR: Clear PE accumulators before a new output tile.
#define ACC_CLEAR() \
    __asm__ __volatile__(".insn r 0x0b, %c0, %c1, x0, x0, x0" : : "i"(ACC_X_NONE), "i"(ACC_FN_CLEAR))

// 6. CFG: Update accelerator configuration bits from rs1.
// bit0 = ReLU enable on final readback path.
#define ACC_CFG(flags) \
    __asm__ __volatile__(".insn r 0x0b, %c0, %c1, x0, %2, x0" : : "i"(ACC_X_RS1), "i"(ACC_FN_CFG), "r"(flags))

#endif /* CUSTOM_INSN_H */
