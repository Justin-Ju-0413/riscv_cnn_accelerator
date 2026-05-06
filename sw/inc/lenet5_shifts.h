// Auto-generated calibration shifts for LeNet-5 INT8 inference
// Generated 2026-05-06
#ifndef LENET5_SHIFTS_H
#define LENET5_SHIFTS_H

// Pool1 output -> Conv2 INT8 input rescaling
#define CONV2_INPUT_RSHIFT 9

// Conv2 output (INT32) -> FC1 input rescaling (applied in FC1 first stage)
// Note: FC1 internally right-shifts by FC1_OUT_RSHIFT, applied separately
#define FC1_OUT_RSHIFT 8
#define FC2_OUT_RSHIFT 9
#define FC3_OUT_RSHIFT 9

#endif
