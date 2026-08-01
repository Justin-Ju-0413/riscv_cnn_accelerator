#!/usr/bin/env python3
"""
LeNet-5 INT8 Inference Calibration & Verification

This script:
1. Parses the C header files (lenet5_weights.h, mnist_test_images.h) to get
   INT8 weights and test data
2. Runs LeNet-5 inference with the CORRECT ReLU placement
   (Conv1: ReLU after conv, Conv2: ReLU AFTER multi-channel accumulation)
3. Sweeps shift values to find optimal calibration
4. Optionally generates updated lenet5_shifts.h

Usage:
  python calibrate_lenet5.py              # verify current shifts
  python calibrate_lenet5.py --sweep      # search for optimal shifts
  python calibrate_lenet5.py --generate   # generate lenet5_shifts.h
"""

import re
import sys
import os
import struct
import gzip
import math
from pathlib import Path

# ---------------------------------------------------------------------------
# Parse C header files
# ---------------------------------------------------------------------------

def parse_int8_array(text, name):
    """Parse 'static const int8_t name[SIZE] = { ... };' from C source."""
    pattern = rf'static const int8_t {name}\[\d+\]\s*=\s*\{{([^}}]+)\}}'
    m = re.search(pattern, text, re.DOTALL)
    if not m:
        raise ValueError(f"Could not find {name} in source")
    body = m.group(1)
    values = [int(x.strip()) for x in body.split(',') if x.strip()]
    return values


def parse_int32_array(text, name):
    """Parse 'static const int32_t name[SIZE] = { ... };'."""
    pattern = rf'static const int32_t {name}\[\d+\]\s*=\s*\{{([^}}]+)\}}'
    m = re.search(pattern, text, re.DOTALL)
    if not m:
        raise ValueError(f"Could not find {name} in source")
    body = m.group(1)
    values = [int(x.strip()) for x in body.split(',') if x.strip()]
    return values


def parse_uint8_array(text, name):
    """Parse 'static const uint8_t name[SIZE] = { ... };'."""
    pattern = rf'static const uint8_t {name}\[\d+\]\s*=\s*\{{([^}}]+)\}}'
    m = re.search(pattern, text, re.DOTALL)
    if not m:
        raise ValueError(f"Could not find {name} in source")
    body = m.group(1)
    values = [int(x.strip()) for x in body.split(',') if x.strip()]
    return values


# ---------------------------------------------------------------------------
# LeNet-5 INT8 Inference (matching C code exactly)
# ---------------------------------------------------------------------------

def conv2d_int8(input_map, H, W, kernel, K, bias, relu):
    """
    INT8 convolution, single input channel.
    Returns INT32 feature map (H-K+1) x (W-K+1).
    relu=1 applies ReLU to output, relu=0 returns raw.
    """
    Ho = H - K + 1
    Wo = W - K + 1
    out = []
    for oy in range(Ho):
        for ox in range(Wo):
            acc = 0
            for ky in range(K):
                for kx in range(K):
                    acc += int(kernel[ky * K + kx]) * int(input_map[(oy + ky) * W + (ox + kx)])
            val = acc + bias
            if relu and val < 0:
                val = 0
            out.append(val)
    return out


def maxpool_2x2(fm, H, W):
    """INT32 2x2 max pooling."""
    H2 = H // 2
    W2 = W // 2
    out = []
    for y in range(H2):
        for x in range(W2):
            m = fm[(y * 2) * W + (x * 2)]
            v = fm[(y * 2) * W + (x * 2 + 1)]
            if v > m: m = v
            v = fm[(y * 2 + 1) * W + (x * 2)]
            if v > m: m = v
            v = fm[(y * 2 + 1) * W + (x * 2 + 1)]
            if v > m: m = v
            out.append(m)
    return out


def fc_layer(input_vec, weights, bias, No, relu, rshift):
    """INT8 weights * INT32 input -> INT32 output with right-shift rescaling."""
    Ni = len(input_vec)
    out = []
    for j in range(No):
        s = bias[j] if bias else 0
        for i in range(Ni):
            s += int(weights[j * Ni + i]) * int(input_vec[i])
        s = s >> rshift
        if relu and s < 0:
            s = 0
        out.append(s)
    return out


