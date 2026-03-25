#ifndef CNN_V1_BENCHMARK_H
#define CNN_V1_BENCHMARK_H

#include <stdint.h>
#include <stdio.h>
#include "cnn_v1_driver.h"

#define CNN_V1_BENCHMARK_OUTPUTS (CNN_V1_OUTPUT_H * CNN_V1_OUTPUT_W)

static inline uint64_t cnn_v1_read_cycle(void)
{
#if defined(__riscv_xlen) && (__riscv_xlen == 64)
    uint64_t cycle;

    __asm__ __volatile__("csrr %0, mcycle" : "=r"(cycle) :: "memory");
    return cycle;
#else
    uint32_t cycle_hi;
    uint32_t cycle_lo;
    uint32_t cycle_hi_check;

    do {
        __asm__ __volatile__("csrr %0, mcycleh" : "=r"(cycle_hi) :: "memory");
        __asm__ __volatile__("csrr %0, mcycle" : "=r"(cycle_lo) :: "memory");
        __asm__ __volatile__("csrr %0, mcycleh" : "=r"(cycle_hi_check) :: "memory");
    } while (cycle_hi != cycle_hi_check);

    return (((uint64_t)cycle_hi) << 32) | cycle_lo;
#endif
}

static inline uint64_t cnn_v1_cycles_per_output(uint64_t cycles)
{
    return cycles / CNN_V1_BENCHMARK_OUTPUTS;
}

static inline uint64_t cnn_v1_speedup_x1000(uint64_t cpu_cycles, uint64_t accel_cycles)
{
    if (accel_cycles == 0) {
        return 0;
    }

    return (cpu_cycles * 1000ULL) / accel_cycles;
}

static inline uint64_t cnn_v1_measure_reference_conv3x3_4x4(const int8_t input[16],
                                                            const int8_t kernel[9],
                                                            int32_t output[4],
                                                            int apply_relu)
{
    const uint64_t start_cycles = cnn_v1_read_cycle();

    cnn_v1_reference_conv3x3_4x4(input, kernel, output, apply_relu);
    return cnn_v1_read_cycle() - start_cycles;
}

static inline uint64_t cnn_v1_measure_accel_conv3x3_4x4(const int8_t input[16],
                                                         const int8_t kernel[9],
                                                         int32_t output[4],
                                                         int apply_relu)
{
    const uint64_t start_cycles = cnn_v1_read_cycle();

    cnn_v1_accel_conv3x3_4x4(input, kernel, output, apply_relu);
    return cnn_v1_read_cycle() - start_cycles;
}

static inline void cnn_v1_print_benchmark_report(uint64_t cpu_cycles, uint64_t accel_cycles)
{
    const unsigned long cpu_cycles_u = (unsigned long)cpu_cycles;
    const unsigned long accel_cycles_u = (unsigned long)accel_cycles;
    const unsigned long cpu_cycles_per_output = (unsigned long)cnn_v1_cycles_per_output(cpu_cycles);
    const unsigned long accel_cycles_per_output = (unsigned long)cnn_v1_cycles_per_output(accel_cycles);
    const unsigned long speedup_x1000 = (unsigned long)cnn_v1_speedup_x1000(cpu_cycles, accel_cycles);
    const long cycle_delta = (long)cpu_cycles_u - (long)accel_cycles_u;

    printf("Benchmark summary: workload=%u cpu_cycles=%lu accel_cycles=%lu cpu_cycles_per_output=%lu accel_cycles_per_output=%lu speedup_x1000=%lu cycle_delta=%ld\n",
           (unsigned)CNN_V1_BENCHMARK_OUTPUTS,
           cpu_cycles_u,
           accel_cycles_u,
           cpu_cycles_per_output,
           accel_cycles_per_output,
           speedup_x1000,
           cycle_delta);
    printf("  CPU-only cycles: %lu (%lu cycles/output)\n", cpu_cycles_u, cpu_cycles_per_output);
    printf("  Accelerator cycles: %lu (%lu cycles/output)\n", accel_cycles_u, accel_cycles_per_output);
    printf("  Cycle speedup: %lu.%03lu x\n", speedup_x1000 / 1000UL, speedup_x1000 % 1000UL);
    printf("  Cycle delta: %ld\n", cycle_delta);
}

#endif /* CNN_V1_BENCHMARK_H */
