# Asset sources

The street geometry, UI and icon were created for this project. They are not scans or reproductions of a particular Jaipur building.

Surface photographs from Poly Haven, licensed CC0:

- Asphalt 02: https://polyhaven.com/a/asphalt_02
- Plastered Wall 02: https://polyhaven.com/a/plastered_wall_02
- License: https://polyhaven.com/license

The 1K diffuse, OpenGL normal and roughness JPEG maps were retrieved through https://api.polyhaven.com and verified against the API-provided MD5 checksums. Original filenames are mapped to `assets/textures/asphalt_*` and `assets/textures/plaster_*`.

- Red Plaster Weathered: https://polyhaven.com/a/red_plaster_weathered (Poly Haven CC0; 1K diffuse, normal and roughness maps verified against API MD5 values).

## World PBR pass (0.6.0, 2026-11-05)

Fourteen more Poly Haven CC0 texture sets (1K diffuse, OpenGL normal, roughness; MD5-verified through https://api.polyhaven.com) under `assets/textures/`, mapped in `world.gd` `make_materials()`; the exact files, URLs and checksums are in `assets/textures/polyhaven_sources.json`: sandstone_cracks (`sandstone_*`), red_brick_03 (`brick_*`), plastered_stone_wall (`plasterwall_*`), concrete_wall_006 (`concrete_*`), cobblestone_floor_08 (`cobble_*`), asphalt_04 (`asphalt2_*`), rocky_terrain_02 (`rock_*`), aerial_grass_rock (`scrubland_*`), grass_medium_01 (`grass_*`), wood_planks_grey (`wood_*`), metal_plate (`metal_*`), painted_plaster_wall (`paintedwall_*`), rough_plaster_brick_02 (`roughplaster_*`), worn_planks (`wornwood_*`). License: https://polyhaven.com/license (CC0).

## Street animals (0.6.0)

`assets/animals/*.glb` are converted from the **Farm Animals Pack by Quaternius** (CC0), downloaded from https://opengameart.org/content/lowpoly-animated-farm-animal-pack (`Farm Animals by @Quaternius.zip`, FBX with Idle/Walk/Run/Jump clips for cow, horse, zebra; Idle/Jump for pug, sheep, pig, llama). FBX → GLB conversion was done with Blender 4.2 (`export_scene.gltf`, animations kept). Quaternius: https://quaternius.com — CC0, attribution appreciated. Used in `animals.gd` for cows (`cow.glb`), dogs (`pug.glb`) and goats (`sheep.glb`); monkeys, pigeons, peacocks and the camel remain box-built.

## MakeHuman crowd (in progress)

`tools/build_crowd.py` generates crowd variants with the MPFB2 Blender extension (https://extensions.blender.org/add-ons/mpfb/, GPL code; generated meshes are the user's own) and the CC0 MakeHuman asset packs from http://files2.makehumancommunity.org/asset_packs/ (`makehuman_system_assets_cc0.zip`, `skins01_cc0.zip`, `eyebrows01_cc0.zip`, `hair01_cc0.zip`, `shirts01_cc0.zip`, `pants01_cc0.zip`, `shoes01_cc0.zip`, `dress01_cc0.zip`, `skirts01_cc0.zip`). The packs stay outside the repository; exported GLBs go to `assets/characters/crowd/`. Rig: MakeHuman "game_engine" skeleton, the same bone names as the existing crowd/hero rigs, so the Mixamo-derived Idle/Walk/Run clips apply unchanged.

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

## OpenStreetMap city data (0.8.0, 2026-11-05)

`assets/data/jaipur_city.json` is a derived database built by `tools/update_city_data.py` from OpenStreetMap: roads, 750 building footprints, parks and POI coordinates for Chandpole, Shastri Nagar, Vidhyadhar Nagar, Sikar Road and Nahargarh/Brahmpuri. Data © OpenStreetMap contributors, Open Database License (ODbL) 1.0 — https://www.openstreetmap.org/copyright. The license text pointer is bundled as `assets/data/OSM-LICENSE.txt` and the in-game atlas shows the attribution. Generated infill buildings, heights, terrain and one authored road (the Nahargarh game connector, `source: authored`) are the project's own additions and are tagged as such in every record; see README §v0.8.0. The raw OSM extracts are cached outside the repository (`/tmp/osm-*.json`).

## Synthesized sound effects (0.8.0)

`assets/audio/step.wav`, `impact.wav`, `dodge.wav` and `engine.wav` are generated procedurally by `tools/synthesize_audio.py` (filtered noise and sine tones, 22.05 kHz mono). No third-party samples are used.

## Authored action animations (0.8.0)

`action_animation.gd` builds the Jab, Cross, Kick, Dodge, Jump, Hit, Wave, Guard and Crouch clips at runtime from bone-rotation keyframes on the existing Mixamo-derived rig. They are original project data, not downloaded clips; locomotion (Idle/Walk/Run) remains the user's existing mocap assets listed above.


### v0.9.0 original city/vehicle geometry

`vehicle_design.gd` and `city_services.gd` author parametric geometry directly in Godot. No downloaded vehicle/building meshes or reference photographs are bundled by this revision. Reuses the project's existing fonts/materials and their licenses. Business names/positions are fictional authored game content. Original OSM JSON is unchanged; gameplay applies 0.88 horizontal compression on top of the source's 0.65 scale. See README v0.9.0 for reference links and limitations.


## v0.9.1 materials, street details and continuous hero

- **Pavement 05**, Jan Burghardt / Poly Haven, CC0: https://polyhaven.com/a/pavement_05 ; license https://polyhaven.com/license . Newly downloaded diffuse/OpenGL-normal/roughness JPEGs (1K), direct official download URLs and local SHA-256 hashes in `assets/textures/realism_sources.json`. This set was fetched from the official asset CDN; its hashes record local file integrity and are not claimed as API-verified upstream hashes.
- Chameliwala Market reference: https://travjoy.com/jaipur/eat-shop-and-party/local-bazaars-and-flea-markets/chameliwala-market . The downloaded photograph stays in ignored `builds/references/`; it is not a game texture. `scooter_design.gd`/`street_details.gd` are original native geometry, informed by street details rather than a literal reconstruction.
- `shyam_hero_v07.glb` and `shyam_continuous_skin.png` derive from the existing user/MakeHuman body, approved generated concept and earlier MediaPipe fit described above. No new person's face was downloaded. `tools/refine_hero_v07.py` transfers fitted detail to the connected head, bakes the texture, adds original hair locks/cloth shaping/shoes and preserves the rig/morphs. `tools/source/hero_continuous.blend` is the editable packed source. Godot-generated GLB texture extractions are committed alongside the GLB. Prior candidates are retained. Approximate likeness and visible close-up transitions remain; not a scan or complete eye rig.

### v0.9.4 structured hero face

- `shyam_hero_v08.glb`, `shyam_structured_skin.png` and `tools/source/hero_v08.blend` derive from `shyam_hero_v07.glb` only (same user/MakeHuman body, approved concept and earlier MediaPipe fit). No new person's face, photo or downloaded asset is involved. `tools/refine_hero_v08.py` (portable Blender 4.2 + numpy) applies authored anatomical displacement fields, rebuilds the Smile key, adds BrowRaise/BrowFurrow, repairs the eyelid UVs/normals and bakes per-vertex tone/mask images; `tools/hero_v08_texture.py` (system Python, scipy/PIL) de-lights the photo region, matches the body skin tone to it and fills the texture background. Godot-generated GLB texture extractions are committed alongside the GLB; v07 and earlier candidates are retained. Still an approximate likeness with painted eyes; not a scan or a complete eye rig.

### v0.9.5 real eyes and motion capture

- `shyam_hero_v09.glb`, `shyam_structured_skin_v09.png`, `tools/source/hero_v09.blend`: the v08 hero plus the character's own MakeHuman eyeballs (`Shyam.low-poly` mesh and `shyam_brown_eye.png` from the existing v0.4 export, CC0 MakeHuman assets), the original MakeHuman orbit geometry restored from `shyam_hero.glb`, and procedural eyelashes. No new downloaded asset.
- `hero_mocap.glb`: 22 clips derived from the **CMU Graphics Lab Motion Capture Database** (http://mocap.cs.cmu.edu), trials 02_04, 13_01, 13_04, 13_11, 13_17, 18_08, 19_08, 74_04, 77_04, 77_09, 90_18, 140_06, 141_14, 141_16, retargeted onto the project's own rig by `tools/cmu_retarget.py`. The database is free for any use, including commercial, with the acknowledgement: "The data used in this project was obtained from mocap.cs.cmu.edu. The database was created with funding from NSF EIA-0196217." Source ASF/AMC files stay in ignored `builds/cmu/`.

### v0.9.2 café / hospital architecture

- `assets/fonts/DejaVuSans-Bold.ttf`: DejaVu Sans Bold, copied from the system font
  package; redistribution terms in `assets/fonts/DejaVu-LICENSE.txt`.
- `assets/fonts/Z003-MediumItalic.otf`: URW Base35 Z003 script face; redistribution
  and font embedding terms in `assets/fonts/URW-LICENSE.txt`.
- `assets/textures/cafe_wood.gdshader`: authored warm-wood material using existing
  Poly Haven `wood_planks_grey` CC0 texture (see `polyhaven_sources.json`).
- Café geometry is authored from the user's three photographs. No reference photo
  is bundled. Hospital/clinic geometry is an authored building type.


## 2026-11-09 restaurant / palace architecture

`heritage_kit.gd`, `restaurant_architecture.gd`, `palace_architecture.gd` and
`neighborhood_architecture.gd` are original parametric Godot geometry. The shared
kit creates extruded cusped arches, lathed domes/columns, jali, windows, chhatris,
lanterns and date palms. Mineral/ground texture is generated from seeded Godot
FastNoiseLite; no external texture or mesh was added. Café chairs, tables, plants,
wood shader and bundled fonts reuse the already credited project assets.

External architecture photographs were viewed only as design references; none is
redistributed or used as an in-game texture. Source links and interpretation notes
are in [the architecture review](designs/13-architecture/README.md). Screenshots in
that directory are original renders of the project. Restaurant locations/names
retain the existing OSM data and attribution; the new facades/interiors and palace
courtyard are artistic designs, not surveyed replicas of those venues.


## 2026-11-10 compact district and vehicle assets

- `vehicle_design.gd`: original procedural sedan, taxi, police, SUV and medical-response meshes; no external car models, badges or trademarks. Shared by player/traffic and parked/showroom vehicles.
- `district_details.gd`, `neighborhood_architecture.gd`: original procedural VKI workshops, street furniture, VDN façades, park pavilion and map-limit signs. Uses existing licensed project materials/fonts.
- `assets/data/vki_vdn_city.json`: reproducible derivative of the existing `jaipur_city.json` OpenStreetMap extract (© OpenStreetMap contributors, ODbL 1.0). `tools/build_compact_city.py` clips geometry and adds explicitly tagged artistic infill and fictional dining locations. Original attribution/retrieval metadata is retained; no new survey is implied.
- `designs/14-compact-city/*.png`: actual Godot runtime renders generated by `tests/compact_capture.gd`, not concept-art composites. The user's supplied reference image guided palette and vehicle families; it is not substituted for game screenshots or embedded as game geometry.
