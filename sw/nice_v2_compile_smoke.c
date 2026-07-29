#include <stdint.h>

#include "nice_v2.h"

uint32_t nice_v2_compile_smoke(const uint32_t *source)
{
    uint32_t capability = nice_v2_cap();

    if (NICE_V2_CAP_MAJOR(capability) != 2u ||
        (NICE_V2_CAP_FEATURES(capability) & NICE_V2_CAP_ICB_READ) == 0u) {
        return 0u;
    }

    nice_v2_mload(source, NICE_V2_SP_ACTIVATION, 0u);
    return nice_v2_mstat(NICE_V2_SP_ACTIVATION, 0u);
}

void nice_v2_reserved_wrapper_compile_smoke(uint32_t *destination)
{
    /*
     * Compile coverage only.  The phase-one CAP value does not advertise these
     * commands and software must not execute this function on the PoC RTL.
     */
    nice_v2_mcfg_raw(0u, 0u);
    nice_v2_mexec_raw(0u, 0u);
    nice_v2_mstore_raw(destination, NICE_V2_SP_SELECTOR(
        NICE_V2_SP_ACTIVATION, 0u));
}