def argmax(vec):
    best_idx = 0
    best_val = vec[0]
    for i, v in enumerate(vec):
        if v > best_val:
            best_val = v
            best_idx = i
    return best_idx


def lenet5_inference(img_uint8, weights, shifts):
    """
    Full LeNet-5 inference with correct ReLU placement.

    Architecture:
      Conv1: 1x28x28 -> 6x24x24, 5x5 kernel, ReLU
      Pool1: 6x24x24 -> 6x12x12, 2x2 maxpool
      Conv2: 6x12x12 -> 16x8x8, 5x5 kernel, ReLU AFTER summing all 6 channels
      Pool2: 16x8x8 -> 16x4x4, 2x2 maxpool
      FC1: 256 -> 120, ReLU
      FC2: 120 -> 84, ReLU
      FC3: 84 -> 10, linear
    """
    # Input: uint8 [0,255] -> int8 [-128,127]
    img = [(int(p) - 128) for p in img_uint8]

    # ---- Conv1: 1ch -> 6ch, kernel 5x5 ----
    fm1 = []  # 6 x 24 x 24
    for k in range(6):
        kern = weights['conv1_weight'][k*25:(k+1)*25]
        bias = weights['conv1_bias'][k]
        ch_out = conv2d_int8(img, 28, 28, kern, 5, bias, relu=1)
        fm1.extend(ch_out)

    # ---- Pool1: 6x24x24 -> 6x12x12 ----
    p1 = []
    for k in range(6):
        ch = fm1[k*576:(k+1)*576]  # 24*24=576
        ch_pool = maxpool_2x2(ch, 24, 24)
        p1.extend(ch_pool)

    # ---- Conv2: 6ch -> 16ch, kernel 5x5 ----
    # CRITICAL: NICE conv per-channel, sum over input channels, THEN ReLU
    fm2 = []  # 16 x 8 x 8 = 1024
    conv2_in_rshift = shifts.get('conv2_input_rshift', 8)

    for ko in range(16):
        # Initialize with bias
        ch_out = [weights['conv2_bias'][ko]] * 64  # 8*8=64

        for ki in range(6):
            # Rescale INT32 pool output back to INT8
            ch_in = []
            for i in range(144):  # 12x12=144
                v = p1[ki * 144 + i] >> conv2_in_rshift
                if v > 127: v = 127
                elif v < -128: v = -128
                ch_in.append(v)

            kern = weights['conv2_weight'][(ko * 6 + ki) * 25:(ko * 6 + ki + 1) * 25]
            tmp = conv2d_int8(ch_in, 12, 12, kern, 5, 0, relu=0)  # NO ReLU per-channel!

            for i in range(64):
                ch_out[i] += tmp[i]

        # ReLU AFTER summing all input channels
        for i in range(64):
            if ch_out[i] < 0:
                ch_out[i] = 0

        fm2.extend(ch_out)

    # ---- Pool2: 16x8x8 -> 16x4x4 ----
    p2 = []
    for k in range(16):
        ch = fm2[k*64:(k+1)*64]
        ch_pool = maxpool_2x2(ch, 8, 8)
        p2.extend(ch_pool)

    # ---- FC1: 256 -> 120 ----
    f1 = fc_layer(p2, weights['fc1_weight'], weights['fc1_bias'],
                  120, relu=1, rshift=shifts['fc1_rshift'])

    # ---- FC2: 120 -> 84 ----
    f2 = fc_layer(f1, weights['fc2_weight'], weights['fc2_bias'],
                  84, relu=1, rshift=shifts['fc2_rshift'])

    # ---- FC3: 84 -> 10 ----
    f3 = fc_layer(f2, weights['fc3_weight'], weights['fc3_bias'],
                  10, relu=0, rshift=shifts['fc3_rshift'])

    return argmax(f3)


