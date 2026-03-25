import os


CNN_V1_INPUT = [
    1, -2, 3, 0,
    4, 5, -6, 1,
    -7, 8, 9, -10,
    11, -12, 13, 14,
]

CNN_V1_KERNEL = [
    2, -1, 0,
    -3, 1, 4,
    1, -2, 3,
]


def conv2d_valid_4x4(input_4x4, kernel_3x3):
    output = []
    for row in range(2):
        out_row = []
        for col in range(2):
            acc = 0
            for kr in range(3):
                for kc in range(3):
                    acc += input_4x4[(row + kr) * 4 + (col + kc)] * kernel_3x3[kr * 3 + kc]
            out_row.append(acc)
        output.append(out_row)
    return output


def relu_matrix(matrix_2x2):
    return [[max(value, 0) for value in row] for row in matrix_2x2]


def flatten(matrix_2x2):
    return [value for row in matrix_2x2 for value in row]


def emit_array(f, c_type, name, values):
    body = ", ".join(str(value) for value in values)
    f.write(f"const {c_type} {name}[{len(values)}] = {{{body}}};\n")


def generate_golden_model():
    conv = conv2d_valid_4x4(CNN_V1_INPUT, CNN_V1_KERNEL)
    relu = relu_matrix(conv)
    out_path = os.path.join(os.path.dirname(__file__), "../c_model/model_data.h")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("#ifndef MODEL_DATA_H\n")
        f.write("#define MODEL_DATA_H\n\n")
        f.write("#include <stdint.h>\n\n")
        f.write("/* Fixed golden case for the minimal CNN v1 host reference. */\n")
        f.write("enum {\n")
        f.write("    CNN_V1_INPUT_H = 4,\n")
        f.write("    CNN_V1_INPUT_W = 4,\n")
        f.write("    CNN_V1_KERNEL_H = 3,\n")
        f.write("    CNN_V1_KERNEL_W = 3,\n")
        f.write("    CNN_V1_OUTPUT_H = 2,\n")
        f.write("    CNN_V1_OUTPUT_W = 2,\n")
        f.write("};\n\n")
        emit_array(f, "int8_t", "CNN_V1_INPUT", CNN_V1_INPUT)
        emit_array(f, "int8_t", "CNN_V1_KERNEL", CNN_V1_KERNEL)
        emit_array(f, "int32_t", "CNN_V1_CONV_GOLDEN", flatten(conv))
        emit_array(f, "int32_t", "CNN_V1_RELU_GOLDEN", flatten(relu))
        f.write("\n#endif /* MODEL_DATA_H */\n")
    print("Python CNN v1 golden ref:")
    for row in conv:
        print("  ", row)
    print("Python CNN v1 ReLU ref:")
    for row in relu:
        print("  ", row)


if __name__ == "__main__":
    generate_golden_model()
