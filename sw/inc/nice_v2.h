#ifndef NICE_V2_H
#define NICE_V2_H

#include <stdint.h>

/*
 * Experimental NICE v2 ABI.
 *
 * Legacy ACC_* definitions remain in custom_insn.h and are not changed here.
 * Query NICE_V2_CAP before using a command.  The phase-one RTL implements CAP,
 * MLOAD, and MSTAT only; MCFG, MEXEC, and MSTORE raw wrappers are reserved for
 * ABI development and will report a hardware error on the proof of concept.
 */

#define NICE_V2_X_NONE       0
#define NICE_V2_X_RS1RS2     3
#define NICE_V2_X_RD         4
#define NICE_V2_X_RD_RS2     5

#define NICE_V2_FN_CAP       6
#define NICE_V2_FN_MCFG      7
#define NICE_V2_FN_MLOAD     8
#define NICE_V2_FN_MEXEC     9
#define NICE_V2_FN_MSTORE    10
#define NICE_V2_FN_MSTAT     11

#define NICE_V2_CAP_ICB_READ       (1u << 0)
#define NICE_V2_CAP_ACTIVATION_SP  (1u << 1)
#define NICE_V2_CAP_WEIGHT_SP      (1u << 2)
#define NICE_V2_CAP_MSTAT          (1u << 3)
#define NICE_V2_CAP_MEM_TIMEOUT    (1u << 4)
#define NICE_V2_CAP_LEGACY_ABI     (1u << 7)

#define NICE_V2_CAP_MAJOR(value) (((uint32_t)(value) >> 24) & 0xffu)
#define NICE_V2_CAP_MINOR(value) (((uint32_t)(value) >> 16) & 0xffu)
#define NICE_V2_CAP_SP_WORDS(value) (((uint32_t)(value) >> 8) & 0xffu)
#define NICE_V2_CAP_FEATURES(value) ((uint32_t)(value) & 0xffu)

#define NICE_V2_SP_ACTIVATION 0u
#define NICE_V2_SP_WEIGHT     1u
#define NICE_V2_SP_SELECTOR(bank, index) \
    ((((uint32_t)(bank) & 1u) << 4) | ((uint32_t)(index) & 0x0fu))

static inline uint32_t nice_v2_cap(void)
{
    uint32_t value;
    __asm__ __volatile__(
        ".insn r 0x0b, %c1, %c2, %0, x0, x0"
        : "=r"(value)
        : "i"(NICE_V2_X_RD), "i"(NICE_V2_FN_CAP)
    );
    return value;
}

static inline void nice_v2_mload(
    const volatile void *address,
    uint32_t bank,
    uint32_t word_index)
{
    uint32_t selector = NICE_V2_SP_SELECTOR(bank, word_index);
    __asm__ __volatile__(
        ".insn r 0x0b, %c0, %c1, x0, %2, %3"
        :
        : "i"(NICE_V2_X_RS1RS2),
          "i"(NICE_V2_FN_MLOAD),
          "r"((uintptr_t)address),
          "r"(selector)
        : "memory"
    );
}

static inline uint32_t nice_v2_mstat(
    uint32_t bank,
    uint32_t word_index)
{
    uint32_t value;
    uint32_t selector = NICE_V2_SP_SELECTOR(bank, word_index);
    __asm__ __volatile__(
        ".insn r 0x0b, %c1, %c2, %0, x0, %3"
        : "=r"(value)
        : "i"(NICE_V2_X_RD_RS2),
          "i"(NICE_V2_FN_MSTAT),
          "r"(selector)
    );
    return value;
}

static inline void nice_v2_mcfg_raw(uint32_t config0, uint32_t config1)
{
    __asm__ __volatile__(
        ".insn r 0x0b, %c0, %c1, x0, %2, %3"
        :
        : "i"(NICE_V2_X_RS1RS2),
          "i"(NICE_V2_FN_MCFG),
          "r"(config0),
          "r"(config1)
        : "memory"
    );
}

static inline void nice_v2_mexec_raw(uint32_t descriptor, uint32_t flags)
{
    __asm__ __volatile__(
        ".insn r 0x0b, %c0, %c1, x0, %2, %3"
        :
        : "i"(NICE_V2_X_RS1RS2),
          "i"(NICE_V2_FN_MEXEC),
          "r"(descriptor),
          "r"(flags)
        : "memory"
    );
}

static inline void nice_v2_mstore_raw(
    volatile void *address,
    uint32_t selector)
{
    __asm__ __volatile__(
        ".insn r 0x0b, %c0, %c1, x0, %2, %3"
        :
        : "i"(NICE_V2_X_RS1RS2),
          "i"(NICE_V2_FN_MSTORE),
          "r"((uintptr_t)address),
          "r"(selector)
        : "memory"
    );
}

#endif /* NICE_V2_H */
