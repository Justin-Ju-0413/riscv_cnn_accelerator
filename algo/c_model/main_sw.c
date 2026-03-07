#include <stdio.h>
#include "model_data.h"
int main() {
    int32_t c_res = 0;
    for(int i=0; i<16; i++) c_res += (int32_t)EXPECTED_W[i] * (int32_t)EXPECTED_D[i];
    printf("C Result: %d, Python Ref: %d\n", c_res, PYTHON_GOLDEN_REF);
    if(c_res == PYTHON_GOLDEN_REF) printf(">>> SW VERIFICATION SUCCESS!\n");
    return 0;
}
