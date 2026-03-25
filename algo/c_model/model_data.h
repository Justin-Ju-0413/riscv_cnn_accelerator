#ifndef MODEL_DATA_H
#define MODEL_DATA_H

#include <stdint.h>

/* Fixed golden case for the minimal CNN v1 host reference. */
enum {
    CNN_V1_INPUT_H = 4,
    CNN_V1_INPUT_W = 4,
    CNN_V1_KERNEL_H = 3,
    CNN_V1_KERNEL_W = 3,
    CNN_V1_OUTPUT_H = 2,
    CNN_V1_OUTPUT_W = 2,
};

const int8_t CNN_V1_INPUT[16] = {1, -2, 3, 0, 4, 5, -6, 1, -7, 8, 9, -10, 11, -12, 13, 14};
const int8_t CNN_V1_KERNEL[9] = {2, -1, 0, -3, 1, 4, 1, -2, 3};
const int32_t CNN_V1_CONV_GOLDEN[4] = {-23, -64, 142, -35};
const int32_t CNN_V1_RELU_GOLDEN[4] = {0, 0, 142, 0};

#endif /* MODEL_DATA_H */
