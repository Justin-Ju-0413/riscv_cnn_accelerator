import numpy as np
import os
def generate_golden_model():
    weights = np.random.randint(-128, 127, size=16, dtype=np.int8)
    data = np.random.randint(-128, 127, size=16, dtype=np.int8)
    weights[0], data[0] = -2, 5
    golden_result = np.sum(weights.astype(np.int32) * data.astype(np.int32))
    out_path = os.path.join(os.path.dirname(__file__), '../c_model/model_data.h')
    with open(out_path, "w") as f:
        f.write("#include <stdint.h>\n")
        f.write(f"const int8_t EXPECTED_W[16] = {{{', '.join(map(str, weights))}}};\n")
        f.write(f"const int8_t EXPECTED_D[16] = {{{', '.join(map(str, data))}}};\n")
        f.write(f"const int32_t PYTHON_GOLDEN_REF = {golden_result};\n")
    print(f"Python Golden Ref: {golden_result}")
if __name__ == "__main__": generate_golden_model()