# ---------------------------------------------------------------------------
# MNIST data loading
# ---------------------------------------------------------------------------

def load_mnist_images(path, max_n=None):
    """Load MNIST IDX images file."""
    with gzip.open(path, 'rb') as f:
        magic, n, rows, cols = struct.unpack('>IIII', f.read(16))
        if max_n:
            n = min(n, max_n)
        data = f.read(n * rows * cols)
        return [list(data[i*rows*cols:(i+1)*rows*cols]) for i in range(n)]


def load_mnist_labels(path, max_n=None):
    """Load MNIST IDX labels file."""
    with gzip.open(path, 'rb') as f:
        magic, n = struct.unpack('>II', f.read(8))
        if max_n:
            n = min(n, max_n)
        return list(f.read(n))


# ---------------------------------------------------------------------------
# Load weights from C headers
# ---------------------------------------------------------------------------

def load_weights(project_root):
    """Parse all LeNet-5 weights from C header files."""
    weights_h = os.path.join(project_root, 'sw', 'inc', 'lenet5_weights.h')
    with open(weights_h, 'r') as f:
        text = f.read()

    return {
        'conv1_weight': parse_int8_array(text, 'lenet5_conv1_weight'),   # 150
        'conv1_bias': parse_int32_array(text, 'lenet5_conv1_bias'),       # 6
        'conv2_weight': parse_int8_array(text, 'lenet5_conv2_weight'),    # 2400
        'conv2_bias': parse_int32_array(text, 'lenet5_conv2_bias'),       # 16
        'fc1_weight': parse_int8_array(text, 'lenet5_fc1_weight'),        # 30720
        'fc1_bias': parse_int32_array(text, 'lenet5_fc1_bias'),           # 120
        'fc2_weight': parse_int8_array(text, 'lenet5_fc2_weight'),        # 10080
        'fc2_bias': parse_int32_array(text, 'lenet5_fc2_bias'),           # 84
        'fc3_weight': parse_int8_array(text, 'lenet5_fc3_weight'),        # 840
        'fc3_bias': parse_int32_array(text, 'lenet5_fc3_bias'),           # 10
    }


def load_shifts(project_root):
    """Parse shift values from lenet5_shifts.h."""
    shifts_h = os.path.join(project_root, 'sw', 'inc', 'lenet5_shifts.h')
    shifts = {}
    if os.path.exists(shifts_h):
        with open(shifts_h, 'r') as f:
            text = f.read()
        for name in ['CONV2_INPUT_RSHIFT', 'FC1_OUT_RSHIFT', 'FC2_OUT_RSHIFT', 'FC3_OUT_RSHIFT']:
            m = re.search(rf'#define {name}\s+(\d+)', text)
            if m:
                shifts[name.lower()] = int(m.group(1))
    return shifts


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    # Paths
    project_root = os.path.join(os.path.dirname(__file__), '..', '..')
    project_root = os.path.abspath(project_root)

    # MNIST data path
    mnist_dir = os.path.join(os.path.dirname(__file__), 'mnist_data')
    os.makedirs(mnist_dir, exist_ok=True)

    # Download MNIST if needed
    import urllib.request

    mnist_files = {
        'train-images-idx3-ubyte.gz':
            'https://ossci-datasets.s3.amazonaws.com/mnist/train-images-idx3-ubyte.gz',
        'train-labels-idx1-ubyte.gz':
            'https://ossci-datasets.s3.amazonaws.com/mnist/train-labels-idx1-ubyte.gz',
        't10k-images-idx3-ubyte.gz':
            'https://ossci-datasets.s3.amazonaws.com/mnist/t10k-images-idx3-ubyte.gz',
        't10k-labels-idx1-ubyte.gz':
            'https://ossci-datasets.s3.amazonaws.com/mnist/t10k-labels-idx1-ubyte.gz',
    }

    for fname, url in mnist_files.items():
        fpath = os.path.join(mnist_dir, fname)
        if not os.path.exists(fpath):
            print(f"Downloading {fname}...")
            urllib.request.urlretrieve(url, fpath)
            print(f"  done.")

    # Load weights
    print("Loading INT8 weights from C headers...")
    weights = load_weights(project_root)

    # Load shifts
    shifts_raw = load_shifts(project_root)
    shifts = {
        'conv2_input_rshift': shifts_raw.get('conv2_input_rshift', 8),
        'fc1_rshift': shifts_raw.get('fc1_out_rshift', 10),
        'fc2_rshift': shifts_raw.get('fc2_out_rshift', 10),
        'fc3_rshift': shifts_raw.get('fc3_out_rshift', 10),
    }
    print(f"Current shifts: {shifts}")

    # Load test images
    print("Loading MNIST test set...")
    test_images = load_mnist_images(os.path.join(mnist_dir, 't10k-images-idx3-ubyte.gz'))
    test_labels = load_mnist_labels(os.path.join(mnist_dir, 't10k-labels-idx1-ubyte.gz'))

    # Run inference
    if '--sweep' in sys.argv:
        sweep_shifts(weights, test_images, test_labels)
    else:
        evaluate(weights, shifts, test_images, test_labels)

    # Generate header if requested
    if '--generate' in sys.argv:
        # Find best shifts first
        best = find_best_shifts(weights, test_images[:1000], test_labels[:1000])
        generate_shifts_header(best, os.path.join(project_root, 'sw', 'inc', 'lenet5_shifts.h'))


