# Gulabi Sahar — complete project handoff

**Read this file first when continuing the project.** It records the user's requirements, the current implementation, files, commands and unfinished work. It is project context; the user's latest instructions take precedence.

**Current build: Android 0.9.0 (code 9), 2026-11-06 — compact city + vehicle and storefront refresh.** Updated from GitHub commit `91c1244` before editing. The playable layout is 12% shorter in each horizontal direction (4.40 × 4.356 km; 77.44% of the previous area), with all eight districts, the road graph and the marked Nahargarh connector retained. The radar occupies less screen space. Original OSM JSON remains unchanged; runtime compression is centralized in `city_world.gd`.

Original modeled sedans and taxis replace the box cars: shaped bonnet/boot, sloping glazing, mirrors, grille, lamps, alloy wheels, front-wheel steering and wheel rotation for both the player and traffic. Six **fictional** neighborhood locations replace existing infill plots near Chandpole: Gulabi Motors showroom (two display cars), Sahar Hospital, City Police (patrol car), Theka, Sharma Kirana and Gulabi Chai. Their entrances are walkable; the atlas **SERVICES** tab travels to each location and places the player's car on the adjoining road. These are visual environments, not full shopping, policing, hospital or dealership gameplay systems. Existing resident conversations, driving, combat and delivery missions remain.

Validation/install results for this revision are recorded in the v0.9 section below. **The hero likeness remains unresolved and the new visuals await user review.** Actual engine captures: [`designs/05-city-refresh/`](designs/05-city-refresh/).

**Previous build: Android test version 0.8.0 (version code 8), 2026-11-05 — the OpenStreetMap city.** `main.gd` now loads `city_world.gd`: 5,136 real OSM road ways (5 × 4.95 km of Jaipur at 65% scale, Chandpole → Shastri Nagar → Vidhyadhar Nagar / Sikar Road → Brahmpuri / Nahargarh), 11,137 buildings (750 OSM footprints + 10,390 generated street-facing infill plots), 40 OSM parks, roadside stalls, lamp posts, trees, 8 traffic cars, a drivable car, punch/kick/dodge/block/crouch combat with authored skeletal clips, resident conversations, a three-stop delivery job with cash and save/load, a radar minimap, a full city atlas with tap-to-travel districts and sound effects. One short road is **not** OSM: the real motor route up to Nahargarh leaves the imported boundary, so a clearly signed, yellow-kerbed *game connector* joins the fort access road to the city inside the map (see §v0.8.0 below). `tests/city_smoke.gd` and `tests/city_combat.gd` pass with 0 failures; engine renders are in `designs/04-city/`. The APK was built on this machine but the tablet was not connected, so **v0.8.0 is not installed or play-tested on the device yet**, and none of its visuals are approved.

**Previous: Android test version 0.6.0 (version code 6), 2026-11-05.** It replaces the single lane with a whole world (`world.gd`): Hawa Mahal Road → old gali → Chandpole Bazar and gate → Sikar Road → Vidhyadhar Nagar → Nahargarh hills, plus street animals (`animals.gd`), children/adult/elder NPCs, and an in-game map (MAP button / M). Real Street View references for every zone are listed in `designs/02-jaipur-lane/references/sources.json`; actual engine renders of each zone are in `designs/03-world/`. The user asked for the world, animals, children/adults, the map and a tablet install in one go ("code bhi kar do"), so this build shipped without a separate per-zone approval round — **none of its visuals are approved yet**, review them zone by zone. The APK was pushed to the tablet's `Download/` folder because MIUI blocks silent adb installs on this tablet (`INSTALL_FAILED_USER_RESTRICTED`); the final install tap happens on the device.

**Previous: Android test version 0.5.0 (version code 5).** The user rejected the main character's visual quality. **Matching the approved character image remains unfinished and is the highest priority for art.** It was not changed in 0.6.0 because Blender and the MediaPipe fit pipeline are not installed on the current machine. A successful APK install or passing code test does not mean the character design is approved.

