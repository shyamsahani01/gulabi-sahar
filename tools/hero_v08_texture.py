"""Texture half of refine_hero_v08.py (runs in the system Python for scipy).
Inputs in the work dir: skin.npy (H,W,3 sRGB floats), tone.npy (baked per-vertex multiplier * 0.5),
mask.npy (baked photo weight), target.npy (photo skin tone).  Writes the corrected PNG.
"""
import sys, pathlib, numpy as np
from PIL import Image
from scipy.ndimage import gaussian_filter, distance_transform_edt
work = pathlib.Path(sys.argv[1]); out = pathlib.Path(sys.argv[2])
skin = np.load(work / 'skin.npy').astype(np.float64)
tone = np.load(work / 'tone.npy').astype(np.float64) * 2.0
masks = np.load(work / 'mask.npy').astype(np.float64)
mask = np.clip(masks[:, :, 0], 0, 1)
neck = np.clip(masks[:, :, 1], 0, 1)
under_eye = np.clip(masks[:, :, 2], 0, 1)
hairline = np.clip(np.load(work / 'zone.npy').astype(np.float64)[:, :, 0], 0, 1)
target = np.load(work / 'target.npy')
H, W, _ = skin.shape
covered = (tone.sum(axis=2) > 0.05)
tone[~covered] = 1.0
tone = np.clip(tone, 0.7, 1.35)
# Blur the correction slightly so triangle interpolation never shows.
tone = np.stack([gaussian_filter(tone[:, :, c], 1.5) for c in range(3)], axis=2)

# De-light the photo region: normalise its low-frequency luminance toward the target tone.
luma = skin @ np.array([0.299, 0.587, 0.114])
target_luma = float(target @ np.array([0.299, 0.587, 0.114]))
def relight(region, sigma, strength, lo, hi):
    weight = region * (luma > 0.40)
    low = gaussian_filter(luma * weight, sigma) / np.maximum(gaussian_filter(weight, sigma), 1e-4)
    gain = np.clip(target_luma / np.maximum(low, 0.05), lo, hi)
    return 1 + strength * (gain - 1) * region * (luma > 0.30)
# The face photo carries baked studio shading (dark sockets, nose shadow); the geometry now
# provides that, so most of the low-frequency light is taken out.  The painted neck shading
# of the base skin (muscle streaks, a darker band under the jaw) is relaxed as well.
delight = relight(mask, 45.0, 0.72, 0.8, 1.42) * relight(neck, 40.0, 0.6, 0.85, 1.25)
# Lift the photographed shadow under each eye (the orbit is now modelled in the geometry).
delight *= 1 + 0.32 * under_eye * np.clip((0.56 - luma) / 0.22, 0, 1)
result = skin * delight[:, :, None] * tone
# The v07 projection left a thin jagged seam where the photo's per-vertex UVs end (forehead,
# temples, jaw).  Keep the low frequencies there but drop the fine detail that draws the line.
seam = ((mask > 0.003) & (mask < 0.7)).astype(np.float64)
seam = np.clip(gaussian_filter(seam, 4.0) * 2.2, 0, 1)
low = np.stack([gaussian_filter(result[:, :, c], 5.0) for c in range(3)], axis=2)
result = low + (result - low) * (1 - seam)[:, :, None]
# Hair from the reference photo landed on the forehead corners; paint those dark texels with
# the surrounding skin.  Then soften the lower lids, where the projection left flat patches.
luma2 = result @ np.array([0.299, 0.587, 0.114])
skinw = ((luma2 > 0.47) & covered).astype(np.float64)
lowskin = np.stack([gaussian_filter(result[:, :, c] * skinw, 9.0) for c in range(3)], axis=2) / np.maximum(gaussian_filter(skinw, 9.0), 1e-4)[:, :, None]
dark = hairline * np.clip((0.5 - luma2) / 0.12, 0, 1)
dark = np.maximum(dark, np.clip(gaussian_filter(dark, 2.0) * 1.5, 0, 1) * hairline)
result = result * (1 - dark)[:, :, None] + lowskin * dark[:, :, None]
soft = np.stack([gaussian_filter(result[:, :, c], 2.5) for c in range(3)], axis=2)
result = result * (1 - 0.85 * under_eye)[:, :, None] + soft * (0.85 * under_eye)[:, :, None]
# Fill everything outside the UV islands with the nearest island colour so mipmaps never
# bleed black into the seams (that reads as dark lines down the neck and around the head).
_, (iy, ix) = distance_transform_edt(~covered, return_indices=True)
result = result[iy, ix]
# Slightly reduce the orange saturation left by the old tint so skin reads as one material.
mean = result.mean(axis=2, keepdims=True)
result = mean + (result - mean) * 0.96
result = np.clip(result, 0, 1)
Image.fromarray((result[::-1] * 255 + 0.5).astype(np.uint8), 'RGB').save(out)
print('TEXTURE written', out, 'photo texels', int((mask > 0.5).sum()), 'mean delight %.3f tone %s' % (delight[mask > 0.5].mean(), np.round(tone[(mask < 0.1) & covered].mean(axis=(0)), 3)))
