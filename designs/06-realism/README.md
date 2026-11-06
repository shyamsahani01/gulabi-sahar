# v0.9.1 actual engine review

All sixteen PNGs are actual Godot renders of the implemented game/character, not concept images. Generated with `tests/design_review_v09.gd` (nine city views) and `tests/hero_portraits.gd` (front, three-quarter, profile, full body, Smile, Serious, Surprised). Portraits use neutral stage lighting so skin/geometry can be inspected independently of the city.

The city keeps the compact map and six services from v0.9, adding native scooters/awning/utility detail, downloaded pavement maps and tiled, lit interiors. The hero uses the connected skinned body/head with the fitted facial detail baked into its UVs, revised hair, clothing and shoes. This is a review candidate: exact likeness is unresolved; forehead/temple transitions and painted eye/blink limitations remain visible. Passing tests does not approve these visuals.

Sources: [Jaipur Chameliwala Market reference](https://travjoy.com/jaipur/eat-shop-and-party/local-bazaars-and-flea-markets/chameliwala-market), [Pavement 05](https://polyhaven.com/a/pavement_05) by Jan Burghardt ([CC0](https://polyhaven.com/license)). Downloaded reference photograph is excluded from Git/APK; texture provenance is in `assets/textures/realism_sources.json`.
