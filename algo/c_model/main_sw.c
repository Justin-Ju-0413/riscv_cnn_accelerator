#include <stdio.h>
#include <stdint.h>
#include "model_data.h"

static void print_matrix_2x2(const char *label, const int32_t values[4])
{
    printf("%s\n", label);
    printf("  [%d, %d]\n", values[0], values[1]);
    printf("  [%d, %d]\n", values[2], values[3]);
}

static void conv2d_valid_4x4(const int8_t input[16], const int8_t kernel[9], int32_t output[4])
{
    int row;
    int col;
    int kr;
    int kc;

    for (row = 0; row < CNN_V1_OUTPUT_H; ++row) {
        for (col = 0; col < CNN_V1_OUTPUT_W; ++col) {
            int32_t acc = 0;
            for (kr = 0; kr < CNN_V1_KERNEL_H; ++kr) {
                for (kc = 0; kc < CNN_V1_KERNEL_W; ++kc) {
                    int input_idx = (row + kr) * CNN_V1_INPUT_W + (col + kc);
                    int kernel_idx = kr * CNN_V1_KERNEL_W + kc;
                    acc += (int32_t)input[input_idx] * (int32_t)kernel[kernel_idx];
                }
            }
            output[row * CNN_V1_OUTPUT_W + col] = acc;
        }
    }
}

static void apply_relu_2x2(const int32_t input[4], int32_t output[4])
{
    int i;

    for (i = 0; i < 4; ++i) {
        output[i] = (input[i] > 0) ? input[i] : 0;
    }
}

static int verify_matrix_2x2(const char *label, const int32_t actual[4], const int32_t expected[4])
{
    int i;
    int pass = 1;

    for (i = 0; i < 4; ++i) {
        if (actual[i] != expected[i]) {
            pass = 0;
        }
    }

    printf("%s => %s\n", label, pass ? "PASS" : "FAIL");
    if (!pass) {
        printf("  expected: [%d, %d; %d, %d]\n",
               expected[0], expected[1], expected[2], expected[3]);
        printf("  actual:   [%d, %d; %d, %d]\n",
               actual[0], actual[1], actual[2], actual[3]);
    }

    return pass;
}

int main(void)
{
    int32_t conv_out[4];
    int32_t relu_out[4];
    int conv_ok;
    int relu_ok;

    conv2d_valid_4x4(CNN_V1_INPUT, CNN_V1_KERNEL, conv_out);
    apply_relu_2x2(conv_out, relu_out);

    printf("CNN v1 host reference check\n");
    printf("Input: 4x4 valid-conv with 3x3 kernel, output is 2x2.\n");
    print_matrix_2x2("Conv output:", conv_out);
    print_matrix_2x2("ReLU output:", relu_out);

    conv_ok = verify_matrix_2x2("Conv golden", conv_out, CNN_V1_CONV_GOLDEN);
    relu_ok = verify_matrix_2x2("ReLU golden", relu_out, CNN_V1_RELU_GOLDEN);

    if (conv_ok && relu_ok) {
        printf(">>> SW VERIFICATION SUCCESS!\n");
        return 0;
    }

    printf(">>> SW VERIFICATION FAILED!\n");
    return 1;
}
