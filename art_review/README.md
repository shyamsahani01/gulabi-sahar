# Native 3D review — likeness and Jaipur lane correction

The user rejected the installed v0.4 character likeness and requested more detail in the character and nearby environment, using real Jaipur lane photographs. The approved 03C design remains the target; a completed match is **not** claimed.

Run `./play.sh res://art_review/review.tscn` from the project root.

- F cycles close face, full body and lane views.
- E cycles the actual facial expressions.
- Drag with the left mouse button to orbit the 3D character.

This scene runs in the same Godot Compatibility renderer as the Android game. Screenshots in `designs/02-jaipur-lane/actual-3d-review-*.png` are real engine captures, not generated concept images. The latest Android test app v0.5.0 now contains this lane and the v0.6 face study, at the user's explicit installation request. This is test integration, not visual approval.

## Changes made for review

- Native review hero `shyam_hero_v06.glb`, preserving v0.4 and the intermediate v0.5 geometry study for comparison.
- Fuller lower face, shorter head/face proportions, reduced nose projection and more open eyelids.
- The v0.5 study tested separate eye spheres; they did not fit the reconstructed sockets and were removed in v0.6. The current review surface includes reference-registered eye detail.
- Fine hair fibers attached to the cap surface, lower/less regular frontal hairline, and relaxed T-shirt waist geometry.
- Woven fabric shader for T-shirt and trousers, with filtering to limit fine-pattern aliasing.
- An original 5.2 m market lane: close shopfronts, upper window recesses, jharokha details, stone paving and side drains, hanging textiles, counters and stock, chai tables, meters, pipes, cables and sagging overhead cloth.
- Eight reference-stage NPCs demonstrate the scale and ambient animations. They are not yet a full shopping simulation.

## Real references

Google image query was fetched locally: `Jaipur Maniharon ka Rasta gali`. Selected photographs were downloaded from their source hosts for local visual reference. See `designs/02-jaipur-lane/references/sources.json`.

- Maniharon ka Rasta: https://www.lifeberrys.com/articles/6/2016/20/holidays/hidden-treasures-of-jaipur-amer-nahargarh-and-jaigarh-fort.html
- Jaipur market arch photograph: https://unsplash.com/photos/people-walking-on-street-during-daytime-0Si7zZJ30gs
- Bazaar photograph: https://www.mycookinghut.com/foodtravel/jaipur-rajasthan

The photographs are not used as a flat game backdrop or bundled as game textures. Their observed features guide original native geometry. Source attribution is not a grant of a distribution license.

## Remaining visible differences

This candidate is still a simplified real-time model. The facial surface is fitted to 478 landmarks detected locally with MediaPipe, using inferred depth and the upstream canonical topology. This is an approximate single-view reconstruction, not a scan. A fitted cornea rig and more work on the face/skull transition remain pending. Hair silhouette, accurate facial anatomy, cloth drape, footwear, material wear, shop variation and baked indirect lighting need more art work to reach the approved photorealistic sheet. Do not label the candidate “exact likeness” or “photoreal complete.”

The previous workflow remains: show the actual visual result, receive the user's design feedback, then refine/implement the accepted result. The user requested installation of the current work; a final character/environment visual approval has not been recorded.

## Local asset tools

`tools/measure_reference_face.py` measures the approved reference with MediaPipe locally. `tools/fit_reference_face.py` builds the native reference-fitted mesh with Blender. Generated assets and editable Blender sources are committed; the downloaded model/runtime and original user FBX files live outside this repository. Required Python packages for the measurement step are listed in `tools/requirements-face-reference.txt`. Canonical topology source: https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/modules/face_geometry/data/canonical_face_model.obj (Apache 2.0; bundled license under `assets/characters/`).
