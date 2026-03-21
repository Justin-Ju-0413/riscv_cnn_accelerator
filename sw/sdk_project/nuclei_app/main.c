#include <stdio.h>
#include <stdint.h>
#include "custom_insn.h"
#include "nuclei_sdk_soc.h"

/*
 * SDK-style application entry intended to live under
 * nuclei-sdk/application/baremetal/cnn_accel_demo/.
 */
static int32_t sw_reference_dot(const int8_t *w, const int8_t *d)
{
    int32_t acc = 0;
    int i;

    for (i = 0; i < 16; ++i) {
        acc += ((int32_t)w[i]) * ((int32_t)d[i]);
    }

    return acc;
}

int main(void)
{
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

    __RV_CSR_SET(CSR_MSTATUS, MSTATUS_XS);

    printf("\r\nCNN Accelerator Demo via NICE\r\n");
    sw_result = sw_reference_dot(weights, data);
    printf("Software reference result: %d\r\n", sw_result);

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

    if (result == sw_result) {
        printf("SDK app check passed.\r\n");
        return 0;
    }

    printf("SDK app check failed.\r\n");
    return 1;
}