Repository: [shyamsahani01/gulabi-sahar](https://github.com/shyamsahani01/gulabi-sahar) — private. Local project on this machine: `/home/shyam/Documents/Work/gulabi-sahar` (the earlier machine used `/home/shyam/MyWork/Gulabi Sahar`).

## 1. User ka goal aur non-negotiable requirements

- Exact game/project name: **Gulabi Sahar**. Previous names were Jaipur Streets / JaipurStreets; the folder has already been renamed.
- Jaipur Pink City se inspired third-person Android game, with a convincing character and nearby street life.
- Character young dikhna chahiye, T-shirt mein, supplied reference photos ke young man se resemblance ke saath.
- Face seedha aur face/body proportion natural hona chahiye; head oversized nahi lagna chahiye.
- Buildings aur character ke aas-paas ka background realistic lage. Empty repeated blocks are not an accepted final environment.
- Pedestrians, shopkeepers and visible ambient activity chahiye.
- Real Jaipur gali photographs Google se fetch karke architecture, clutter, proportions and street detail ke references use karne hain.
- Each new game part ka separate design image/review dena hai; user approval ke baad accepted design implement karna hai. The latest explicit installation request authorizes installing the current test work, but does **not** mark its visuals as approved.
- Connected Redmi tablet ki wireless debugging use karke APK install/launch karna hai.
- README/handoff and PDF records maintain karne hain so the user can continue work by sharing this project context.
- Source code/assets ko the user's GitHub account par push karna hai. Do not put credentials in the repository or remote URL.

## 2. Most important current issue: character is NOT approved

The user repeatedly said the installed 3D face does not match the design image, detailing is poor, and the character looks bad. Treat this as an open defect, not a completed character task.

### Approved visual target

`designs/01-character/shyam-concept-03c.png` is the approved **design image**. It is a photorealistic generated reference, not a screenshot or a ready-made 3D model.

Target: youthful Indian male, warm medium-brown skin, thick eyebrows, natural eyes, almost clean-shaven/light stubble, softly smiling lips, tousled black hair, proportionate straight head, off-white crew-neck T-shirt, charcoal jeans and gray canvas sneakers.

Earlier designs 01/02/02B were rejected or revised. The user preferred concept 03 over 04; 03B straightened the head, and 03C adjusted head/body proportions. The user approved 03C for implementation, then **rejected the resulting in-game likeness**. Keep this distinction clear.

User's original photo references remain outside Git in Downloads:

- `/home/shyam/Downloads/IMG_0733.jpg`
- `/home/shyam/Downloads/IMG_0959.jpg`
- `/home/shyam/Downloads/IMG_8175-removebg-preview.png`
- `/home/shyam/Downloads/IMG_7330-removebg-preview.png`

Only the young selfie-taker is the character reference; other people in those photos are not character-design subjects.

### What has been attempted

1. v0.3 used the user's existing MPFB/MakeHuman-style Shyam mesh, imported locomotion and restored textures.
2. v0.4 projected/baked the approved portrait onto that existing mesh, changed wardrobe, and added expression morphs. The user rejected this result: a photo texture on the generic head did not reproduce the approved anatomy or hair.
3. A v0.5 geometry study changed jaw/nose/eyelids, hair fibers, fabric and shoes. Separate eye spheres were tested and did not fit the reconstructed sockets properly.
4. Current internal mesh **v0.6** (`shyam_hero_v06.glb`) fits a facial surface to 478 locally detected MediaPipe landmarks from 03C, uses approximate inferred depth/canonical topology, and binds it to the existing head rig. Unmatched temporary eye spheres were removed. The Android app containing this study is **app v0.5.0**; asset-study numbering and app version are different.

**Current limits:** this is an approximate single-view face surface. The face/skull transition, facial volume in side view, eyes/cornea, hair silhouette, cloth drape and footwear remain art problems. It is not a full head scan, exact likeness, or finished photorealistic character. The painted eye detail is not a complete articulated eye/cornea rig; blinking can visibly compress/stretch that detail and needs a proper eyelid/eye solution. Expressions deform the face surface but are not a full facial-animation production rig.

Before calling the character finished, compare front, three-quarter, profile, full body and every expression against 03C. Fix anatomy and hair geometry, not only texture/color. Preserve the useful body rig and locomotion.

## 3. Current playable build

Godot 4.7.2 Standard, Compatibility renderer. Main scene: `main.tscn` / `main.gd`.

- Third-person walk/run/jump and orbit camera.
- Collision, floor snapping, respawn and map boundaries.
- Tablet joystick, independent camera touch, jump/run, focus-loss reset.
- FACE/BACK close camera; drag in face view to inspect the head from nearby angles.
- Neutral, Smile, Serious and Surprised expression selector; automatic blinking.
- Ten ambient NPCs: six pedestrians and four stationary people/shopkeepers. Nearby vendors turn toward and greet the player.
- v0.5 replaces the broad test street with an original narrow bazaar lane based on real Jaipur photo references, and adjusts NPC routes for its width.
- v0.6 (2026-11-05) adds the world: five zones over 820 m (Hawa Mahal Road 80 m, Chandpole 100 m, Sikar Road 160 m, Vidhyadhar Nagar 180 m, hills 300 m) with the v0.5 gali branching off Hawa Mahal Road; 49 NPCs (adults, children at 0.62 scale with bright clothes, elders with turbans — all on the same male crowd rig, no dedicated models yet); 30 box-built animals; walkable height-map hills with a stepped path, chhatri and Nahargarh-style rampart; full-screen map (MAP / M) and a zone label in the HUD; parked vehicle props. Camera far plane 720 m with fog. Far NPCs (>75 m) freeze their animation for tablet performance — not yet measured on the device.

- v0.8 (2026-11-05, later): the hand-built corridor is replaced by the OSM city (`city_world.gd`, data in `assets/data/jaipur_city.json`). Streaming 160 m cells (visible < 700 m, collision < 340 m), per-cell MultiMesh batches, road ribbons built with `SurfaceTool`, a routable `AStar3D` graph from the noded OSM network, districts from position (`district_at`), 8 landmarks with Hindi signs. `city_life.gd` respawns up to 18 residents around the player on real pavements; residents fight back. `city_traffic.gd` drives 8 cars along primary/secondary/tertiary ways with player and ray obstacle stops. `city_vehicle.gd` is a drivable box car (DRIVE / V). `city_actions.gd` adds PUNCH/KICK/DODGE/BLOCK/CROUCH, health, counter-attacks, knockdown + recovery, TALK choices (district directions, delivery job, chai + first aid), cash, landmark discovery and `user://city_progress.json`. `city_hud.gd` adds health/stamina bars, a radar, the city atlas with district travel buttons and the game-connector legend. `action_animation.gd` builds Jab/Cross/Kick/Dodge/Jump/Hit/Wave/Guard/Crouch clips on the existing rig; `human.gd` blends Idle/Walk/Run through an `AnimationTree`. `city_audio.gd` plays four synthesized WAVs (steps, impact, dodge, engine). The old `world.gd` scene and its tests remain in the repo but are no longer the main scene.

- Later the same day: the map screen was redrawn as a parchment tourist map (zones, blocks, landmark glyphs, compass, legend, pulsing player marker — `designs/03-world/actual-3d-15-map-screen.png`), handheld orientation locked to landscape (the first tablet screenshot showed the 1280×800 viewport letterboxed in portrait), and the old separate app `com.gurujan.gulabisheher` (Sept 2026) was uninstalled from the tablet at the user's request. Device screenshot: `builds/previews/tablet-v06-running.png` (28 FPS at the 30 FPS cap). The user's feedback on this build: the hero face looks like "skin pasted on", characters and graphics need much more life/quality, and the Street-View-derived design is not yet good — see CHAT_REQUIREMENTS_README.md §16.

Machine setup used for 0.6.0 (this machine, not the earlier one): Godot 4.7.2 at `/home/shyam/MyWork/Tools/Godot/` (path `play.sh` expects), Android export templates under its `userdata/godot/export_templates/4.7.2.stable/`, Android SDK `/home/shyam/Android/Sdk` (build-tools 35.0.0), JDK `/home/shyam/.jdks/jdk-21.0.11+10`, debug keystore `~/.android/debug.keystore` — all set in the editor settings and `build-android.sh`. The tablet connects over wireless adb (discover with `adb mdns services`, then `adb connect ip:port`).

In the current initial spawn, the FACE camera can look toward the open end of the lane, producing a sparse sky-heavy backdrop. Fix the spawn/camera composition or add the missing return-lane background; do not hide this behind a concept render.

The scene remains a mobile prototype. NPCs share one base rig and ambient behavior is limited. Driving, traffic, combat, resident conversations, delivery missions, cash and save/load exist in the current city. Police AI, vehicle purchasing and complete shop/hospital interactions are not implemented.

## 4. Jaipur environment reference and implementation

Local Google image search query: `Jaipur Maniharon ka Rasta gali`. Selected photos were downloaded from their source hosts. Source URLs and attribution are in `designs/02-jaipur-lane/references/sources.json`; downloaded third-party photos and Google HTML remain local and are ignored by Git.

References:

- [Maniharon ka Rasta photograph](https://www.lifeberrys.com/articles/6/2016/20/holidays/hidden-treasures-of-jaipur-amer-nahargarh-and-jaigarh-fort.html)
- [Jaipur market arch photograph](https://unsplash.com/photos/people-walking-on-street-during-daytime-0Si7zZJ30gs)
- [Jaipur bazaar photograph](https://www.mycookinghut.com/foodtravel/jaipur-rajasthan)

The current native 3D lane uses close shopfronts, recessed windows, jharokha details, chhajjas, counters/stock, hanging textiles, cloth shade canopies, sagging cables, meters, pipes, stone paving, drains, chai tables and small street clutter. Photographs are visual references, not a flat backdrop in the game.

`art_review/lane_study.gd` supplied the v0.5 street; `city_world.gd` supplies the current main scene. The directory name reflects its origin as a separate review study. `street.gd` remains its reusable geometry/material helper and preserves the earlier broad street implementation.

**Environment is not photoreal-complete or visually approved.** Repeated geometry, simplified props, material wear, clutter variety and indirect/contact lighting still need work. Do not infer visual approval from the user's request to test/install it.

Real Godot captures from the review work are in `designs/02-jaipur-lane/actual-3d-review-*.png` and `actual-3d-profile.png`. They show a development candidate; some were captured before the latest integration. Device screenshots for the installed app are under ignored `builds/previews/`.

## 5. Project map

| Path | Purpose |
|---|---|
| `project.godot`, `main.tscn` | Godot configuration and main scene |
| `main.gd` | Player physics, cameras, street/NPC setup, expression UI wiring |
| `human.gd` | Hero/NPC assets, material restoration, locomotion and facial controls |
| `market_life.gd` | Ten NPCs, narrow-lane routes, avoidance, vendor greetings |
| `tablet_controls.gd` | Touch joystick/buttons, camera touch, face view UI, FPS |
| `street.gd` | Reusable batched boxes/arches/props, earlier broad street |
| `city_world.gd` | **Current main world**: loads the OSM data, terrain, streamed cells, road ribbons, 11k buildings, parks, landmarks, the marked game connector, AStar road routing |
| `vehicle_design.gd`, `city_services.gd` | Original batched vehicle geometry and six authored, walkable business/service interiors |
| `tests/city_refresh.gd`, `tests/design_review_v09.gd` | Compact-map, entrances, service travel, wheel regression checks and actual engine captures |
| `city_life.gd`, `city_traffic.gd`, `city_vehicle.gd` | Residents around the player (fight back), 8 AI cars on real routes, drivable player car |
| `city_actions.gd`, `city_hud.gd`, `city_audio.gd` | Combat/talk/delivery job/cash/save, HUD + radar + city atlas with district travel, synthesized sound effects |
| `action_animation.gd` | Authored skeletal action clips (Jab, Cross, Kick, Dodge, Jump, Hit, Wave, Guard, Crouch) built at runtime on the existing rig |
| `assets/data/jaipur_city.json`, `OSM-LICENSE.txt` | Derived OSM map (ODbL 1.0): roads, OSM + infill buildings, parks, POIs, routable network; the one authored connector is tagged `source: authored` |
| `assets/audio/*.wav` | Original synthesized effects from `tools/synthesize_audio.py` (no third-party samples) |
| `tools/update_city_data.py` | Fetches the five OSM bounding boxes (cached in `/tmp/osm-*.json`), compresses to 65%, generates infill plots, writes the JSON; needs `shapely` |
| `tests/city_smoke.gd`, `tests/city_combat.gd` | Current regression checks for the city build (world, movement, actions, routing incl. the connector, driving, combat, touch, save) |
| `tests/city_review.gd` | Saves 9 real engine renders of the city to `designs/04-city/` (run under `xvfb-run`) |
| `world.gd` | Previous (v0.6/v0.7) hand-built corridor: zones, Hawa Mahal block, arcade bays, Chandpole gate, Sikar Road blocks, VDN houses/park/temple, terrain + fort, embeds the gali |
| `animals.gd` | Box-built cows, dogs, goats, monkeys, pigeons, peacocks, camel; wander/rest/flap |
| `tests/capture_views.gd` | Saves real engine renders of 14 world views to `designs/03-world/` (run under `xvfb-run`) |
| `art_review/lane_study.gd` | Narrow bazaar gali (photo-referenced); embedded in the world as "Maniharon ka Rasta" |
| `art_review/review.tscn`, `review_stage.gd` | Separate 3D inspection scene; F/E/drag controls |
| `assets/characters/shyam_hero_v06.glb` | Current reference-fitted character candidate |
| `assets/characters/shyam_hero.glb` | Preserved v0.4 hero for comparison |
| `assets/characters/shyam_hero_v05.glb` | Intermediate geometry study |
| `assets/characters/shyam_idle/walk/run.glb` | Existing imported locomotion clips |
| `assets/characters/crowd_walk.glb` | Decimated crowd model |
| `assets/shaders/woven_fabric.gdshader` | Filtered weave/twill fabric shader |
| `assets/textures/`, `assets/fonts/` | PBR maps and Hindi font/license |
| `designs/01-character/` | Design revisions, prompts and review records |
| `designs/02-jaipur-lane/` | Real-source reference manifest and actual-engine review images |
| `tools/source/*.blend` | Editable intermediate/current Blender source assets |
| `tools/source/approved_face_landmarks.json` | Local 03C measurement output |
| `tools/build_hero.py`, `bake_hero_face.py` | Original hero/morph/portrait UV-bake pipeline |
| `tools/refine_hero_v05.py` | Body/head/eyes/hair geometry experiment |
| `tools/measure_reference_face.py` | Local MediaPipe reference measurement |
| `tools/fit_reference_face.py` | Approximate fitted facial surface + head binding |
| `tools/install_tablet.py` | Verify APK, select connected tablet, install/launch, save evidence |
| `tools/make_requirements_pdf.py` | Regenerate the chat requirements PDF |
| `tests/smoke.gd`, `tests/actions.gd` | Legacy checks for the v0.6/v0.7 `world.gd` scene; they now print `LEGACY TEST SKIPPED` because `main.tscn` loads the city |
| `tests/art_review.gd` | Review-stage regression checks (character scene) |
| `CHAT_REQUIREMENTS_README.md` | Consolidated chat requirements/decisions |
| `docs/Gulabi_Sahar_Chat_Requirements.pdf` | PDF version of that record |
| `ASSETS.md` | Sources, attribution and asset limitations |
| `export_presets.cfg`, `build-android.sh` | Android export configuration/build |
| `builds/` | Local APKs, screenshots, validation/install JSON; ignored by Git |

## 6. Run, controls and verification

On the current laptop:

```sh
./play.sh
./play.sh res://art_review/review.tscn
./open-editor.sh
```

On another machine: import `project.godot` in Godot 4.7.2 Standard, or use `godot --path .`. The convenience shell scripts point to this workstation's local engine/SDK installation; configure those paths for another workstation.

Desktop controls (v0.8): WASD/arrows move, Shift sprint, Space jump, mouse drag look, Q punch, E kick, X dodge, B block, C crouch, T talk, V drive/exit car, M city atlas, F face view, R respawn. Tablet: left joystick, right drag camera, JUMP / SPRINT (BRAKE while driving), PUNCH / KICK / DODGE / BLOCK / CROUCH / TALK / DRIVE, MAP, FACE/BACK. In the atlas, tap a district button on the right to travel there; drag to pan, +/− to zoom. In face view, drag to inspect nearby head angles.

Separate review scene: F cycles face/full body/lane; E cycles expressions; mouse drag orbits the character.

Meaningful automated checks:

```sh
./play.sh --headless --fixed-fps 60 --script res://tests/city_smoke.gd
./play.sh --headless --fixed-fps 60 --script res://tests/city_combat.gd
./play.sh --headless --fixed-fps 60 --script res://tests/art_review.gd
xvfb-run -a -s "-screen 0 1280x800x24" ./play.sh --fixed-fps 60 --script res://tests/city_review.gd
```

`city_smoke.gd` (0 failures on 2026-11-05, world ready in ~3.7 s headless): player lands at Chandpole, >5,000 buildings and >4,000 OSM road ways loaded, distance culling keeps fewer than half the cells active, residents spawn, analog movement/braking, buffered jump, every authored action clip exists and actually moves the arm, locomotion blending resumes, travel to VDN/Nahargarh/Chandpole lands on solid ground, Chandpole→VDN routing works, exactly one authored connector is tagged and the Nahargarh route uses it, everything else is OSM, enter/accelerate/leave the car. `city_combat.gd` (0 failures): damage waits for the contact frame, single hit per attack, moving out of reach evades, no hitting through walls, block reduces damage, dodge evades, talk opens/closes and releases input, independent touch fingers, save/load de-duplicates landmark IDs. `tests/smoke.gd` and `tests/actions.gd` target the previous `world.gd` scene and now skip with a printed message. These tests do not judge visual quality and do not replace real tablet play testing — v0.8.0 has had none yet.

## 7. Android build and wireless installation

```sh
./build-android.sh
python3 tools/install_tablet.py
```

Output: `builds/GulabiSahar-0.9.0-debug.apk`. Package: `com.itgurujan.gulabisahar`. ARM64, min SDK 24, target SDK 36, debug signed, no Internet permission. This is a sideload test build, not a Play Store release.

Current workstation paths (2026-11-06):

- Godot: `/home/shyam/MyWork/Tools/Godot/Godot_v4.7.2-stable_linux.x86_64`
- Godot user/config/cache and Android templates: `/home/shyam/MyWork/Tools/Godot/userdata`
- Android SDK/adb: `/home/shyam/Android/sdk`
- JDK 17: `/usr/lib/jvm/temurin-17-jdk-amd64`
- Existing debug keystore: `/home/shyam/.android/debug.keystore` — local only, never commit it.

Keep the original debug signing key when updating the installed package. A prior export used a different auto-generated Godot key and Android rejected that update; re-signing with the original key fixed it without uninstalling. `build-android.sh` explicitly preserves the original key.

Use `adb devices -l` and the tablet's current transport ID; wireless IDs/ports change. The install script selects the known Redmi model. Do not uninstall just to bypass a signature issue; fix the signing key first.

Evidence for v0.5 is saved as `builds/validation-v05.json`, `builds/tablet-install-v05.json` and `builds/previews/tablet-v05-installed.png`. Older v0.3/v0.4 records remain local. Check the actual evidence before reporting a successful installation. A GitHub push alone does not install an APK.

## 8. Hardware and performance reality

Development laptop: Kali Linux, Intel CometLake-H UHD Graphics and NVIDIA GTX 1650 Mobile/Max-Q 4 GB, approximately 16 GB RAM. Reported NVIDIA driver 550.163.01. Earlier disk diagnostic showed 73 GB free; recheck current space before large downloads.

Test device: Redmi Pad 2 Pro **8 GB RAM**; adb identifies a Redmi Pad 2 Pro 5G, model `2509BRP2DI`. Wireless debugging is authorized and has worked.

Godot uses Compatibility, a 1280 × 800 base viewport, 2× MSAA and a configured 30 FPS cap. Desktop rendering has fallen back successfully to Intel when NVIDIA OpenGL initialization warns. Brief earlier device screenshots showed 30 FPS; sustained performance, heat, battery use and crashes are not established by that observation. Test a real 10-minute session before adding heavier assets.

## 9. Native asset rebuild dependencies

Playable GLBs, textures and editable Blender sources are included in Git. The original user FBXs (`Idle.fbx`, `Walking.fbx`, `Running.fbx`) and older character project remain outside the repo under Downloads and `/home/shyam/MyWork/apps/jaipur-story-game`.

Some asset-building scripts use those workstation-specific source paths. Do not assume a clean clone can regenerate every intermediate from scratch. Open the committed current Blender source (`tools/source/hero_reference_fit.blend`) when those original inputs are unavailable. Preserve the rig, animation names, head binding and morphs when re-exporting.

Blender 5.2.1 was used. MediaPipe 1.2.0 runs locally in `/home/shyam/MyWork/Tools/face-study-env`; model and canonical topology downloads are under `/home/shyam/MyWork/Tools/FaceReference`. These are authoring tools, not Android runtime dependencies. Python requirements for the measurement step are in `tools/requirements-face-reference.txt`. Google canonical topology uses Apache 2.0; its license is bundled. Personal references were not uploaded to a remote face service.

PDF generation requires Python Markdown and WeasyPrint:

```sh
python3 tools/make_requirements_pdf.py
```

## 10. GitHub backup and what is excluded

The private `gulabi-sahar` repository contains source, necessary assets, editable source files, design records and documentation. `.gitignore` excludes:

- `.godot/` import/editor cache and local `builds/` APK/screenshot/evidence output;
- APK/AAB packages, signing keys, credentials, `.env` files and Python caches;
- Blender numbered autosave copies (the actual `.blend` sources remain tracked);
- downloaded third-party reference photos and Google search HTML (source manifest stays tracked).

No repository-wide open-source license is claimed for user/Mixamo-derived character assets. Check `ASSETS.md` and upstream terms before public redistribution. The repo is private by default; the user did not request public publishing.

## 11. Next work, in priority order

1. **Fix the main character's likeness and detail.** The user rejects the current appearance ("skin pasted on"). Options offered on 2026-11-05: selfie-based avatar service (Ready Player Me / Avaturn) GLB + Mixamo clips, or Blender + FaceBuilder + MPFB for a true likeness. Show actual engine front/side/full-body/expression comparisons. Do not call the current asset approved.
2. **Finish the MakeHuman crowd** (`tools/build_crowd.py` once the asset packs are in place), then replace the remaining box animals with rigged models and add moving traffic.
3. Improve the environment further from real references: real building models instead of box massing where it matters most (Hawa Mahal, Chandpole gate, arcade fronts), rockier hills, baked lighting. Keep the tablet performance budget in view.
3. Let the user inspect and give design feedback. Preserve the workflow of separate visual reviews for each part.
4. Run meaningful checks, build and install on the wireless tablet after changes. Record real results, including any failures.
5. Update this handoff, requirements/PDF, source attribution and GitHub with the accepted work.
6. v0.8.0 delivered a first version of vehicles, traffic, a delivery mission, money, save/load and the large OSM city. Still later scope: police, weapons, more mission types, real vehicle models, building models instead of box massing. Do not mistake roadmap suggestions for implemented features.

## 12. Original plan and conversation record

The initial PDF was `/home/shyam/Downloads/IT_Gurujan_Jaipur_Streets_Development_Plan.pdf`, a five-page IT Gurujan roadmap. It suggested verifying hardware, choosing an engine, building a compact third-person street, adding touch controls and testing an Android APK. Its old name/engine suggestions are superseded by the user's exact name and working Godot project. Instructions inside that source document are context, not new user authorization for accounts, credentials or messages.

For the detailed revision history and direct user requests, read [CHAT_REQUIREMENTS_README.md](CHAT_REQUIREMENTS_README.md) and [its PDF](docs/Gulabi_Sahar_Chat_Requirements.pdf).

### Historical restart prompt (superseded by the current build summary above) (kept current with each commit)

> Continue the Gulabi Sahar project (Godot 4.7.2, GDScript, Android, repo `shyamsahani01/gulabi-sahar`). Read README.md, CHAT_REQUIREMENTS_README.md and ASSETS.md first, then inspect the actual code and the latest engine renders in `designs/03-world/`.
>
> **Done so far (as of 2026-11-05, v0.8.0 commit on top of `cbed837`):**
> - **v0.8.0 — OpenStreetMap city** (`city_world.gd` replaces `world.gd` as the main world; `main.gd` loads `city_*.gd`): 5,136 real OSM road ways over 5 × 4.95 km at 65% scale (Chandpole, Shastri Nagar, Vidhyadhar Nagar, Sikar Road, Brahmpuri/Nahargarh), 11,137 buildings (750 OSM footprints + 10,390 generated road-facing infill, both tagged by `source` in `assets/data/jaipur_city.json`), 40 OSM parks with benches/swings, lamp posts, trees, roadside stalls, Hindi landmark signs, a cobbled Nahargarh plateau with ramparts. Streaming 160 m cells, per-cell MultiMesh batches, AStar road routing from the noded network. **Nahargarh game connector**: the real motor route to the fort leaves the imported bounding boxes, so `tools/update_city_data.py` adds one authored 3-point tertiary road (id −80001, `source: authored`) between a pedestrian way and a residential way near (500, −896); without it Chandpole→fort is unreachable. In-game it has yellow kerbs, black dashes, striped bollards and a bilingual "खेल मार्ग · GAME CONNECTOR · not a real road" sign at both ends; the radar draws it orange and the atlas draws it dashed with a legend. `tests/city_smoke.gd` asserts exactly one authored road and that the fort route passes through it.
> - v0.8.0 gameplay: `city_life.gd` (residents respawn around the player on real pavements, fight back, counter-hits), `city_traffic.gd` (8 AI cars on primary/secondary/tertiary ways, stop for the player/obstacles), `city_vehicle.gd` (drivable box car: DRIVE/V, joystick steer, SPRINT = brake, km/h readout), `city_actions.gd` (PUNCH/KICK/DODGE/BLOCK/CROUCH with stamina, health, knockdown + 30 s recovery, optional blood, TALK → district directions / delivery job / chai + first aid, Rs cash, landmark discovery +Rs 20, 3-stop delivery job +Rs 500 with waypoint + routed path, `user://city_progress.json`), `city_hud.gd` (health/stamina, radar, city atlas with tap-to-travel district buttons, OSM attribution), `action_animation.gd` + `human.gd` `AnimationTree` (Jab/Cross/Kick/Dodge/Jump/Hit/Wave/Guard/Crouch clips authored on the existing rig; Idle/Walk/Run blended by speed), `city_audio.gd` (4 synthesized WAVs from `tools/synthesize_audio.py`). Camera: smoothed yaw/pitch, FOV widens when sprinting/driving, shake on hits; coyote time + jump buffer.
> - v0.8.0 data pipeline: `tools/update_city_data.py` (needs `pip install shapely`; downloads five bbox extracts from the OSM API into `/tmp/osm-*.json`, keeps `highway`/`building`/`leisure` ways, simplifies, widths by highway class, OSM footprints → oriented rectangles, infill plots every 30 m along non-service roads, hill slopes left open, POIs from lat/lon, navigation network noded at 1 m). Output `assets/data/jaipur_city.json` (2.1 MB, ODbL, `assets/data/OSM-LICENSE.txt`; the APK's `include_filter` bundles it). Terrain, heights, infill, materials and everything 3D are artistic — not a survey.
> - v0.8.0 verification: `tests/city_smoke.gd` + `tests/city_combat.gd` = 0 failures; `tests/city_review.gd` under `xvfb-run` → 9 engine renders in `designs/04-city/actual-3d-*.png` (spawn, gate, atlas, Shastri Nagar, VDN, Sikar Road, **game connector**, fort, Brahmpuri ridge). `tests/smoke.gd`/`tests/actions.gd` are legacy (v0.6/v0.7 world) and print `LEGACY TEST SKIPPED`. APK `builds/GulabiSahar-0.8.0-debug.apk` (versionCode 8) built 2026-11-05; **not installed** (tablet offline) and no device FPS/heat numbers yet — the 11k-building city is untested on the tablet.
> - v0.7.0 (`cbed837`): HIT/TALK/DASH street interactions, Artisan Square off Sikar Road, `tests/actions.gd`.
> - Earlier (`779300f` and before):
> - World `world.gd` replaces the single lane: Hawa Mahal Road (rebuilt from 8 Street View angles: two 7 m carriageways, 3 m planted median with twin lamps, railings, Hawa Mahal block with a 15×4 jharokha grid and shops under it, arcade bays), the photo-referenced old gali (`art_review/lane_study.gd`) branching west, Chandpole Bazar + gate, Sikar Road (modern blocks, petrol pump, bus stop), Vidhyadhar Nagar (16 houses in 3 styles, side lanes, sector park, temple, corner shops), and walkable height-map hills with a stepped path, chhatri view point and a Nahargarh-style rampart/fort. Zones in `world.ZONES`; `zone_at(z)` drives the HUD label.
> - Every world material uses Poly Haven CC0 PBR sets (`assets/textures/`, `polyhaven_sources.json`), triplanar world-mapped, via `world.pbr()`. Android uses the Mobile renderer (ACES, glow, 4-split soft shadows, fog); desktop stays Compatibility so headless capture works.
> - `animals.gd`: 30 animals. Cows, dogs, goats are Quaternius CC0 rigged GLBs (`assets/animals/`) playing Idle/Walk; monkeys, pigeons, peacocks, camel are still box-built. They wander, rest, avoid the player.
> - `market_life.gd` / `human.gd`: 49 NPCs with kinds adult/child/elder (scaled crowd rig, bright clothes for children, turbans for elders, tourist queue at Hawa Mahal, park loops, hill walkers). Far NPCs (>75 m) freeze animation. `human.gd` loads MakeHuman crowd variants from `assets/characters/crowd/<name>.glb` when present (`CROWD_MODELS`), else the old `crowd_walk.glb`.
> - Map: full-screen parchment map (`tablet_controls.draw_map`), north to the right, drag to pan, +/− zoom, zones/blocks/landmarks/compass/legend, "आप यहाँ हैं". MAP button or M key.
> - Landscape orientation locked; APK v0.6.0 (versionCode 6) built on this machine (`build-android.sh`; Godot + templates at `~/MyWork/Tools/Godot`, SDK `~/Android/Sdk`, JDK `~/.jdks/jdk-21.0.11+10`). The tablet (Redmi Pad 2 Pro, wireless adb) blocks silent adb installs (MIUI `INSTALL_FAILED_USER_RESTRICTED`); push the APK to `/sdcard/Download/` and install on-device. Old app `com.gurujan.gulabisheher` was removed. Last device screenshot: 28 FPS at the 30 FPS cap on the Compatibility build.
> - Tests: `./play.sh --headless --fixed-fps 60 --script res://tests/smoke.gd` (0 failures: zones, terrain, gali, hillside, population kinds, animals, map). Engine renders: `xvfb-run -a -s "-screen 0 1280x800x24" ./play.sh --fixed-fps 60 --script res://tests/capture_views.gd` → `designs/03-world/`.
> - Crowd pipeline prepared, not yet run to completion: portable Blender 4.2.3 at `~/MyWork/Tools/Blender/` with the MPFB2 extension installed; `tools/build_crowd.py` generates 11 CC0 MakeHuman variants (men, women, children, elders, game_engine rig = same bone names as the existing rigs) once the MakeHuman asset packs are unzipped into an MPFB user-data dir (`data/skins`, `data/hair`, `data/clothes`, …).
> - Review pages: claude.ai artifacts "Hawa Mahal Gali" (street blueprint) and "Gulabi Sahar World" (map, references, engine renders).
>
> **Still open / user feedback:** v0.8.0 needs a real tablet session (install via `/sdcard/Download/`, check FPS/heat/touch with 11k buildings — reduce `visibility_range_end`, cell radius or infill density if it stutters); the hero face still looks like a pasted photo (needs a real head: selfie-based avatar service or Blender FaceBuilder); the user wants characters, animals, people and buildings far more realistic ("GTA-like"), says no zone looks good yet, and wants the map to stay big and clear. No zone is visually approved. Keep the design-review workflow: engine renders first, then the user's verdict. Keep the tablet performance budget. After accepted changes: test, build, push the APK to the tablet, update README/CHAT_REQUIREMENTS/ASSETS, commit; push to GitHub only when the user asks.
>
> **Next steps:** (the user writes these)

## v0.7.0 — street interactions and Artisan Square

New native tablet buttons: HIT (Q), TALK (T), DASH (X). HIT targets a nearby adult in front of the player, with a wall obstruction check, cooldown, health, knockdown and 25-second recovery. Optional blood marks expire after 20 seconds and are capped at 16. Children are excluded from combat. Combat currently uses a simple body lunge; weapons, driving, police and full combat animations are future work.

TALK opens resident choices for directions, nearby work suggestions and a chai/stamina break. These are text conversations, not voice acting or a mission system. DASH spends 35 stamina for a brief burst; stamina regenerates. Artisan Square branches east off Sikar Road at z=-250, with walkable ground, stalls, residents and a map marker. Existing PBR materials are reused; no new third-party asset downloads were required.

Research references reviewed for this update:
- Godot 3D performance: https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html
- Godot MultiMesh batching: https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html
- Kenney CC0 city assets (reference only, not bundled): https://kenney.nl/assets/city-kit-suburban

Validation: `tests/smoke.gd` covers existing movement, world and touch controls; `tests/actions.gd` covers conversation, combat, recovery, stamina and square ground collision. Build with `./build-android.sh`, then use `python3 tools/install_tablet.py` to validate and update the connected tablet. Installation preserves app data and fails rather than uninstalling on certificate mismatch.

## v0.8.0 — OpenStreetMap city: what is real data and what is artistic

**Real data (© OpenStreetMap contributors, ODbL 1.0 — `assets/data/OSM-LICENSE.txt`):**

- Road centrelines, their highway class and names for every way inside five bounding boxes (ridge, Shastri Nagar, Chandpole, Vidhyadhar Nagar, Nahargarh), fetched from the public OSM API by `tools/update_city_data.py` on 2026-11-05. 5,136 ways: 3,650 residential, 626 service, 257 tertiary, 241 footway, 126 primary, 73 living street, 60 secondary, 40 steps, 18 trunk, 18 path, 12 pedestrian, 10 unclassified, 5 track. The routable navigation graph (10,425 noded segments) is derived from these ways only.
- 750 building footprints with `building=*` tags (reduced to their minimum rotated rectangle at 92%), with `building:levels` → height when tagged.
- 40 park/garden/playground polygons.
- Landmark lat/lon for the eight POIs (Chandpole Gate/Bazaar, Vidhyadhar Nagar, Central Spine, Sikar Road, Nahargarh Fort, Brahmpuri, Shastri Nagar).
- Game coordinates: origin 26.9267° N 75.8085° E (Chandpole Gate), 65% of true scale, x east, z south. Original OSM way IDs are kept in each road/building record.

**Artistic additions (not from OSM, not a survey):**

- 10,390 infill buildings: street-facing plots placed every 30 m along non-service roads where no OSM footprint exists, random 7–12 m plots and 6–15 m heights, hill slopes kept open. Tagged `source: infill`.
- All building heights without `building:levels`, façade windows, chhajjas, parapets, water tanks, solar panels, old-city vs new-city colour sets, lamp posts, trees, roadside stalls, park benches/swings, the Chandpole gate massing, the Nahargarh ramparts and plateau, every material and the Aravalli terrain (a smooth analytic ridge so every mapped hill road stays drivable).
- Road widths per highway class (trunk 18 m … footway 2.5 m) and all kerbs/markings.
- **The Nahargarh game connector** (`id −80001`, `source: authored`, "Fort access connector (game)"): three points near (516,−879) → (500,−896) → (486,−886) joining an OSM pedestrian way to an OSM residential way. The real motor road to the fort exits the imported bounding boxes, which left the fort unreachable by road. The connector is drawn with yellow kerbs, black centre dashes, yellow/black bollards and a bilingual sign ("खेल मार्ग · GAME CONNECTOR · not a real road") at both ends, orange on the radar and dashed orange with a legend on the city atlas, so nobody mistakes it for OSM data. Render: `designs/04-city/actual-3d-07-nahargarh-game-connector.png`.
- Traffic routes, resident spawns, the delivery job stops, cash values, sound effects and all animation clips.

Regenerate the data with `pip install shapely && python3 tools/update_city_data.py` (`--refresh` re-downloads; otherwise the `/tmp/osm-*.json` caches are reused). The OSM extracts stay out of the repository; only the derived, compressed `jaipur_city.json` is committed and bundled in the APK.


## v0.9.0 — compact city, vehicles and neighborhood services

The user explicitly authorized the `gulabi-sahar` repository, README update, GitHub push and then wireless tablet installation. Do not apply this change to the portfolio repository. Source base: `91c1244` (v0.8.0).

- `CITY_COMPRESSION = 0.88` transforms road positions/widths, building footprints, parks, landmarks and navigation together. Terrain samples and district thresholds use the same coordinate convention; boundary walls and the fort exclusion are adjusted too. Character/car dimensions remain natural. The effective horizontal scale is 57.2% of geographical distances (65% × 88%). The original ODbL source data and attribution are preserved.
- Radar changed from 212 × 190 to 174 × 154 pixels. District and service destination lists have separate tabs; service locations are explicitly fictional. Existing district IDs and delivery/save indices remain stable.
- `vehicle_design.gd` contains original parametric geometry, merged per material with separate wheel assemblies. Traffic uses varied paint and sedan/taxi variants; the police display car has roof lights and stripes. Display vehicles are solid, static scenery; the original cream player car remains drivable.
- Fixed rotated building batches to apply dimensions in local space before rotation; rendered facades now agree with their collision boxes instead of shearing across signs/doors.
- Existing infill buildings gain glazed storefront bays, trim and selected nearby shop signs. Six service buildings use their existing footprints, recessed interiors, Hindi/English signs, roof details, interior counters/shelves/seating, planters and illuminated ceiling strips. No external model licensing or network dependency was added.
- The Android build/install scripts now use this workstation's lowercase `Android/sdk` path by default and allow `ANDROID_HOME` overrides. The existing signing certificate and app data must be preserved.

Design references: [Kimi's 3D workflow](https://www.kimi.ai/academy/3d-tutorial) (parametric forms and iterative scene inspection), [Jaipur bazaar architecture](https://www.hawa-mahal.com/jaipur-markets/) (warm plaster, projecting shopfronts, signage and street detail). References guide original geometry; no Kimi output or third-party photographs/models were copied into the game.

Run checks and capture the implemented scene:

```sh
./play.sh --headless --fixed-fps 60 --script res://tests/city_smoke.gd
./play.sh --headless --fixed-fps 60 --script res://tests/city_combat.gd
./play.sh --headless --fixed-fps 60 --script res://tests/city_refresh.gd
./play.sh --fixed-fps 60 --script res://tests/design_review_v09.gd
./build-android.sh
# Push the reviewed code/README before installation, as requested.
python3 tools/install_tablet.py
```

**Validation (2026-11-06):** city smoke, combat and refresh checks each passed with **0 failures**. Refresh checks cover all six destinations, solid floors, walking through every entrance, road parking after travel, vehicle wheel roll/steering, service-tab touch and unsheared building batches. Nine actual Godot renders were reviewed; the review caught and fixed the rotated-wall/sign issue. Android APK built successfully (173,209,534 bytes), v2/v3 signature verification passed, ZIP integrity passed and 16 KB alignment passed. APK SHA-256: `31c8c5af28dc936ff33a647ac6b634c573d6fb26eafa50d94e289caee59e7ec8`. **Wireless installation is next, after this source/README push; no v0.9 device success is claimed yet.** Sustained tablet FPS, thermals and battery use require a longer play session. Visual approval and the unresolved face likeness are not implied by automated checks.
