# ================================
# img_to_hex.py  (HARDCODED, 12-bit input + scaled golden)
# ================================

import numpy as np
from PIL import Image

# ----------------------------
# CONFIGURE THESE
# ----------------------------
INPUT_IMAGE = "basic.jpg"   # put the image in the same folder as this script (or use full path)
WIDTH  = 1280
HEIGHT = 960

# Input to DUT (greyscale stage) width
WRITE_INPUT_BITS = 12            # your greyscale iDATA is 12-bit

# Golden generation (Sobel)
GENERATE_GOLDEN = True
EDGE_MODE = "omit"               # "omit" or "replicate"
KERNEL = "sobelmag"              # "sobelx", "sobely", "sobelmag"

# Prevent golden from saturating (bigger shift => darker, less clipping)
GOLDEN_SCALE_SHIFT = 4           # try 3, 4, or 5

# Write golden in 12-bit (recommended if your RTL output is 12-bit)
WRITE_GOLDEN_BITS = 12           # set to 8 if your convolution output is 8-bit
# ----------------------------


def save_hex(arr, filename, bits):
    arr = np.asarray(arr).reshape(-1)

    maxv = (1 << bits) - 1
    if arr.min() < 0:
        # clip negatives (Sobel intermediate can be negative before abs, but output shouldn't be)
        arr = np.clip(arr, 0, None)

    arr = np.clip(arr, 0, maxv)

    hex_digits = (bits + 3) // 4
    fmt = f"{{:0{hex_digits}X}}"

    with open(filename, "w", encoding="utf-8") as f:
        for v in arr:
            f.write(fmt.format(int(v)) + "\n")


def conv3x3(img_u8, kernel, edge_mode):
    img = img_u8.astype(np.int32)
    h, w = img.shape

    if edge_mode == "replicate":
        pad = np.pad(img, ((1, 1), (1, 1)), mode="edge")
        out = np.zeros((h, w), dtype=np.int32)
        for r in range(h):
            for c in range(w):
                win = pad[r:r+3, c:c+3]
                out[r, c] = int(np.sum(win * kernel))
        return out

    # omit edges
    out = np.zeros((h, w), dtype=np.int32)
    for r in range(1, h - 1):
        for c in range(1, w - 1):
            win = img[r-1:r+2, c-1:c+2]
            out[r, c] = int(np.sum(win * kernel))
    return out


print("Loading image...")
img = Image.open(INPUT_IMAGE).convert("L")
img = img.resize((WIDTH, HEIGHT), Image.BILINEAR)
gray8 = np.array(img, dtype=np.uint8)

# 8-bit -> 12-bit input scaling (0..255 -> 0..4080)
# This matches what we were doing in the TB ({pix8, 4'b0})
gray12 = (gray8.astype(np.uint16) << 4)

save_hex(gray12, "input.hex", bits=WRITE_INPUT_BITS)
print(f"Wrote input.hex ({WRITE_INPUT_BITS}-bit), {WIDTH}x{HEIGHT}")

if GENERATE_GOLDEN:
    print("Generating golden output...")

    kx = np.array([[-1, 0, 1],
                   [-2, 0, 2],
                   [-1, 0, 1]], dtype=np.int32)
    ky = np.array([[-1, -2, -1],
                   [ 0,  0,  0],
                   [ 1,  2,  1]], dtype=np.int32)

    gx = conv3x3(gray8, kx, EDGE_MODE)
    gy = conv3x3(gray8, ky, EDGE_MODE)

    if KERNEL == "sobelx":
        mag = np.abs(gx)
    elif KERNEL == "sobely":
        mag = np.abs(gy)
    else:
        mag = np.abs(gx) + np.abs(gy)

    # Scale down BEFORE clipping so it doesn't blow out
    mag = (mag >> GOLDEN_SCALE_SHIFT)

    # If writing 12-bit golden, map into 0..4095 range naturally
    # If writing 8-bit golden, keep 0..255
    if WRITE_GOLDEN_BITS == 12:
        mag = np.clip(mag, 0, 4095).astype(np.uint16)
        save_hex(mag, "golden.hex", bits=12)
        print(f"Wrote golden.hex (12-bit) kernel={KERNEL} scale_shift={GOLDEN_SCALE_SHIFT}")
    else:
        mag8 = np.clip(mag, 0, 255).astype(np.uint8)
        save_hex(mag8, "golden.hex", bits=8)
        print(f"Wrote golden.hex (8-bit) kernel={KERNEL} scale_shift={GOLDEN_SCALE_SHIFT}")

print("Done.")
