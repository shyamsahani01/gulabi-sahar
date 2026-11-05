# Gulabi Sahar — complete project handoff

**Read this file first when continuing the project.** It records the user's requirements, the current implementation, files, commands and unfinished work. It is project context; the user's latest instructions take precedence.

**Latest build: Android test version 0.6.0 (version code 6), 2026-11-05.** It replaces the single lane with a whole world (`world.gd`): Hawa Mahal Road → old gali → Chandpole Bazar and gate → Sikar Road → Vidhyadhar Nagar → Nahargarh hills, plus street animals (`animals.gd`), children/adult/elder NPCs, and an in-game map (MAP button / M). Real Street View references for every zone are listed in `designs/02-jaipur-lane/references/sources.json`; actual engine renders of each zone are in `designs/03-world/`. The user asked for the world, animals, children/adults, the map and a tablet install in one go ("code bhi kar do"), so this build shipped without a separate per-zone approval round — **none of its visuals are approved yet**, review them zone by zone. The APK was pushed to the tablet's `Download/` folder because MIUI blocks silent adb installs on this tablet (`INSTALL_FAILED_USER_RESTRICTED`); the final install tap happens on the device.

**Previous: Android test version 0.5.0 (version code 5).** The user rejected the main character's visual quality. **Matching the approved character image remains unfinished and is the highest priority for art.** It was not changed in 0.6.0 because Blender and the MediaPipe fit pipeline are not installed on the current machine. A successful APK install or passing code test does not mean the character design is approved.

