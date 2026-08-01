#!/usr/bin/env python3
"""Unit tests for the MPhil tensor/scan golden models."""

import unittest

from mphil_microbench import (
    conv2d_valid_i8,
    depthwise_conv2d_valid_i8,
    matmul_i8,
    run_reference_suite,
    ssm_scan_i32,
)


class TensorScanGoldenTest(unittest.TestCase):
    def test_matmul(self) -> None:
        self.assertEqual(
            matmul_i8(
                [[1, -2, 3], [4, 0, -1]],
                [[2, 1], [-1, 3], [0, -2]],
            ),
            [[4, -11], [8, 6]],
        )

    def test_matmul_dimension_error(self) -> None:
        with self.assertRaises(ValueError):
            matmul_i8([[1, 2]], [[1, 2]])

    def test_multichannel_1x1_convolution(self) -> None:
        self.assertEqual(
            conv2d_valid_i8(
                [[[1, 2], [3, 4]], [[5, 6], [7, 8]]],
                [[[[2]], [[-1]]], [[[-1]], [[3]]]],
                bias=[1, -2],
            ),
            [
                [[-2, -1], [0, 1]],
                [[12, 14], [16, 18]],
            ],
        )

    def test_three_by_three_convolution(self) -> None:
        self.assertEqual(
            conv2d_valid_i8(
                [
                    [
                        [1, 2, 3, 4],
                        [5, 6, 7, 8],
                        [9, 10, 11, 12],
                        [13, 14, 15, 16],
                    ]
                ],
                [[[[1, 0, -1], [1, 0, -1], [1, 0, -1]]]],
            ),
            [[[-6, -6], [-6, -6]]],
        )

    def test_depthwise_convolution(self) -> None:
        self.assertEqual(
            depthwise_conv2d_valid_i8(
                [
                    [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
                    [[9, 8, 7], [6, 5, 4], [3, 2, 1]],
                ],
                [[[1, 0], [0, -1]], [[0, 1], [-1, 0]]],
            ),
            [
                [[-4, -4], [-4, -4]],
                [[2, 2], [2, 2]],
            ],
        )

    def test_ssm_scan_ordering(self) -> None:
        output, state = ssm_scan_i32(
            [1, 2, -1, 3], a=2, b=1, c=3, d=1
        )
        self.assertEqual(state, [1, 4, 7, 17])
        self.assertEqual(output, [4, 14, 20, 54])

    def test_reference_suite_is_stable(self) -> None:
        suite = run_reference_suite()
        self.assertEqual(
            sorted(suite),
            ["conv1x1", "conv3x3", "depthwise", "gemm", "ssm_scan"],
        )
        self.assertEqual(suite["gemm"]["checksum"], 30)
        self.assertEqual(suite["ssm_scan"]["checksum"], 522)


if __name__ == "__main__":
    unittest.main(verbosity=2)
