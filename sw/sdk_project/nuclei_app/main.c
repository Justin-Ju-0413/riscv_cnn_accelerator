#include <stdio.h>
#include "custom_insn.h"
#include "nuclei_sdk_soc.h"

/*
 * SDK-style application entry intended to live under
 * nuclei-sdk/application/baremetal/cnn_accel_demo/.
 */
int main(void)
{
    uint32_t test_weights = 0x0A0A0A0A;
    uint32_t test_data = 0x02020202;
    int32_t result = 0;

    printf("\r\nCNN Accelerator Demo via NICE\r\n");

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

    printf("Accelerator result: %d\r\n", result);

    if (result == 320) {
        printf("SDK app check passed.\r\n");
        return 0;
    }

    printf("SDK app check failed.\r\n");
    return 1;
}
