# Final Defense Plan

## Goal

Prepare a final defense package that matches the thesis and engineering evidence.

## Slide Structure

1. Title and project goal
2. Background and motivation
3. Overall system architecture
4. E203v2 and NICE integration
5. CNN accelerator RTL design
6. RTL verification evidence
7. full-SoC SDK verification evidence
8. FPGA bring-up flow
9. Board runtime evidence
10. Current blocker and debug plan
11. Contribution summary
12. Future work

## Main Message

The project has completed RTL/NICE and full-SoC verification. The remaining closure work focuses on board-level runtime evidence and soft-core debug on Davinci Pro A7-100T.

## Evidence Package

- Branch and commit table
- RTL `[TB_PASS]` screenshot
- full-SoC `expected_rstat=19` screenshot
- Vivado `xc7a100t_0` detection screenshot
- `system.bit` generation record
- UART hello evidence
- CNN UART result evidence
- ILA PC and NICE handshake evidence

## QA Preparation

Prepare answers for:

- Why use RISC-V and NICE?
- What does the accelerator compute?
- How was RTL verified?
- What does full-SoC simulation prove?
- How does the program enter the bitstream?
- Why is soft-core debug still a blocker?
- What is the difference between PTD04 programming and CPU debugging?
- What is the next step if UART has no output?

## Rehearsal Plan

- 8 to 12 minute full version
- 3 minute short version
- 1 minute current status answer
- 30 second blocker answer

