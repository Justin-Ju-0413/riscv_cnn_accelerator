# Verification Report

## Test Scenario: 4x4 MAC Verification
- **Input Weights**: 16 integers of value `10` loaded into the 4x4 PE array over 4 `WLOAD` commands.
- **Input Activations**: 16 integers of value `2` loaded over 4 `DLOAD` commands.
- **Theoretical Result**: $10 \times 2 \times 16 = 320$.

## Execution Logs
Running `./Project_Manager.sh run_hw` yields:
```text
[CPU] Issuing CLEAR...
[CPU] Issuing WLOAD x4 (Weight: 0x0A0A0A0A)...
[CPU] Issuing DLOAD x4 (Activation: 0x02020202)...
[CPU] Issuing COMP...
[CPU] Issuing RSTAT...
>>> HW RESULT #1: 320
>>> HW RESULT #2: 136
```

## Timing Analysis
The GTKWave waveform confirms:
1. `nice_req_valid` pulses are correctly decoded for `CLEAR`, `WLOAD`, `DLOAD`, `COMP`, and `RSTAT`.
2. Four `WLOAD` and four `DLOAD` transactions populate all 16 PE weight and activation entries via `rs2[1:0]`.
3. `nice_rsp_valid` remains asserted until `nice_rsp_ready` acknowledges the response, while `nice_req_ready` stays low during the pending response window.
4. The checked response values are `0x00000140` (Dec: 320) and `0x00000088` (Dec: 136).
