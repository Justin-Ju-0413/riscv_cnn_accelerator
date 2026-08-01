#!/usr/bin/env python3
"""Quick validation of LeNet-5 configs on full MNIST test set."""
import os
from calibrate_lenet5 import *


if __name__ == '__main__':
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
    mnist_dir = os.path.join(os.path.dirname(__file__), 'mnist_data')

    weights = load_weights(project_root)
    test_images = load_mnist_images(os.path.join(mnist_dir, 't10k-images-idx3-ubyte.gz'))
    test_labels = load_mnist_labels(os.path.join(mnist_dir, 't10k-labels-idx1-ubyte.gz'))

    # Config A: Corrected ReLU + calibrated shifts
    print("=" * 60)
    print("Config A: Corrected ReLU + calibrated shifts (NEW)")
    shifts_a = {'conv2_input_rshift': 9, 'fc1_rshift': 8, 'fc2_rshift': 9, 'fc3_rshift': 9}
    evaluate(weights, shifts_a, test_images, test_labels, max_n=10000)

    # Config B: Old buggy shifts
    print("\n" + "=" * 60)
    print("Config B: Corrected ReLU + OLD hardcoded shifts")
    shifts_b = {'conv2_input_rshift': 8, 'fc1_rshift': 10, 'fc2_rshift': 10, 'fc3_rshift': 10}
    evaluate(weights, shifts_b, test_images, test_labels, max_n=10000)

    print("\n" + "=" * 60)
    print("Done.")
