# Verification Report

## Test Scenario: 4x4 MAC Verification
- **Input Weights**: 4 integers of value `10` loaded into PEs.
- **Input Activations**: Fixed value of `2` simulated in testbench.
- **Theoretical Result**: $10 \times 2 \times 4 = 80$.

## Execution Logs
Running `./Project_Manager.sh run_hw` yields:
\`\`\`text
[CPU] Issuing WLOAD (Weight: 0x0A0A0A0A)...
[CPU] Issuing COMP...
[CPU] Issuing RSTAT...
>>> HW RESULT: 80
\`\`\`

## Timing Analysis
The GTKWave waveform confirms:
1. `nice_req_valid` pulses are correctly decoded.
2. `nice_rsp_valid` is asserted immediately after computation.
3. The 32-bit result `0x00000050` (Dec: 80) is correctly placed on `rdat`.
