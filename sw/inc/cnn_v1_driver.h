#ifndef CNN_V1_DRIVER_H
#define CNN_V1_DRIVER_H

#include <stdint.h>
#include "custom_insn.h"

#define CNN_V1_INPUT_H 4
#define CNN_V1_INPUT_W 4
#define CNN_V1_KERNEL_H 3
#define CNN_V1_KERNEL_W 3
#define CNN_V1_OUTPUT_H 2
#define CNN_V1_OUTPUT_W 2
#define CNN_V1_PATCH_WORDS 4

static inline uint32_t cnn_v1_pack_i8x4(int8_t b0, int8_t b1, int8_t b2, int8_t b3)
{
    return ((uint32_t)(uint8_t)b0) |
           ((uint32_t)(uint8_t)b1 << 8) |
           ((uint32_t)(uint8_t)b2 << 16) |
           ((uint32_t)(uint8_t)b3 << 24);
}

static inline void cnn_v1_build_kernel_words(const int8_t kernel[9], uint32_t words[4])
{
    words[0] = cnn_v1_pack_i8x4(kernel[0], kernel[1], kernel[2], 0);
    words[1] = cnn_v1_pack_i8x4(kernel[3], kernel[4], kernel[5], 0);
    words[2] = cnn_v1_pack_i8x4(kernel[6], kernel[7], kernel[8], 0);
    words[3] = 0;
}

static inline void cnn_v1_build_patch_words(const int8_t input[16], int out_x, int out_y, uint32_t words[4])
{
    const int base_y = out_y;
    const int base_x = out_x;

    words[0] = cnn_v1_pack_i8x4(
        input[(base_y + 0) * CNN_V1_INPUT_W + (base_x + 0)],
        input[(base_y + 0) * CNN_V1_INPUT_W + (base_x + 1)],
        input[(base_y + 0) * CNN_V1_INPUT_W + (base_x + 2)],
        0);
    words[1] = cnn_v1_pack_i8x4(
        input[(base_y + 1) * CNN_V1_INPUT_W + (base_x + 0)],
        input[(base_y + 1) * CNN_V1_INPUT_W + (base_x + 1)],
        input[(base_y + 1) * CNN_V1_INPUT_W + (base_x + 2)],
        0);
    words[2] = cnn_v1_pack_i8x4(
        input[(base_y + 2) * CNN_V1_INPUT_W + (base_x + 0)],
        input[(base_y + 2) * CNN_V1_INPUT_W + (base_x + 1)],
        input[(base_y + 2) * CNN_V1_INPUT_W + (base_x + 2)],
        0);
    words[3] = 0;
}

static inline void cnn_v1_extract_patch(const int8_t input[16], int out_x, int out_y, int8_t patch[9])
{
    int idx = 0;
    int ky;
    int kx;

    for (ky = 0; ky < CNN_V1_KERNEL_H; ++ky) {
        for (kx = 0; kx < CNN_V1_KERNEL_W; ++kx) {
            patch[idx++] = input[(out_y + ky) * CNN_V1_INPUT_W + (out_x + kx)];
        }
    }
}

static inline int32_t cnn_v1_dot9_reference(const int8_t kernel[9], const int8_t patch[9])
{
    int32_t acc = 0;
    int i;

    for (i = 0; i < 9; ++i) {
        acc += ((int32_t)kernel[i]) * ((int32_t)patch[i]);
    }

    return acc;
}

static inline int32_t cnn_v1_relu32(int32_t value)
{
    return (value > 0) ? value : 0;
}

static inline void cnn_v1_accel_run_tile(const uint32_t kernel_words[4], const uint32_t patch_words[4], int32_t *result)
{
    ACC_CLEAR();
    ACC_WLOAD(kernel_words[0], 0);
    ACC_WLOAD(kernel_words[1], 1);
    ACC_WLOAD(kernel_words[2], 2);
    ACC_WLOAD(kernel_words[3], 3);
    ACC_DLOAD(patch_words[0], 0);
    ACC_DLOAD(patch_words[1], 1);
    ACC_DLOAD(patch_words[2], 2);
    ACC_DLOAD(patch_words[3], 3);
    ACC_COMP();
    ACC_RSTAT(*result);
}

static inline void cnn_v1_reference_conv3x3_4x4(const int8_t input[16], const int8_t kernel[9], int32_t output[4], int apply_relu)
{
    int out_y;
    int out_x;

    for (out_y = 0; out_y < CNN_V1_OUTPUT_H; ++out_y) {
        for (out_x = 0; out_x < CNN_V1_OUTPUT_W; ++out_x) {
            int8_t patch[9];
            int32_t value;

            cnn_v1_extract_patch(input, out_x, out_y, patch);
            value = cnn_v1_dot9_reference(kernel, patch);
            if (apply_relu) {
                value = cnn_v1_relu32(value);
            }
            output[out_y * CNN_V1_OUTPUT_W + out_x] = value;
        }
    }
}

static inline void cnn_v1_accel_conv3x3_4x4(const int8_t input[16], const int8_t kernel[9], int32_t output[4], int apply_relu)
{
    uint32_t kernel_words[4];
    int out_y;
    int out_x;

    ACC_CFG(apply_relu ? ACC_CFG_RELU_EN : 0u);
    cnn_v1_build_kernel_words(kernel, kernel_words);

    for (out_y = 0; out_y < CNN_V1_OUTPUT_H; ++out_y) {
        for (out_x = 0; out_x < CNN_V1_OUTPUT_W; ++out_x) {
            uint32_t patch_words[4];
            int32_t value = 0;

            cnn_v1_build_patch_words(input, out_x, out_y, patch_words);
            cnn_v1_accel_run_tile(kernel_words, patch_words, &value);
            output[out_y * CNN_V1_OUTPUT_W + out_x] = value;
        }
    }

    if (apply_relu) {
        ACC_CFG(0u);
    }
}

#endif /* CNN_V1_DRIVER_H */
