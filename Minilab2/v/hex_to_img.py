# ================================
# hex_to_img.py  (HARDCODED)
# ================================

import numpy as np
from PIL import Image

# ----------------------------
# CONFIGURE THESE
# ----------------------------
INPUT_HEX = "dut_out.hex"
OUTPUT_IMAGE = "golden_output.png"
WIDTH  = 1280
HEIGHT = 960
BITS = 12
# ----------------------------


def read_hex(filename):
    vals = []
    with open(filename, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            vals.append(int(line, 16))
    return np.array(vals)


print("Reading hex file...")
data = read_hex(INPUT_HEX)

expected = WIDTH * HEIGHT
if len(data) < expected:
    raise ValueError("Not enough pixels in hex file")

data = data[:expected]
maxv = (1 << BITS) - 1
data = np.clip(data, 0, maxv)

if BITS != 8:
    data = (data * (255.0 / maxv)).astype(np.uint8)
else:
    data = data.astype(np.uint8)

img = data.reshape((HEIGHT, WIDTH))
Image.fromarray(img, mode="L").save(OUTPUT_IMAGE)

print(f"Wrote {OUTPUT_IMAGE}")
print("Done.")
