// Per-layer quantization scales for LeNet-5
// Scale factor: FP32_value = INT8_value * scale
#ifndef LENET5_SCALES_H
#define LENET5_SCALES_H

// conv1 scale: 0.00306786f
#define CONV1_SCALE 0.00306786f
// conv2 scale: 0.00241322f
#define CONV2_SCALE 0.00241322f
// fc1 scale: 0.00202640f
#define FC1_SCALE 0.00202640f
// fc2 scale: 0.00264765f
#define FC2_SCALE 0.00264765f
// fc3 scale: 0.00230990f
#define FC3_SCALE 0.00230990f

// Input scale (uint8[0,255] -> normalized float)
#define INPUT_SCALE (1.0f/255.0f)

// Integer rescale shifts (fixed-point approximation)
// conv1_shift: input(INT8) * weight(INT8) * scale_in * scale_w -> INT32 output
#define CONV1_RSHIFT 0  // accumulate in INT32, no shift needed
#define CONV2_RSHIFT 4  // rescale pool1(INT32) to conv2 input range
#define FC_RSHIFT 10     // rescale FC input to output

#endif
