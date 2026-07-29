#!/usr/bin/env python3
"""Deterministic integer golden models for the MPhil tensor/scan microbenchmarks.

The models intentionally use plain Python integers and explicit loops. They are
reference behavior, not performance implementations and not a quantized network
accuracy claim.
"""

from __future__ import annotations

import argparse
import json
from collections.abc import Sequence
from typing import Any


def _matrix_shape(matrix: Sequence[Sequence[int]], name: str) -> tuple[int, int]:
    if not matrix or not matrix[0]:
        raise ValueError(f"{name} must be non-empty")
    columns = len(matrix[0])
    if any(len(row) != columns for row in matrix):
        raise ValueError(f"{name} must be rectangular")
    return len(matrix), columns


def matmul_i8(
    lhs: Sequence[Sequence[int]], rhs: Sequence[Sequence[int]]
) -> list[list[int]]:
    """Multiply two integer matrices with unbounded reference accumulation."""

    lhs_rows, lhs_columns = _matrix_shape(lhs, "lhs")
    rhs_rows, rhs_columns = _matrix_shape(rhs, "rhs")
    if lhs_columns != rhs_rows:
        raise ValueError("matmul inner dimensions must match")

    result = [[0 for _ in range(rhs_columns)] for _ in range(lhs_rows)]
    for row in range(lhs_rows):
        for column in range(rhs_columns):
            accumulator = 0
            for inner in range(lhs_columns):
                accumulator += int(lhs[row][inner]) * int(rhs[inner][column])
            result[row][column] = accumulator
    return result


def _chw_shape(
    tensor: Sequence[Sequence[Sequence[int]]], name: str
) -> tuple[int, int, int]:
    if not tensor:
        raise ValueError(f"{name} must contain at least one channel")
    height, width = _matrix_shape(tensor[0], f"{name}[0]")
    for channel, plane in enumerate(tensor[1:], start=1):
        if _matrix_shape(plane, f"{name}[{channel}]") != (height, width):
            raise ValueError(f"{name} channels must share one shape")
    return len(tensor), height, width


def conv2d_valid_i8(
    activation: Sequence[Sequence[Sequence[int]]],
    weight: Sequence[Sequence[Sequence[Sequence[int]]]],
    bias: Sequence[int] | None = None,
) -> list[list[list[int]]]:
    """Reference N=1, CHW activation and OIHW valid convolution."""

    input_channels, input_height, input_width = _chw_shape(
        activation, "activation"
    )
    if not weight:
        raise ValueError("weight must contain at least one output channel")
    if any(len(output_kernel) != input_channels for output_kernel in weight):
        raise ValueError("weight input-channel count must match activation")

    _, kernel_height, kernel_width = _chw_shape(weight[0], "weight[0]")
    for output_channel, output_kernel in enumerate(weight[1:], start=1):
        if _chw_shape(output_kernel, f"weight[{output_channel}]") != (
            input_channels,
            kernel_height,
            kernel_width,
        ):
            raise ValueError("all output kernels must share one shape")

    output_height = input_height - kernel_height + 1
    output_width = input_width - kernel_width + 1
    if output_height <= 0 or output_width <= 0:
        raise ValueError("kernel must fit inside activation")
    if bias is not None and len(bias) != len(weight):
        raise ValueError("bias length must match output channels")

    output = [
        [[0 for _ in range(output_width)] for _ in range(output_height)]
        for _ in weight
    ]
    for output_channel, output_kernel in enumerate(weight):
        for output_row in range(output_height):
            for output_column in range(output_width):
                accumulator = 0 if bias is None else int(bias[output_channel])
                for input_channel in range(input_channels):
                    for kernel_row in range(kernel_height):
                        for kernel_column in range(kernel_width):
                            accumulator += (
                                int(
                                    activation[input_channel][
                                        output_row + kernel_row
                                    ][output_column + kernel_column]
                                )
                                * int(
                                    output_kernel[input_channel][kernel_row][
                                        kernel_column
                                    ]
                                )
                            )
                output[output_channel][output_row][output_column] = accumulator
    return output


