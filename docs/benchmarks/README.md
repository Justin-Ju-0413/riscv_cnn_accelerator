# Benchmark Record Guide

This directory stores future benchmark records for the RISC-V/E203 NICE CNN
accelerator. Use one record per meaningful experiment, design change, or board
run.

## Create A Record

```bash
./Project_Manager.sh new_benchmark_record short-name
```

The script creates a Markdown file under `docs/benchmarks/records/`.

## Required Evidence Fields

Each record should capture:

- test scope: RTL, FullSoC, board UART, board ILA, or full network
- design baseline: branch, commit, board, bitstream, and relevant config
- correctness result: expected output, actual output, and pass/fail status
- performance: CPU-only cycles, accelerator cycles, and speedup
- hardware cost: LUT, FF, BRAM, DSP, WNS, and WHS
- logs: command output, UART text, ILA summary, or attached artifact path
- claim boundary: exactly what the result proves and what it does not prove

## Reporting Rules

- `5.282x` is only the current 3x3 convolution-kernel benchmark unless a new
  record proves a different scope.
- `10/10` is only the current FPGA board sample demonstration unless a new
  record proves a larger sample set.
- Full LeNet-5 or full MNIST claims require an end-to-end dataset-level record.
- New buffering, line-buffer, or operator results must include reference-model
  comparison before they are treated as validated.

