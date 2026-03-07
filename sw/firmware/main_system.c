#include <stdio.h>
#include "custom_insn.h"

/**
 * This code is intended to run on the RISC-V Core (Hummingbird E203).
 * It demonstrates how software invokes the CNN accelerator.
 */
int main() {
    printf("--- RISC-V HW/SW Co-Design Test ---\n");

    // Test Data: 4 weights packed into a 32-bit word (all set to 10)
    uint32_t test_weights = 0x0A0A0A0A; 
    int32_t result = 0;

    // Step 1: Software sends weights to the hardware accelerator
    printf("[SW] Executing ACC_WLOAD...\n");
    ACC_WLOAD(test_weights, 0);

    // Step 2: Software triggers the hardware calculation
    printf("[SW] Executing ACC_COMP...\n");
    ACC_COMP();

    // Step 3: Software retrieves the result from the accelerator
    printf("[SW] Executing ACC_RSTAT...\n");
    ACC_RSTAT(result);

    // Step 4: Verification
    printf("[SW] Final Result from Accelerator: %d\n", result);
    
    if (result == 80) { // 10 (weight) * 2 (fixed input in RTL) * 4 (PEs) = 80
        printf(">>> SYSTEM TEST PASSED! <<<\n");
    } else {
        printf(">>> SYSTEM TEST FAILED! <<<\n");
    }

    return 0;
}
