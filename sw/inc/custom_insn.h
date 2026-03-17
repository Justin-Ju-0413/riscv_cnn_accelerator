#ifndef CUSTOM_INSN_H
#define CUSTOM_INSN_H

#include <stdint.h>

/*
 * RISC-V Custom0 Instruction Definitions (Opcode: 0x0b)
 * Format: .insn r opcode, func3, func7, rd, rs1, rs2
 */

// 1. WLOAD: Load weight data to hardware.
// func3 = 0, rs1 = 32-bit weight data, rs2 = index (0-3)
#define ACC_WLOAD(data, index) \
    asm volatile(".insn r 0x0b, 0, 0, x0, %0, %1" : : "r"(data), "r"(index))

// 2. DLOAD: Load activation data to hardware.
// func3 = 1, rs1 = 32-bit activation data, rs2 = index (0-3)
#define ACC_DLOAD(data, index) \
    asm volatile(".insn r 0x0b, 1, 0, x0, %0, %1" : : "r"(data), "r"(index))

// 3. COMP: Trigger parallel convolution calculation.
// func3 = 2, no parameters
#define ACC_COMP() \
    asm volatile(".insn r 0x0b, 2, 0, x0, x0, x0" : : )

// 4. RSTAT: Read 32-bit accumulated result from hardware.
// func3 = 3, result returned to destination register rd
#define ACC_RSTAT(rd) \
    asm volatile(".insn r 0x0b, 3, 0, %0, x0, x0" : "=r"(rd))

// 5. CLEAR: Clear PE accumulators before a new output tile.
#define ACC_CLEAR() \
    asm volatile(".insn r 0x0b, 4, 0, x0, x0, x0" : : )

#endif /* CUSTOM_INSN_H */
