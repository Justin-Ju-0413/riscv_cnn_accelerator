#include <stdio.h>
#include <stdint.h>
#include "nuclei_sdk_soc.h"
#include "cnn_v1_demo.h"
#include "cnn_v1_benchmark.h"

static void print_feature_map_2x2(const char *title, const int32_t values[4])
{
    printf("%s\n", title);
    printf("  [%11ld, %11ld]\n", (long)values[0], (long)values[1]);
    printf("  [%11ld, %11ld]\n", (long)values[2], (long)values[3]);
}

static int compare_feature_maps_2x2(const int32_t lhs[4], const int32_t rhs[4])
{
    int i;

    for (i = 0; i < 4; ++i) {
        if (lhs[i] != rhs[i]) {
            return 0;
        }
    }

    return 1;
}

int main(void)
{
    int32_t sw_output[4];
    int32_t hw_output[4];
    const int32_t *expected_output = CNN_V1_DEMO_ENABLE_RELU ? CNN_V1_DEMO_EXPECTED_RELU : CNN_V1_DEMO_EXPECTED_RAW;
    int pass;
    uint64_t cpu_cycles;
    uint64_t accel_cycles;

    printf("\r\n--- Nuclei SDK CNN v1 Demo ---\r\n");
    printf("Kernel: 3x3 INT8, Input: 4x4 INT8, Output: 2x2\r\n");
    printf("ReLU: %s\r\n", CNN_V1_DEMO_ENABLE_RELU ? "on" : "off");

    __RV_CSR_SET(CSR_MSTATUS, MSTATUS_XS);

    cpu_cycles = cnn_v1_measure_reference_conv3x3_4x4(CNN_V1_DEMO_INPUT,
                                                       CNN_V1_DEMO_KERNEL,
                                                       sw_output,
                                                       CNN_V1_DEMO_ENABLE_RELU);
    accel_cycles = cnn_v1_measure_accel_conv3x3_4x4(CNN_V1_DEMO_INPUT,
                                                     CNN_V1_DEMO_KERNEL,
                                                     hw_output,
                                                     CNN_V1_DEMO_ENABLE_RELU);

    print_feature_map_2x2("Software reference output:", sw_output);
    print_feature_map_2x2("Accelerator output:", hw_output);
    print_feature_map_2x2("Expected output:", expected_output);
    cnn_v1_print_benchmark_report(cpu_cycles, accel_cycles);
    fflush(stdout);

    pass = compare_feature_maps_2x2(sw_output, expected_output) &&
           compare_feature_maps_2x2(hw_output, expected_output);
    if (pass) {
        printf("SDK app check passed.\r\n");
        return 0;
    }

    printf("SDK app check failed.\r\n");
    return 1;
}
