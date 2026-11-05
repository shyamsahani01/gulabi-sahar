# Design review status

The user approved character concept **03C** as the visual target, then rejected the in-game likeness. Do not mark the 3D character complete. `01-character/shyam-concept-03c.png` remains the target.

The current v0.6 reference-fit face study and the Jaipur photo-reference lane are integrated into Android **test app v0.5.0**, installed at the user's explicit request. Installation is not visual approval. Real engine review images and street source URLs are under `02-jaipur-lane/`. Source photos stay local.

Review each part separately and use actual engine comparisons before describing an implementation as matching an approved image.

**2026-11-05 — world build (0.6.0).** The user asked for the whole corridor from Hawa Mahal to Vidhyadhar Nagar ("kuch area hi uthana", not every kilometre), hills beyond VDN, animals, children and adults, an in-game map, and a better character — and then said "code bhi kar do", so the world shipped without a per-zone approval round. Street View references for each zone are tracked in `02-jaipur-lane/references/sources.json` (Hawa Mahal Road 8 angles; Chandpole gate/bazar; a colony off Sikar Road for the VDN house style; VDN edge; VKI). Actual engine renders of 14 views are in `03-world/actual-3d-*.png` (captured by `tests/capture_views.gd`). **No zone is visually approved yet.** The character was not changed in this build (no Blender on this machine); it stays the top open art item.