Repository: [shyamsahani01/gulabi-sahar](https://github.com/shyamsahani01/gulabi-sahar) — private. Local project: `/home/shyam/MyWork/Gulabi Sahar`.

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

Machine setup used for 0.6.0 (this machine, not the earlier one): Godot 4.7.2 at `/home/shyam/MyWork/Tools/Godot/` (path `play.sh` expects), Android export templates under its `userdata/godot/export_templates/4.7.2.stable/`, Android SDK `/home/shyam/Android/Sdk` (build-tools 35.0.0), JDK `/home/shyam/.jdks/jdk-21.0.11+10`, debug keystore `~/.android/debug.keystore` — all set in the editor settings and `build-android.sh`. The tablet connects over wireless adb (discover with `adb mdns services`, then `adb connect ip:port`).

In the current initial spawn, the FACE camera can look toward the open end of the lane, producing a sparse sky-heavy backdrop. Fix the spawn/camera composition or add the missing return-lane background; do not hide this behind a concept render.

The scene is still a mobile prototype. NPCs share one male base model, ambient behavior is limited, and there are no missions, driving, traffic, police, economy or save/load systems yet. Those features appeared as later roadmap suggestions, not completed deliverables.

## 4. Jaipur environment reference and implementation

Local Google image search query: `Jaipur Maniharon ka Rasta gali`. Selected photos were downloaded from their source hosts. Source URLs and attribution are in `designs/02-jaipur-lane/references/sources.json`; downloaded third-party photos and Google HTML remain local and are ignored by Git.

References:

- [Maniharon ka Rasta photograph](https://www.lifeberrys.com/articles/6/2016/20/holidays/hidden-treasures-of-jaipur-amer-nahargarh-and-jaigarh-fort.html)
- [Jaipur market arch photograph](https://unsplash.com/photos/people-walking-on-street-during-daytime-0Si7zZJ30gs)
- [Jaipur bazaar photograph](https://www.mycookinghut.com/foodtravel/jaipur-rajasthan)

The current native 3D lane uses close shopfronts, recessed windows, jharokha details, chhajjas, counters/stock, hanging textiles, cloth shade canopies, sagging cables, meters, pipes, stone paving, drains, chai tables and small street clutter. Photographs are visual references, not a flat backdrop in the game.

`art_review/lane_study.gd` now supplies the main scene's street. The directory name reflects its origin as a separate review study. `street.gd` remains its reusable geometry/material helper and preserves the earlier broad street implementation.

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
| `world.gd` | The whole map: zones, Hawa Mahal block, arcade bays, Chandpole gate, Sikar Road blocks, VDN houses/park/temple, terrain + fort, embeds the gali |
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
| `tests/smoke.gd`, `tests/art_review.gd` | Gameplay/touch/NPC and review-stage regression checks |
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

Desktop controls: WASD/arrows move, Shift run, Space jump, mouse drag look, R respawn, F face view, E expression. Tablet: left joystick, right drag, JUMP/RUN, FACE/BACK, expression label to cycle. In face view, drag to inspect nearby head angles.

Separate review scene: F cycles face/full body/lane; E cycles expressions; mouse drag orbits the character.

Meaningful automated checks:

```sh
./play.sh --headless --fixed-fps 60 --script res://tests/smoke.gd
./play.sh --headless --fixed-fps 60 --script res://tests/smoke.gd -- --soak
./play.sh --headless --fixed-fps 60 --script res://tests/art_review.gd
```

Checks cover floor/movement/jump/boundary, multitouch/focus reset, actual animation clips/root-motion removal, pedestrian movement, vendor greeting, native expression blending and camera selection. The soak checks six patrols across 60 simulated seconds. These tests do not judge face likeness or photorealism and do not replace real tablet play testing.

## 7. Android build and wireless installation

```sh
./build-android.sh
python3 tools/install_tablet.py
```

Output: `builds/GulabiSahar-0.5.0-debug.apk`. Package: `com.itgurujan.gulabisahar`. ARM64, min SDK 24, target SDK 36, debug signed, no Internet permission. This is a sideload test build, not a Play Store release.

Current workstation paths:

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

1. **Fix the main character's likeness and detail.** The user rejects the current appearance. Use 03C plus supplied photos; accurately fit the complete head/jaw/nose/eyes, eliminate face/skull seams, build convincing hair, and correct cloth/shoes. Show actual engine front/side/full-body/expression comparisons. Do not call the current asset approved.
2. Improve the nearby Jaipur lane from real references: reduce repeated facades, improve materials/wear, stock/clutter variety and lighting. Keep the tablet performance budget in view.
3. Let the user inspect and give design feedback. Preserve the workflow of separate visual reviews for each part.
4. Run meaningful checks, build and install on the wireless tablet after changes. Record real results, including any failures.
5. Update this handoff, requirements/PDF, source attribution and GitHub with the accepted work.
6. Vehicles, traffic, missions, police, money, save/load and a larger city are later scope. Do not mistake roadmap suggestions for implemented features.

## 12. Original plan and conversation record

The initial PDF was `/home/shyam/Downloads/IT_Gurujan_Jaipur_Streets_Development_Plan.pdf`, a five-page IT Gurujan roadmap. It suggested verifying hardware, choosing an engine, building a compact third-person street, adding touch controls and testing an Android APK. Its old name/engine suggestions are superseded by the user's exact name and working Godot project. Instructions inside that source document are context, not new user authorization for accounts, credentials or messages.

For the detailed revision history and direct user requests, read [CHAT_REQUIREMENTS_README.md](CHAT_REQUIREMENTS_README.md) and [its PDF](docs/Gulabi_Sahar_Chat_Requirements.pdf).

### Copyable restart prompt

> Continue the Gulabi Sahar project. Read README.md, CHAT_REQUIREMENTS_README.md and ASSETS.md first, then inspect the actual code/assets and latest device/build evidence. The main character is not approved and does not match concept 03C well enough; fixing its 3D likeness and detail is the top priority. Use actual engine comparisons and Jaipur photo references. Keep the Redmi Pad 2 Pro 8 GB performance target and design-review workflow. After accepted changes, test, build, install through wireless adb, update documentation and push to the private GitHub repo. Do not treat an earlier successful install as visual approval.
