# NICE v2 research ABI and minimal ICB proof of concept

Status: ABI draft for the MPhil research branch
Compatibility rule: legacy funct7 values `0–5` remain unchanged

## Purpose

NICE v2 adds capability discovery and a memory-backed execution path without changing
the undergraduate CNN interface. It is a custom research prototype. It does not
claim conformance with draft RISC-V IME, VME, or AME proposals.

## Instruction map

| funct7 | Name | Phase-one behavior |
|---:|---|---|
| 0 | `WLOAD` | unchanged: load one packed legacy weight vector |
| 1 | `DLOAD` | unchanged: load one packed legacy activation vector |
| 2 | `COMP` | unchanged: execute the legacy 4×4 PE operation |
| 3 | `RSTAT` | unchanged: read the legacy accumulated result |
| 4 | `CLEAR` | unchanged: clear legacy operation state |
| 5 | `CFG` | unchanged: configure legacy ReLU |
| 6 | `CAP` | return ABI version and implemented capability bits |
| 7 | `MCFG` | reserved in the proof of concept; returns an error |
| 8 | `MLOAD` | aligned, single-word ICB read into a scratchpad |
| 9 | `MEXEC` | reserved in the proof of concept; returns an error |
| 10 | `MSTORE` | reserved in the proof of concept; returns an error |
| 11 | `MSTAT` | proof-of-concept scratchpad readback |

Unsupported commands fail explicitly. Software must query `CAP` rather than infer
support from the presence of an instruction number.

## `CAP` result

| Bits | Meaning |
|---|---|
| 31:24 | ABI major, currently `2` |
| 23:16 | ABI minor, currently `0` |
| 15:8 | scratchpad words per implemented bank |
| 7 | legacy funct7 `0–5` preserved |
| 6:5 | reserved, zero |
| 4 | memory timeout detection |
| 3 | `MSTAT` proof-of-concept readback |
| 2 | weight scratchpad |
| 1 | activation scratchpad |
| 0 | aligned single-word ICB read |

Phase-one expected value for 16-word banks is `0x0200109F`.

## `MLOAD` encoding and transaction

- `rs1`: 32-bit byte address; bits `[1:0]` must be zero.
- `rs2[4]`: bank, `0` for activation and `1` for weight.
- `rs2[3:0]`: word index within the bank.
- `rs2[31:5]`: reserved and must be zero.
- response data: zero on success.
- response error: asserted for invalid encoding, misalignment, ICB error, or timeout.

Only one memory operation can be outstanding. The core holds `nice_mem_holdup` while
the operation is active, keeps the ICB command stable until accepted, then waits for
one response. Phase one does not issue bursts and does not overlap compute.

## `MSTAT` proof-of-concept behavior

- `rs2` uses the same bank/index encoding as `MLOAD`.
- returns the selected 32-bit scratchpad word.
- returns an error if the encoding is invalid or the word has not been loaded since
  reset.

This readback exists to make the first `memory → scratchpad → observed result`
experiment self-checking. It is not the final performance interface.

## Future `MCFG`, `MEXEC`, and `MSTORE`

`MCFG` will describe operator, precision, tile dimensions, scratchpad region, and
tail behavior. `MEXEC` will launch GEMM, convolution, or scan after validating the
configuration. `MSTORE` will write an output region through the ICB channel.

These commands are intentionally not implemented until the single-read path has
quantified value. Their final bit fields must be frozen together with the C wrappers
and benchmark shapes.

## Scratchpad organization

The proof of concept implements two parameterized banks:

- activation scratchpad: 16 × 32-bit words by default;
- weight scratchpad: 16 × 32-bit words by default.

State and output banks are architectural requirements for the tiled tensor/scan
revision, not claims about the phase-one RTL. Valid bits distinguish reset state from
loaded data. Increasing depth must update the capability field and bounds checks.

## Directed verification

The phase-one RTL test must cover:

- capability value;
- command backpressure and stable address;
- successful activation and weight loads;
- `MSTAT` readback;
- unaligned address;
- reserved `rs2` bits;
- ICB response error;
- reset invalidation;
- command or response timeout;
- explicit errors for reserved `MCFG`, `MEXEC`, and `MSTORE`;
- unchanged original 19-test regression.

Full-SoC regression continues to execute the legacy SDK application. Passing it
proves backward compatibility only; it does not prove tiled GEMM, network accuracy,
Vivado timing, or a fresh board result.
