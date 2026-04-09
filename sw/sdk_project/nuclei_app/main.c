#include <stdio.h>
#include <stdint.h>
#include "nuclei_sdk_soc.h"
#include "cnn_v1_demo.h"
#include "cnn_v1_benchmark.h"

#define GPIOA_BASE_ADDR 0x10012000UL
#define GPIO_PADDIR_REG (*(volatile uint32_t *)(GPIOA_BASE_ADDR + 0x00))
#define GPIO_PADOUT_REG (*(volatile uint32_t *)(GPIOA_BASE_ADDR + 0x08))
#define STAGE_LED_MASK  (1u << 0)

enum demo_stage {
    DEMO_STAGE_BOOT = 0,
    DEMO_STAGE_MAIN = 1,
    DEMO_STAGE_ACCEL_CFG = 2,
    DEMO_STAGE_START = 3,
    DEMO_STAGE_DONE = 4,
    DEMO_STAGE_PASS = 5,
    DEMO_STAGE_FAIL = 6
};

static void set_stage_led(enum demo_stage stage)
{
    GPIO_PADDIR_REG |= STAGE_LED_MASK;
    if (stage >= DEMO_STAGE_DONE) {
        GPIO_PADOUT_REG |= STAGE_LED_MASK;
    } else {
        GPIO_PADOUT_REG &= ~STAGE_LED_MASK;
    }
}

static void print_stage(const char *stage, enum demo_stage led_stage)
{
    set_stage_led(led_stage);
    printf("[stage] %s\r\n", stage);
    fflush(stdout);
}

static void print_feature_map_2x2(const char *title, const int32_t values[4])
{
    printf("%s\r\n", title);
    printf("  [%11ld, %11ld]\r\n", (long)values[0], (long)values[1]);
    printf("  [%11ld, %11ld]\r\n", (long)values[2], (long)values[3]);
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

    set_stage_led(DEMO_STAGE_BOOT);
    __RV_CSR_SET(CSR_MSTATUS, MSTATUS_XS);
    print_stage("boot", DEMO_STAGE_BOOT);
    print_stage("main", DEMO_STAGE_MAIN);

    printf("\r\nCNN v1 Demo via NICE\r\n");
    printf("Kernel: 3x3 INT8, Input: 4x4 INT8, Output: 2x2\r\n");
    printf("ReLU: %s\r\n", CNN_V1_DEMO_ENABLE_RELU ? "on" : "off");

    print_stage("accel cfg", DEMO_STAGE_ACCEL_CFG);
    cpu_cycles = cnn_v1_measure_reference_conv3x3_4x4(CNN_V1_DEMO_INPUT,
                                                       CNN_V1_DEMO_KERNEL,
                                                       sw_output,
                                                       CNN_V1_DEMO_ENABLE_RELU);
    print_stage("start", DEMO_STAGE_START);
    accel_cycles = cnn_v1_measure_accel_conv3x3_4x4(CNN_V1_DEMO_INPUT,
                                                     CNN_V1_DEMO_KERNEL,
                                                     hw_output,
                                                     CNN_V1_DEMO_ENABLE_RELU);
    print_stage("done", DEMO_STAGE_DONE);

    print_feature_map_2x2("Software reference output:", sw_output);
    print_feature_map_2x2("Accelerator output:", hw_output);
    print_feature_map_2x2("Expected output:", expected_output);
    cnn_v1_print_benchmark_report(cpu_cycles, accel_cycles);
    fflush(stdout);

    pass = compare_feature_maps_2x2(sw_output, expected_output) &&
           compare_feature_maps_2x2(hw_output, expected_output);
    if (pass) {
        print_stage("result", DEMO_STAGE_PASS);
        printf("SDK app check passed.\r\n");
        return 0;
    }

    print_stage("result", DEMO_STAGE_FAIL);
    printf("SDK app check failed.\r\n");
    return 1;
}