def evaluate(weights, shifts, images, labels, max_n=1000):
    """Evaluate accuracy with given shifts."""
    correct = 0
    total = min(max_n, len(images))
    print(f"\nEvaluating {total} test images with shifts: {shifts}")
    for i in range(total):
        pred = lenet5_inference(images[i], weights, shifts)
        if pred == labels[i]:
            correct += 1
    acc = correct * 100.0 / total
    print(f"Accuracy: {correct}/{total} = {acc:.2f}%")
    return acc


def sweep_shifts(weights, images, labels):
    """Grid search for optimal shift values."""
    total = min(500, len(images))
    print(f"\nSweeping shifts on {total} images...")

    best_acc = 0
    best_shifts = None

    for c2 in range(6, 12):
        for fc1 in range(6, 12):
            for fc2 in range(6, 12):
                for fc3 in range(6, 12):
                    shifts = {
                        'conv2_input_rshift': c2,
                        'fc1_rshift': fc1,
                        'fc2_rshift': fc2,
                        'fc3_rshift': fc3,
                    }
                    correct = 0
                    for i in range(total):
                        pred = lenet5_inference(images[i], weights, shifts)
                        if pred == labels[i]:
                            correct += 1
                    acc = correct * 100.0 / total
                    if acc > best_acc:
                        best_acc = acc
                        best_shifts = dict(shifts)
                        print(f"  NEW BEST: {shifts} -> {acc:.2f}%")

    print(f"\nBest shifts: {best_shifts} -> {best_acc:.2f}%")
    return best_shifts


def find_best_shifts(weights, images, labels):
    """Find best shifts via coarse search (for --generate)."""
    return sweep_shifts(weights, images, labels)


def generate_shifts_header(shifts, out_path):
    """Generate lenet5_shifts.h from shift dict."""
    content = f"""// Auto-generated calibration shifts for LeNet-5 INT8 inference
// Generated by calibrate_lenet5.py
#ifndef LENET5_SHIFTS_H
#define LENET5_SHIFTS_H

// Pool1 output -> Conv2 INT8 input rescaling
#define CONV2_INPUT_RSHIFT {shifts['conv2_input_rshift']}

// FC layer output rescaling (applied inside fc() as right-shift)
#define FC1_OUT_RSHIFT {shifts['fc1_rshift']}
#define FC2_OUT_RSHIFT {shifts['fc2_rshift']}
#define FC3_OUT_RSHIFT {shifts['fc3_rshift']}

#endif
"""
    with open(out_path, 'w') as f:
        f.write(content)
    print(f"\nGenerated: {out_path}")


if __name__ == '__main__':
    main()
