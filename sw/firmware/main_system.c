#include <stdio.h>
#include <stdint.h>
#include "custom_insn.h"

/**
 * This code is intended to run on the RISC-V Core (Hummingbird E203).
 * It demonstrates how software invokes the CNN accelerator.
 */
int32_t sw_reference_dot(const int8_t *w, const int8_t *d) {
    int32_t acc = 0;
    int i;

    for (i = 0; i < 16; ++i) {
        acc += ((int32_t)w[i]) * ((int32_t)d[i]);
    }

    return acc;
}

int main() {
    printf("--- RISC-V HW/SW Co-Design Test ---\n");

    // Four 32-bit payloads populate all 16 weights and activations in the PE array.
    const int8_t weights[16] = {
        10, 10, 10, 10,
        10, 10, 10, 10,
        10, 10, 10, 10,
        10, 10, 10, 10
    };
    const int8_t data[16] = {
        2, 2, 2, 2,
        2, 2, 2, 2,
        2, 2, 2, 2,
        2, 2, 2, 2
    };
    uint32_t test_weights = 0x0A0A0A0A;
    uint32_t test_data = 0x02020202;
    int32_t sw_result = 0;
    int32_t result = 0;

    sw_result = sw_reference_dot(weights, data);
    printf("[SW] Software reference result: %d\n", sw_result);

    // Step 1: Start from a known accumulator state.
    printf("[SW] Executing ACC_CLEAR...\n");
    ACC_CLEAR();

    // Step 2: Load 16 weights.
    printf("[SW] Executing ACC_WLOAD x4...\n");
    ACC_WLOAD(test_weights, 0);
    ACC_WLOAD(test_weights, 1);
    ACC_WLOAD(test_weights, 2);
    ACC_WLOAD(test_weights, 3);

    // Step 3: Load 16 activations.
    printf("[SW] Executing ACC_DLOAD x4...\n");
    ACC_DLOAD(test_data, 0);
    ACC_DLOAD(test_data, 1);
    ACC_DLOAD(test_data, 2);
    ACC_DLOAD(test_data, 3);

    // Step 4: Trigger the hardware calculation.
    printf("[SW] Executing ACC_COMP...\n");
    ACC_COMP();

    // Step 5: Retrieve the result from the accelerator.
    printf("[SW] Executing ACC_RSTAT...\n");
    ACC_RSTAT(result);

    // Step 6: Verification.
    printf("[SW] Final Result from Accelerator: %d\n", result);

    if (result == sw_result) {
        printf(">>> SYSTEM TEST PASSED! <<<\n");
    } else {
        printf(">>> SYSTEM TEST FAILED! <<<\n");
    }

    return 0;
}
