# Asset sources

The street geometry, UI and icon were created for this project. They are not scans or reproductions of a particular Jaipur building.

Surface photographs from Poly Haven, licensed CC0:

- Asphalt 02: https://polyhaven.com/a/asphalt_02
- Plastered Wall 02: https://polyhaven.com/a/plastered_wall_02
- License: https://polyhaven.com/license

The 1K diffuse, OpenGL normal and roughness JPEG maps were retrieved through https://api.polyhaven.com and verified against the API-provided MD5 checksums. Original filenames are mapped to `assets/textures/asphalt_*` and `assets/textures/plaster_*`.

- Red Plaster Weathered: https://polyhaven.com/a/red_plaster_weathered (Poly Haven CC0; 1K diffuse, normal and roughness maps verified against API MD5 values).

## Existing user character and animation assets

- Original character and original texture reference: `/home/shyam/MyWork/apps/jaipur-story-game/shyam_character.glb`. Its existing project notes identify it as an MPFB/MakeHuman character named Shyam.
- Animated FBX sources: `/home/shyam/Downloads/Idle.fbx`, `Walking.fbx`, `Running.fbx`. Their animation tracks are named `mixamo.com`. These are existing user assets, not newly downloaded CC0 assets.
- Exported only the animated rig and its bound meshes, excluding unrelated duplicate meshes present in the FBX. A decimated copy is used for the crowd.
- Original GLB skin, hair, eyebrows and eye images replace the FBX exports' blank color channels at runtime.
- Noto Sans Devanagari: copied from the system font installation; bundled license in `assets/fonts/NOTO-LICENSE.txt`.

## Approved hero adaptation (0.4)

- Concept 03C is a generated design approved by the user in this conversation. Supplied personal reference photographs are recorded in `CHAT_REQUIREMENTS_README.md` and are not bundled in the APK.
- `tools/build_hero.py` derives the existing user mesh/rig and imports expression-unit deltas from the locally installed MPFB package; source indices are preserved exactly, excluding MakeHuman helper vertices. MPFB/MakeHuman target data remain subject to their upstream asset license; no new third-party marketplace character is claimed.
- `tools/bake_hero_face.py` uses Blender's native projection and emission bake to adapt the approved portrait to the existing UVs, then adjusts cheeks/jaw and hair. `shyam_approved_skin.png` is a baked texture asset; `shyam_hero.glb` includes the facial morphs. This is a simplified 3D adaptation, not a photogrammetry scan or exact likeness.

## Reference-fitted facial study

The v0.6 review face is derived from the approved generated concept through locally detected MediaPipe landmarks and approximate inferred depth, combined with the existing user rig. Canonical face topology is from Google AI Edge MediaPipe: https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/modules/face_geometry/data/canonical_face_model.obj . Apache 2.0 license is bundled as `assets/characters/MEDIAPIPE-LICENSE.txt`. MediaPipe model/runtime downloads remain outside the project and are not game runtime dependencies.

Jaipur reference photographs were fetched for local visual research only; their source URLs are tracked in `designs/02-jaipur-lane/references/sources.json`, while downloaded third-party photos and Google search HTML are ignored by Git. Original native geometry is used in the lane study.
