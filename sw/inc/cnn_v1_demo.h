#ifndef CNN_V1_DEMO_H
#define CNN_V1_DEMO_H

#include <stdint.h>
#include "cnn_v1_driver.h"

#define CNN_V1_DEMO_ENABLE_RELU 1

static const int8_t CNN_V1_DEMO_INPUT[16] = {
    1, -2, 3, 0,
    4, 5, -6, 1,
    -7, 8, 9, -1,
    2, -3, 4, 5
};

static const int8_t CNN_V1_DEMO_KERNEL[9] = {
    1, 0, -1,
    2, -1, 1,
    0, 1, 1
};

static const int32_t CNN_V1_DEMO_EXPECTED_RAW[4] = {
    12, 23, -2, 19
};

static const int32_t CNN_V1_DEMO_EXPECTED_RELU[4] = {
    12, 23, 0, 19
};

#endif /* CNN_V1_DEMO_H */
