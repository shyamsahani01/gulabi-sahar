# Hero wardrobe — GTA-style outfits (app 0.9.3, 2026-11-06)

Reference: the user's two "GTA-style" character sheets (sunglasses, stubble, open leather
jacket over a white tee with a chain, hoodie with a chest mark, cargo trousers, tactical vest,
white sneakers). The request was "same character, main character ka".

What was built (`hero_wardrobe.gd`, `assets/shaders/garment.gdshader`, `stubble.gdshader`,
`sneaker.gdshader`): everything is procedural and attached to the existing v07 rig, so the
face, hair and body meshes are unchanged.

| Outfit | Pieces |
|---|---|
| 0 Street (default) | Open black leather jacket drawn over the tee mesh (chrome zip), white tee strip, long leather sleeves on the arm bones, chain with pendant, watch, dark denim, white sneakers, sunglasses, stubble |
| 1 Hoodie | Cream hoodie with kangaroo pocket, drawstrings, hood, GS★ chest mark, backwards cap, black cargo trousers with thigh pockets, black/white sneakers, sunglasses, stubble |
| 2 Tactical | Black tee, plate-carrier vest with pouches, grey cargo trousers, black boots, watch, sunglasses, stubble |
| 3 Classic | The previous off-white tee and charcoal jeans, no accessories |

Switch: FACE view → **OUTFIT >** button, or key **O**. The choice is saved in
`user://city_progress.json`.

Renders (`tests/hero_outfits.gd`): `<n>-<name>-front.png`, `-three-quarter.png`, `-full-body.png`.

Honest limits: the beard is a shader overlay (no hair geometry), the sleeves/vest/cap are
simple primitives, the hair is still the short swept style (the reference has longer wavy
hair), and the face likeness issue from earlier sessions is unchanged. The user has not
approved this look yet.
