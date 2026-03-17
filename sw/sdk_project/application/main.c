#include <stdio.h>
#include "../../inc/custom_insn.h"

/*
 * This file mirrors the current standalone firmware flow but is arranged as a
 * Nuclei SDK application entry point so the project can be migrated with
 * minimal reshaping after the SDK is installed.
 */
int main(void) {
    uint32_t test_weights = 0x0A0A0A0A;
    uint32_t test_data = 0x02020202;
    int32_t result = 0;

    printf("--- Nuclei SDK CNN Accelerator Demo ---\n");

    ACC_CLEAR();

    ACC_WLOAD(test_weights, 0);
    ACC_WLOAD(test_weights, 1);
    ACC_WLOAD(test_weights, 2);
    ACC_WLOAD(test_weights, 3);

    ACC_DLOAD(test_data, 0);
    ACC_DLOAD(test_data, 1);
    ACC_DLOAD(test_data, 2);
    ACC_DLOAD(test_data, 3);

    ACC_COMP();
    ACC_RSTAT(result);

    printf("Accelerator result: %d\n", result);
    if(result == 320) {
        printf("SDK app check passed.\n");
    } else {
        printf("SDK app check failed.\n");
    }

    return 0;
}
