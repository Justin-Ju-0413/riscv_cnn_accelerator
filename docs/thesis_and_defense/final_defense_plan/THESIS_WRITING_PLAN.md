# Thesis Writing Plan

## Goal

Write the thesis in parallel with engineering closure. The thesis should describe what was built, how it was verified, and what remains open.

## Chapter Plan

1. Introduction
   - CNN acceleration background
   - RISC-V custom instruction motivation
   - project goal and scope

2. Related Work
   - CNN accelerators
   - FPGA-based acceleration
   - RISC-V custom instruction and coprocessor methods
   - E203/NICE-style SoC integration

3. System Architecture
   - E203v2 soft-core
   - NICE custom instruction path
   - CNN accelerator structure
   - software/hardware execution flow

4. RTL Design and Verification
   - PE and PE array
   - controller and data path
   - local RTL regression
   - key evidence: `[TB_PASS]`

5. Full-SoC Integration and Verification
   - SDK app build
   - ELF to Verilog image
   - ITCM/DTCM split
   - full-SoC simulation
   - key evidence: `expected_rstat=19`, `[PHASE4_PASS]`

6. FPGA Bring-Up and Board Evidence
   - Davinci Pro A7-100T environment
   - bitstream and JTAG programming
   - UART/LED/ILA evidence
   - soft-core debug blocker

7. Conclusion and Future Work
   - completed work
   - limitations
   - future debug bridge and board-level improvements

## Figure List

- System architecture diagram
- NICE request/response flow
- CNN accelerator block diagram
- RTL regression screenshot
- full-SoC regression screenshot
- FPGA bring-up flow diagram
- UART/ILA evidence screenshots

## Reference Plan

Collect references in these groups:

- RISC-V ISA and custom instruction documents
- Nuclei E203/NICE documentation
- CNN accelerator papers
- FPGA CNN acceleration surveys
- OpenOCD/GDB/Vivado engineering documents

## Writing Rule

Do not claim that GDB single-step debug is closed unless there is direct evidence. The thesis should state that soft-core debug is the current board-level blocker.

