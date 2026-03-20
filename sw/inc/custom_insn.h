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

// 1. WLOAD: Load weight data to hardware.
// xspec = xs1|xs2, funct7 = 0
#define ACC_WLOAD(data, index) \
    asm volatile(".insn r 0x0b, %c0, %c1, x0, %2, %3" : : "i"(ACC_X_RS1RS2), "i"(ACC_FN_WLOAD), "r"(data), "r"(index))

// 2. DLOAD: Load activation data to hardware.
// xspec = xs1|xs2, funct7 = 1
#define ACC_DLOAD(data, index) \
    asm volatile(".insn r 0x0b, %c0, %c1, x0, %2, %3" : : "i"(ACC_X_RS1RS2), "i"(ACC_FN_DLOAD), "r"(data), "r"(index))

// 3. COMP: Trigger parallel convolution calculation.
// xspec = none, funct7 = 2
#define ACC_COMP() \
    asm volatile(".insn r 0x0b, %c0, %c1, x0, x0, x0" : : "i"(ACC_X_NONE), "i"(ACC_FN_COMP))

// 4. RSTAT: Read 32-bit accumulated result from hardware.
// xspec = xd, funct7 = 3
#define ACC_RSTAT(rd) \
    asm volatile(".insn r 0x0b, %c1, %c2, %0, x0, x0" : "=r"(rd) : "i"(ACC_X_RD), "i"(ACC_FN_RSTAT))

// 5. CLEAR: Clear PE accumulators before a new output tile.
#define ACC_CLEAR() \
    asm volatile(".insn r 0x0b, %c0, %c1, x0, x0, x0" : : "i"(ACC_X_NONE), "i"(ACC_FN_CLEAR))

#endif /* CUSTOM_INSN_H */