def depthwise_conv2d_valid_i8(
    activation: Sequence[Sequence[Sequence[int]]],
    weight: Sequence[Sequence[Sequence[int]]],
    bias: Sequence[int] | None = None,
) -> list[list[list[int]]]:
    """Reference depthwise valid convolution with channel multiplier one."""

    channels, input_height, input_width = _chw_shape(activation, "activation")
    weight_channels, kernel_height, kernel_width = _chw_shape(weight, "weight")
    if channels != weight_channels:
        raise ValueError("depthwise weight count must match activation channels")
    if bias is not None and len(bias) != channels:
        raise ValueError("bias length must match channels")

    output_height = input_height - kernel_height + 1
    output_width = input_width - kernel_width + 1
    if output_height <= 0 or output_width <= 0:
        raise ValueError("kernel must fit inside activation")

    output = [
        [[0 for _ in range(output_width)] for _ in range(output_height)]
        for _ in range(channels)
    ]
    for channel in range(channels):
        for output_row in range(output_height):
            for output_column in range(output_width):
                accumulator = 0 if bias is None else int(bias[channel])
                for kernel_row in range(kernel_height):
                    for kernel_column in range(kernel_width):
                        accumulator += (
                            int(
                                activation[channel][output_row + kernel_row][
                                    output_column + kernel_column
                                ]
                            )
                            * int(weight[channel][kernel_row][kernel_column])
                        )
                output[channel][output_row][output_column] = accumulator
    return output


def ssm_scan_i32(
    inputs: Sequence[int],
    *,
    a: int,
    b: int,
    c: int,
    d: int = 0,
    initial_state: int = 0,
) -> tuple[list[int], list[int]]:
    """Scalar integer recurrence used to pin down scan ordering.

    h[t] = a * h[t-1] + b * x[t]
    y[t] = c * h[t] + d * x[t]
    """

    state = int(initial_state)
    states: list[int] = []
    outputs: list[int] = []
    for value in inputs:
        input_value = int(value)
        state = int(a) * state + int(b) * input_value
        states.append(state)
        outputs.append(int(c) * state + int(d) * input_value)
    return outputs, states


def _weighted_checksum(value: Any) -> int:
    flattened: list[int] = []

    def visit(item: Any) -> None:
        if isinstance(item, (list, tuple)):
            for child in item:
                visit(child)
        else:
            flattened.append(int(item))

    visit(value)
    return sum((index + 1) * item for index, item in enumerate(flattened))


def run_reference_suite() -> dict[str, dict[str, Any]]:
    """Run fixed GEMM, convolution, depthwise, and SSM cases."""

    gemm = matmul_i8(
        [[1, -2, 3], [4, 0, -1]],
        [[2, 1], [-1, 3], [0, -2]],
    )
    conv3x3 = conv2d_valid_i8(
        [
            [
                [1, 2, 3, 4],
                [5, 6, 7, 8],
                [9, 10, 11, 12],
                [13, 14, 15, 16],
            ]
        ],
        [[[[1, 0, -1], [1, 0, -1], [1, 0, -1]]]],
    )
    conv1x1 = conv2d_valid_i8(
        [[[1, 2], [3, 4]], [[5, 6], [7, 8]]],
        [[[[2]], [[-1]]], [[[-1]], [[3]]]],
        bias=[1, -2],
    )
    depthwise = depthwise_conv2d_valid_i8(
        [
            [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
            [[9, 8, 7], [6, 5, 4], [3, 2, 1]],
        ],
        [[[1, 0], [0, -1]], [[0, 1], [-1, 0]]],
    )
    scan_output, scan_state = ssm_scan_i32(
        [1, 2, -1, 3], a=2, b=1, c=3, d=1
    )

    cases = {
        "gemm": {"shape": [2, 2], "output": gemm},
        "conv3x3": {"shape": [1, 2, 2], "output": conv3x3},
        "conv1x1": {"shape": [2, 2, 2], "output": conv1x1},
        "depthwise": {"shape": [2, 2, 2], "output": depthwise},
        "ssm_scan": {
            "shape": [4],
            "output": scan_output,
            "state": scan_state,
        },
    }
    for case in cases.values():
        case["checksum"] = _weighted_checksum(
            [case["output"], case.get("state", [])]
        )
    return cases


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--compact",
        action="store_true",
        help="emit compact JSON rather than indented JSON",
    )
    args = parser.parse_args()
    print(
        json.dumps(
            run_reference_suite(),
            indent=None if args.compact else 2,
            sort_keys=True,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
