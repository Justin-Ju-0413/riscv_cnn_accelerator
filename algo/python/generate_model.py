import os


def generate_golden_model():
    weights = [-2, 34, 12, -56, 91, -77, 5, 18, -99, 43, 27, -11, 64, -8, 3, 120]
    data = [5, -9, 44, 7, -12, 88, -31, 6, 14, -5, 19, -64, 22, 11, -3, 9]
    golden_result = sum(w * d for w, d in zip(weights, data))
    out_path = os.path.join(os.path.dirname(__file__), '../c_model/model_data.h')
    with open(out_path, "w") as f:
        f.write("#include <stdint.h>\n")
        f.write(f"const int8_t EXPECTED_W[16] = {{{', '.join(map(str, weights))}}};\n")
        f.write(f"const int8_t EXPECTED_D[16] = {{{', '.join(map(str, data))}}};\n")
        f.write(f"const int32_t PYTHON_GOLDEN_REF = {golden_result};\n")
    print(f"Python Golden Ref: {golden_result}")


if __name__ == "__main__":
    generate_golden_model()
