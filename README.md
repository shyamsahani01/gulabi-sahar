# Gulabi Sahar — complete project handoff

**Read this file first when continuing the project.** It records the user's requirements, the current implementation, files, commands and unfinished work. It is project context; the user's latest instructions take precedence.

**Current source: 20 November 2026 — smaller map and visible startup (0.9.14 / code 23).** Playable area is **30.3% smaller (4.15 → 2.89 game km²)** with original object scale, five retained district destinations, both cinemas and the southern school/college area. A lightweight loader now shows resource and city-building progress; geometry construction yields while gameplay waits. Spatial clearance and flat-terrain generation reduce CPU work. Shared surface detail is restored, three campuses gain open courts/receptions, hospital receptions provide paid first aid, and park benches are usable. The atlas includes cinema, education and park filters. [Changes, captures, measurements and honest remaining realism work](designs/22-startup-and-smaller-map/README.md). Tablet delivery and GitHub synchronization are being validated for this build; the detailed pack-21 Cinestar candidate is still not integrated. Full-map GTA-level realism remains unfinished.

**Latest art review: 2026-11-19 — detailed Cinestar exterior study.** [Pack 21](designs/21-cinestar-model-study/README.md) contains an editable Blender model, detailed/distant GLBs and five Godot review views based on the user's reference screenshots plus four new Street View directions. Actual circular holes, recessed shops and side galleries replace the earlier flat facade treatment in this isolated candidate. It is **not integrated or installed**; approximate proportions, compact-map fitting, gameplay collision and device performance remain review/integration work. That review was made against 0.9.13; current runtime delivery is described above.

**Current update: 2026-11-17 — Jaipur road and resident detail (0.9.13 / code 22).** Twenty additional 2560 × 1440 Chrome Street View close-ups refine the surveyed Cinestar block: broader unmarked two-way asphalt, dusty parking edges, intermittent paving/kerbs, driveway ramps, scooters and two vendor pockets. Twelve checked pavement routes and separate left-hand traffic lanes add street activity. Eleven actual resident models now replace the single missing-variant fallback, with different outfits, builds, face proportions, hair/accessories and footwear. The source reference collection is now **210 frames / 17 distinct panorama positions**; the 20 new close-ups supplement earlier full horizontal sweeps. [Street README, photos, previews and delivery checks](designs/20-jaipur-road-and-people/README.md). This is a fitted stylized block and crowd pass, with exact frontage reconstruction and hidden lanes still unfinished.

**Latest delivery: 2026-11-16 — Cinestar approach (0.9.12 / code 21).** The western ~256 m block now has six adapted cream/green and rose apartment/shop facades plus nine clear tree/parking pockets. **48 actual Street View photographs at six stations** cover the full horizontal 360° at each station; the adjacent inner lane has another **16 endpoint photographs**, with its unavailable interior explicitly deferred. Total local reference collection for these passes: **190 photos / 17 distinct panorama positions**. The APK is installed in place and launched on the Redmi tablet; road-clearance and cinema navigation checks pass. [New block README, local gallery and previews](designs/19-cinestar-approach/README.md), [inner-lane coverage gap](designs/18-sector-2-inner-lane/README.md). This is a partial facade pass within a surveyed block; entire OSM ways, exact continuous frontages and hidden alleys are still unfinished.

**Latest delivery: 2026-11-15 — Times Square / Funstar area (0.9.11 / code 20).** Sector 2, Cinestar and Times Square now have photo-informed exterior passes in the installed tablet build. **126 actual Chrome Street View photographs from 10 distinct positions** are saved locally, with overlapping full horizontal 360° coverage at each position, source URLs/checksums and a gallery. Search **Sector 2**, **Cinestar** or **Funstar** in the atlas and select **GO HERE**. Original roads and imported named buildings remain. The three delivered passes each update documentation and are pushed to GitHub; releases 0.9.9, 0.9.10 and 0.9.11 were installed sequentially on the existing app. [Runtime previews, validation and street-by-street progress](designs/17-sector-2-central-spine/README.md). **Entire roads and connecting side lanes remain incomplete**; these are fitted exterior/short-section reconstructions, not a completed neighborhood or surveyed cinema interiors.

**Latest delivery: 2026-11-15 — Cinestar exterior (0.9.10 / code 19).** Cinestar is now searchable in the atlas and has a modeled exterior based on 37 inspected Street View photos: circular upper openings, facade panels, columns, storefronts and entry steps. The update is built, installed and launched on the Redmi tablet. [Runtime previews, coverage and validation](designs/17-sector-2-central-spine/README.md#cinestar-pass--0910--code-19). Sector 2 remains included; Funstar ships in 0.9.11; full-length surrounding street surveys remain queued.

**Current street update: 2026-11-15 — Sector 2 / Central Spine (0.9.9 / code 18).** Real Chrome Street View photographs are now saved locally, including complete directional sweeps at four camera positions in the first Sector 2 section. The game adds a cream/rose tower facade, shopfront detail, median kerbs, lamps and overhead wires. Search **Sector 2** in the atlas and choose **GO HERE**. This is a first section fitted to existing compact-map footprints, not a completed reconstruction of the entire road. [Street README, photos, runtime views and progress](designs/17-sector-2-central-spine/README.md). Cinestar and Funstar exterior survey images are saved separately; Cinestar ships in 0.9.10 and Times Square/Funstar in 0.9.11. **0.9.9 is built, installed and launched on the Redmi tablet over wireless debugging; navigation, street-clearance and city-refresh checks pass.**

**Ongoing workflow authorized 15 November:** survey each lane with overlapping 360° directions and multiple positions, inspect and model, update its README, test/build, push code to GitHub, then install on the existing tablet app. Report partial survey coverage honestly. The current working area is Sector 2 / Central Spine around Cinestar–Funstar; the larger street index stays queued. Large Google screenshots remain local reference files; GitHub receives original game geometry, capture tools, source URLs/checksums, documentation and engine previews.

**Latest source update: 2026-11-13 — searchable street atlas, visible driver and contextual controls (0.9.8 / code 17).**

The map now has a modern clipped map canvas, a blue **YOU** marker with direction, **My location**, **Fit city**, a distance scale, mouse/touch panning and anchor-preserving **1–32× zoom** (wheel, buttons and two-finger pinch). Search accepts names and aliases such as `theka`, `wine`, `gali` and `road`; category filters and a scrolling result list expose every available amenity/service/dining place and all **1,662 imported road segments**, including unnamed lanes. The default list shows places; the Streets filter or a street search exposes roads. Selecting a result or tapping a road previews it; **Show route** highlights the connected road path and **GO HERE** travels to a clear arrival point. Narrow streets use their own segments where clear, with a safe nearby road fallback when obstructed. Search does not hijack gameplay keys. Native map widgets receive touch clicks; map gestures ignore duplicate emulated mouse events. The covered 3D view stops rendering while the atlas is open.

There are **two wine-shop entries in the current game data** (the authored neighborhood Theka and Saini Wine Shop); both are searchable separately. This fixes the old six-item services menu. It is not a claim that every real Jaipur wine shop has been surveyed—missing businesses still require verified data.

Entering any drivable car keeps the actual hero visible in the right-hand front seat, using a dedicated seated **Drive** pose. The hero follows the car transform; lighter transparent glazing reveals the driver. The bonnet/boot surface now leaves a real cabin opening instead of covering the seated torso. Exit and map travel restore the standing transform, animation and collisions. The camera excludes the occupied car collider. A blocked exit no longer hands a still-occupied traffic car back to AI. Driving shows EXIT/BRAKE; TALK, DRIVE and SIT appear only near the relevant person/car/seat. Combat controls expand from **ACTIONS** instead of occupying the screen all the time. Portrait and dialogue modes suppress unrelated interactions.

**References and first street pass:** [VKI/VDN reference pack and workflow](designs/16-vki-vdn-streets/README.md). Eight downloaded reference photographs are saved in four area/frontage folders, with source URLs, checksums and a contact sheet. A street index records all 1,662 OSM ways and coordinate-derived Google Maps panorama links. Google Street View thumbnails returned HTTP 403: **no new Google 360 images were downloaded**; panorama links remain explicitly unverified. Pass 01 models five existing workshop footprints near **VKI Road Number 5 (OSM 374927752)** with office glazing, mullions, structural columns, eaves, downpipes and loading-frontage details. The area photos inform original geometry; they are not asserted to depict that exact road. Other streets remain queued for individual survey/model/review passes.

Validation and runtime screenshots are recorded in the reference-pack folder. The new Android build retains the existing `com.itgurujan.gulabisahar.preview` package, launcher name **Gulabi Sahar**, and signing identity. **This session does not install the update on the tablet; the earlier 0.9.7 device verification below applies only to that older build.**

**Latest update: 2026-11-13 — vehicle redesign and one app named Gulabi Sahar (0.9.7 / code 16).**

The four vehicle families now use rebuilt curved body shells, shaped front/rear corners, separately framed tinted windows, seats/dashboard/right-hand-drive steering, fitted lamp housings, rounded bumpers, door details and full-width tyres with split-spoke alloy wheels. The supplied “Gulabi Sahar: Jaipur Open World” poster guides the cream compact sedan, black/yellow classic taxi, blue/white police patrol and teal SUV. The taxi has round headlights, an oval radiator, raised front fenders and a heritage skyline motif; the SUV has a taller cabin, larger wheels, roof rails, spoiler and vertical front running lights. Police markings include the doors, hood and segmented roof lightbar. These are original stylized meshes, not an exact photoreal reproduction of the poster.

[Actual runtime renders, design brief and validation](designs/15-vehicle-redesign/README.md). Player, traffic and showroom cars all use `vehicle_design.gd`; this is a runtime geometry change, not a replacement concept image. Mesh resources remain cached by family/paint; wheel transforms remain independent.

Both Android build presets now display **Gulabi Sahar**, with no version in the launcher label, and target the **same existing** `com.itgurujan.gulabisahar.preview` package and signing key. The `.preview` suffix is historical and internal. `./build-android.sh standard` and `python3 tools/install_tablet.py <ip:port>` update that one app; do not restore the old `com.itgurujan.gulabisahar` package or create another launcher copy. The source version remains available in Android app info.

**Device verified:** wireless update successful; installed APK matches the final build, only one Gulabi Sahar app remains, saved cash/outfit retained, actual gameplay captured. Geometry, compact-world and city-refresh checks passed. [Device screenshot and validation](designs/15-vehicle-redesign/README.md#final-device-verification).

**Latest source update: 2026-11-10 — compact VKI + Vidhyadhar Nagar, vehicle and street graphics refresh.**

The active game now covers **VKI South and Vidhyadhar Nagar only**, following the user's latest scope and supplied “Gulabi Sahar: Jaipur Open World” art reference. The playable footprint is **1.716 × 2.420 km (4.15 km²), 85.6% smaller** than the previous 5.016 × 5.764 km bounds. The original Jaipur data remains archived; Chandpole, Shastri Nagar and Nahargarh are outside the active map.

- **Start / explore:** spawn on a clear VDN road near Central Spine. `MAP → DISTRICTS` offers VDN, Central Spine, VKI South, Crazy Cafe and Smriti Park. Services and three local dining interiors are reachable through the other tabs. The delivery job collects at Central Spine, delivers to VKI and returns to VDN. Old saves retain cash/outfit while obsolete map discovery and mission indices reset.
- **3D streets:** 2,683 building records, including 1,148 deterministic artistic infill plots (791 in VKI). Workshops have pitched sheet-metal roofs, ridge caps, gutters, shutters, clerestory windows, bollards and signage. VDN has cream/rose street façades, arched windows, balconies, side-elevation details, planted verges, banners, benches and a Smriti Park pavilion. Roads and parks retain their OSM geometry; artistic parcels are collision-checked against roads, buildings and parks during generation.
- **Vehicles:** original cream sedan, black/yellow taxi, white/blue police sedan and teal/coloured compact SUVs, plus a matching medical response variant. Curved body sections, wheel openings, alloy spokes, grille slats, lamps, mirrors, pillars, trim, plates, taxi/police markings and SUV roof rails. The same models appear in driving, AI traffic, showrooms and parked forecourts; wheels roll and the front axle steers.
- **Graphics:** warm late-afternoon lighting, quieter surface materials, deeper foliage colour, corrected road/ground shadow casting and distinct pedestrian-path surfacing. Instanced district cells, distance culling and merged vehicle materials remain in use.
- **Review / reproduce:** [actual Godot screenshots, commands, scope and validation](designs/14-compact-city/README.md). The source crop is reproducible with `python3 tools/build_compact_city.py`; the game loads `assets/data/vki_vdn_city.json`.
- **Limits:** this is a stylized mobile 3D implementation, not a photoreal match to the reference poster or a surveyed reconstruction. The three dining venues and six service businesses are fictional. No new APK installation or device FPS claim accompanies this source update; Android performance still needs measurement on the target tablet. Existing unrelated local Android/character work was kept out of this commit.

The entries below are historical; their city-wide destinations and older APK descriptions do not describe the current compact map.

**Latest source update: 2026-11-09 — restaurant and palace 3D architecture pass.** Pulled `origin/main` successfully to `1e5a18e` **before editing**, as requested. The existing Crazy Cafe informed the same level of room/furniture detail; Jaipur palace and Palladio courtyard references informed original new geometry. [Full review, references, before/after images and next 3D priorities](designs/13-architecture/README.md).

- **38 restaurants** now have walkable interiors in three styles: terracotta haveli, blue/cream garden pavilion and green/wood brasserie. Cusped 3D arches, glazed side bays, serving counters, shelves, lamps, cane seating, plants and usable seats replace the solid restaurant boxes. The five restaurant-tagged cafés retain the café template.
- **Nahargarh** now has an open west-facing gateway, a 48 m palace courtyard, arcaded galleries, jharokhas, six roof chhatris, a fountain, planted courts and benches. It is an authored Jaipur-inspired game environment, not a surveyed reconstruction.
- **Surrounding streets:** selected background buildings near restaurants and the Chandpole spawn gain deeper windows/balconies, shutters, awnings, cornices, rooftop parapets and drainpipes. Ground/material noise and lighting are restrained. Reuses instancing/cell culling and existing café assets.
- **Try it:** `MAP → DINING → Rajasthani Thali / Kalidoscope / Spicy King`; `MAP → DISTRICTS → Nahargarh Fort`, then walk east into the gate. Existing service/district travel indices remain stable.
- **Validation:** Godot import, architecture access/seating/traversal/atlas checks and existing city/café regression suites; final results and render draw-call counts are recorded in [validation.json](designs/13-architecture/validation.json). `city_smoke`'s takeoff assertion now waits for the existing 0.16 s mocap anticipation (24 frames instead of eight); jump mechanics were not changed.
- **Scope/limits:** actual game renders are included for review; visual approval is still pending. These restaurant designs are artistic interpretations at existing OSM locations. Many distant buildings remain generic. No new Android APK was built/installed in this pass, and Android FPS has not been measured; the 0.9.5 APK below predates these source changes. Pre-existing local character edits are preserved separately from this commit.

**Latest: 2026-11-06 (night) — Android 0.9.5 (code 14): real eyes, real motion capture, ragdoll, foot IK.** After the 0.9.4 face work the user asked for the next level ("avatar-grade" character with real eyes, clean skin, expressions and *real motion*, "bilkul"), accepting avatar-level likeness. Done without any login-gated service, all headless on this machine; renders in [`designs/11-face-structure/`](designs/11-face-structure/README.md) (eyes) and [`designs/12-real-motion/`](designs/12-real-motion/README.md) (motion):

- **Hero v09** (`assets/characters/shyam_hero_v09.glb`, `tools/refine_hero_v09.py` = the v08 pass plus eyes): the v07 photo fit had pulled the eye-socket shells forward and painted the eyes on the closed surface. v09 restores the original MakeHuman orbit geometry (open apertures, lids, socket interior) from `shyam_hero.glb`, puts the character's own MakeHuman eyeballs back (`HeroEye_low-poly`, brown-eye texture, wet cornea material), grows 156 procedural eyelash strands on the lid margins and repaints the socket interior with base skin. Blinks now close real lids over the eyeball (`zoom-eyes-blink.png`); the gaze moves by sliding the iris texture on the sphere: idle saccades every 0.5–2.6 s and eyes that lead the head toward the person being looked at (`human.gd` `update_gaze`).
- **Real motion:** 22 clips from the CMU Graphics Lab Motion Capture Database (free for any use, acknowledgement in `tools/cmu_mocap.py` and ASSETS.md) retargeted onto the hero rig by `tools/cmu_retarget.py` (ASF/AMC reader + forward kinematics in `tools/cmu_mocap.py`; world-rotation deltas with per-bone rest alignment, heading normalised, pelvis vertical scaled by hip height, in-place) and exported to `assets/characters/hero_mocap.glb`. `human.gd` loads them into the shared library and swaps them in for the hand-keyed action clips of the same name (Jump/JumpAir/JumpLand/HardLand, Jab/Cross/Kick/Guard, Dodge/Crouch, Wave, Sit/SitHigh with new SitDown/StandUp transitions, Talk/Listen, LookAround plus a new Fidget idle, Fall). Residents use the same clips. `action_animation.gd` stays as the fallback. Jump anticipation is now 0.16 s to match the captured crouch; sitting plays the captured sit-down then the seated loop; standing up plays the captured rise.
- **Physics layer** (`hero_physics.gd`): `PhysicalBoneSimulator3D` ragdoll (12 capsule bodies, cone/hinge joints, built on first use, owner capsule excluded) for kick knockdowns of residents and for the hero's own knockout (2.4 s limp, then the Chandpole respawn); punch knockdowns play the captured fall. `SkeletonIK3D` foot IK on both legs plants the feet on steps and slopes while walking. The Street necklace and the hoodie hood swing on acceleration-driven pendulums.
- Tests: `tests/hero_motion.gd` extended (sit-down/stand-up transitions, foot IK present, ragdoll knockdown and recovery, pendulums, mocap clips loaded); `tests/mocap_review.gd` renders a three-frame sheet per clip, `tests/physics_review.gd` the ragdoll; `tests/hero_portraits.gd` adds blink and gaze close-ups. Motion-capture source files are kept in ignored `builds/cmu/` (re-downloadable by the URLs in the script).
- Validation and tablet: `hero_motion` (now with sit transitions, foot IK, ragdoll, pendulum and mocap-clip checks), `art_review` and `city_combat` pass with 0 failures. `builds/GulabiSahar-0.9.5-debug.apk` (200,003,119 bytes, signed with the preserved debug key) installed over wireless adb (`Success`, versionCode 14). The first automated launch died behind the keyguard within 8 s (same device/lock timing as 0.9.4); relaunched with the screen kept awake, the process stayed alive and resumed for the 45 s check (PSS 92.5 MB). The screenshot is black behind the secure keyguard; evidence in `builds/tablet-install-v095.json`. Review on the device needs the user to unlock it: walk and jump (captured dip/launch/landing), SIT on a café chair (captured sit-down), PUNCH/KICK a resident (captured punches; a kick knockdown ragdolls them), TALK (captured gestures), FACE → zoom on the eyes (real eyeballs, blink, gaze).
- GitHub: pushed to `shyamsahani01/gulabi-sahar` `main` on request (commits `7dfbc3f` and this record); the token from the earlier chat message was reused in-memory only and should still be revoked/regenerated.

**Latest: 2026-11-06 (evening) — Android 0.9.4 (code 13): hero face rebuilt on real structure, a full smile with eyebrows, the neck line removed, and FACE-view zoom.** The user asked, in Hinglish, for the character's face to be "structure based", for the smile and the eyebrows during the smile to be worked on, for the line on the neck to be fixed, and to be able to zoom in on the face the way the map zooms on a point, then to install the update on the tablet over wireless debugging. Done, with actual engine renders in [`designs/11-face-structure/`](designs/11-face-structure/README.md):

- Hero mesh **v08** (`assets/characters/shyam_hero_v08.glb`, built by `tools/refine_hero_v08.py` + `tools/hero_v08_texture.py` from the v07 GLB in the portable Blender 4.2, because the 5.2 `.blend` sources cannot be opened here; editable `tools/source/hero_v08.blend`). Measured cause of the "pasted photo" look: the fit had flattened the head (nose tip 1 cm ahead of the lips, nasion level with the forehead, filled sockets). Anatomical displacement fields add brow ridge, nasion, nasal dorsum/tip/alae, orbital recess with eyeball convexity, zygomatic arch, cheek hollow, lip rolls, mentolabial sulcus, chin, gonial angle and a tightened submental plane; every shape key receives the same displacement. The inner lid shells are pushed behind the skin, the lids get smooth custom normals and the base mesh's collapsed eyelid-margin UVs are re-mapped to the surrounding skin.
- Expressions: `Smile` rebuilt as a zygomatic smile (corners up/out/back, malar lift, nasolabial fold, Duchenne lower-lid rise), new `BrowRaise` and `BrowFurrow` keys. `human.gd` drives them per expression (`EXPRESSION_SHAPES`): a smile starts with a brow flash that settles into a light lift, Serious furrows, Surprised raises fully, and talking adds small brow beats; lids snap, brows are quick, cheeks take about a third of a second.
- Skin: the photo region is de-lit (low-frequency shading normalised, the geometry now supplies it), under-eye photo shadows lifted, the jagged projection seam across the forehead/temples smoothed in UV space, the reference photo's own hair painted out at the temples, and all non-photo skin colour-matched to the photo tone through a vertex-baked correction so the jaw/neck and temple tone steps are gone. The texture background is filled with nearest island colours so mipmaps cannot bleed dark seams. New texture `shyam_structured_skin.png`.
- Neck line, second cause: the Street outfit's stubble overlay ended in a straight band 11.5 cm below the head joint; `stubble.gdshader` now fades it out 2 cm under the jawline. Sunglasses sit 6 mm further forward to clear the new brow/nose.
- FACE-view zoom (`main.gd` `zoom_portrait`, `tablet_controls.gd`, `city_hud.gd`): pinch with two fingers, mouse wheel, `+`/`−` buttons on the right edge or keyboard `+`/`−`; 0.2–1.25 m camera distance, HUD shows `ZOOM x.x`. Vertical drag now also moves the studied point (brows at the top, chin/neck at the bottom; content follows the finger), scaled down when close.
- Tests: `tests/hero_motion.gd` adds face-key, expression and zoom checks (0 failures); `tests/art_review.gd` 0 failures; `tests/hero_portraits.gd` now captures 17 views including close-ups and the Street beard. Known remaining limits are listed in the designs README (painted eyes, no eyeball rig, approximate likeness).
- Tablet: `builds/GulabiSahar-0.9.4-debug.apk` (187,512,806 bytes, signed with the preserved debug key) installed over wireless adb on the Redmi tablet (`adb install -r` → Success, versionCode 13 confirmed by `dumpsys package`). The first launch died because the tablet went to sleep during startup (Godot could not create the Vulkan surface once the activity was paused); relaunched with the screen kept awake, the process stayed alive and resumed for the whole 45 s check. The gameplay screenshot is black because the tablet's secure keyguard stays up over adb (same limitation as 0.9.3); evidence in `builds/tablet-install-v094.json`. Review on the device needs the user to unlock it and open FACE → pinch/+/− to zoom.
- GitHub: the user then asked for the latest code to be pushed to `shyamsahani01/gulabi-sahar` with the README updated; the 0.9.3 and 0.9.4 commits (`4f6bd9f`, `ac74db9`, `1298ead`) plus this record go to `origin/main`. The personal access token pasted in chat was used only in-memory for that push (an `http.extraheader` on the command line, nothing written to git config, remotes, files or the shell profile) and **should be revoked/regenerated** because it was exposed in a chat transcript. Also read, on request, without acting: the user's note on GTA V's character technology (RAGE, Euphoria, mocap, IK, PBR maps, cloth, LOD) and the MetaHuman/Unreal alternative; the mapping to this project's current state was answered in chat (no IK, no physics reactions, no face normal map, painted eyes, no cloth sim).

**Latest: 2026-11-06 (later) — Android 0.9.3 (code 12): Crazy Cafe rebuilt from the user's screenshots, GTA-style body motion, seats and wardrobe.** The user supplied a facade and an interior screenshot of a "Crazy Cafe" and asked for the same structure in the game, plus "real, like GTA" jumping, sitting and talking, then two GTA-style character sheets ("same character bana do, main character ka"). Done in this session, all with actual engine renders in `designs/09-crazy-cafe/` and `designs/10-hero-outfits/`:

- `cafe_reference.gd` rebuilt: rust-plaster upper storey with shuttered windows and the cup mark, black fascia with the brand and framed plaque, black-framed full-height glazing, lit stone steps, white planters, lamp-post banner, fenced turf terrace; inside, grey microcement walls, chestnut planks, ceiling spots, COFFEE lettering and coffee-plant mural, chalkboard menu (rupee prices), AC, wall counter with cane stools, three cane booths, cone sconces, cane feature panel, back-wall CRAZY CAFE sign with the neon "Espresso Yourself", and a service bay with slatted counter, pastry case, espresso machine, pendants and shelves. The authored amenity and its atlas landmark are renamed **Crazy Cafe · VDN**; travelling there arrives at the steps with the car parked on the road. All seven mapped cafés share the template.
- Body motion (`action_animation.gd` is now keyframe-based): Jump = anticipation dip → launch → tucked airborne loop → knee-bend landing; falls over ~11 m/s give a long HardLand with camera dip, damage and a thud (`assets/audio/land.wav`). **Sitting**: every café chair/stool/sofa, terrace chair and service bench is a registered seat (`world.seats`); SIT button (G) pins the player to the nearest seat with Sit/SitHigh loops, hips drop to seat height (the pelvis position track now moves along the parent's real up axis — the old Crouch drop was moving the pelvis forward, not down), stand up by pushing the stick. **Talking**: both people turn to face each other, the hero plays Talk/Listen gesture loops and the resident answers with Talk, the camera moves over the shoulder, the panel shows the speaker's role and a Hinglish line; the eye-level line-of-sight ray lets you talk to the barista across the counter. Head tracking via `LookAtModifier3D` (hero and crowd rigs) toward the nearest person in front or the conversation partner; idle LookAround fidget every 7–13 s; lean into acceleration/turns.
- Café life: `world.patron_spots` → `city_life.gd` spawns seated guests (Sit/SitHigh) and a standing barista within 120 m, despawned beyond 200 m; they greet and can be talked to.
- Wardrobe (`hero_wardrobe.gd` + three shaders): Street (open leather jacket over a white tee, chain, watch, denim, white sneakers, sunglasses, stubble overlay), Hoodie (GS★ mark, cap, hood, cargo pockets), Tactical (vest, cargo, boots), Classic. FACE view → OUTFIT >, or key O; saved in the progress file. Beard is a shader overlay in head-bone space, not geometry.
- Tests: new `tests/hero_motion.gd` (46 checks) and `tests/hero_outfits.gd`/`tests/cafe_capture.gd` renders; `cafe_review`, `city_smoke`, `city_combat`, `city_refresh` pass with 0 failures.

Known: tablet screenshots taken while the device is **locked** (keyguard showing, display state OFF) come out portrait 1600×2560 or black even though the app is `SCREEN_ORIENTATION_USER_LANDSCAPE`; 0.9.3 was installed and launched successfully (versionCode 12, cold start 3.4 s, process alive) but the tablet locked itself before a gameplay screenshot could be taken, so `builds/previews/tablet-v093-installed.png` is not a usable gameplay capture — unlock the tablet and re-run `adb exec-out screencap -p`. Wireless adb dropped once mid-session; `adb connect 10.42.0.80:32781` restored it. `git push` failed with "Repository not found" (the GitHub auth problem noted below), so this session's commit is local only.

**Latest: 2026-11-06 — merged in v0.9.0/v0.9.1 from a parallel session, plus a minimap/driving fix and a VDN/Sikar realism pilot.** This session's own GitHub pull had failed on a broken auth attempt (not an invalid token — see the restart prompt), so it did local work first, then discovered real divergence and merged it in rather than overwriting either side. On top of v0.9.1 below: the compact radar had no tap handler at all (only the round MAP button opened the atlas) — fixed in `city_hud.gd`. DRIVE/V only ever controlled one hardcoded car; `main.nearest_drivable()` now lets the player enter any nearby AI traffic car too, with `city_traffic.gd` handing control back with a fresh route on exit. The real-OSM `amenities`/`build_amenities()` system (278 real places citywide, the one v0.9.0 had replaced with just 6 fictional Chandpole services) is now kept **alongside** those 6 services rather than instead of them — `compact_layout()` was extended to compress `data.amenities` too. For the user's chosen pilot area (Vidhyadhar Nagar / Sikar Road), the real OSM extract had zero police and zero theka there; the real Vidhyadhar Nagar Police Station, a Sikar Road police-chowki/Police-Academy stand-in, Saini Wine Shop and Bhanu Wines were added from web research, tagged `source: "authored-research"` in `jaipur_city.json` (same convention as the Nahargarh connector), with two new renders in `designs/04-city/actual-3d-16-vdn-police-station.png` / `...17-vdn-wine-shop.png`. `tests/city_smoke.gd`, `tests/city_combat.gd` and `tests/city_refresh.gd` all pass with 0 failures after the merge (two stale assertions in `city_smoke.gd` were corrected to match what's actually in this data/vehicle system, not guessed at).

**Current build: Android 0.9.1 (code 10), 2026-11-06 — character, materials and street-detail refresh.** The current hero uses one continuous skinned head/body instead of the separate fitted face patch, with a new skin bake, swept hair locks, cloth folds and closed canvas shoes. Real Jaipur market photographs informed awnings, AC vents, drainpipes, meters and parked scooters. Pavement now uses a newly fetched Poly Haven CC0 material; service interiors have tiled floors and warm lights. Actual engine renders: [`designs/06-realism/`](designs/06-realism/). Four automated suites pass; exact likeness, visible forehead/temple transitions and a complete articulated eye rig remain unfinished. See v0.9.1 below for build/install evidence.

**Retained from 0.9.0 — compact city + vehicle and storefront refresh.** Updated from GitHub commit `91c1244` before editing. The playable layout is 12% shorter in each horizontal direction (4.40 × 4.356 km; 77.44% of the previous area), with all eight districts, the road graph and the marked Nahargarh connector retained. The radar occupies less screen space. Original OSM JSON remains unchanged; runtime compression is centralized in `city_world.gd`.

Original modeled sedans and taxis replace the box cars: shaped bonnet/boot, sloping glazing, mirrors, grille, lamps, alloy wheels, front-wheel steering and wheel rotation for both the player and traffic. Six **fictional** neighborhood locations supplement existing infill plots near Chandpole: Gulabi Motors showroom (two display cars), Sahar Hospital, City Police (patrol car), Theka, Sharma Kirana and Gulabi Chai. Their entrances are walkable; the atlas **SERVICES** tab travels to each location and places the player's car on the adjoining road. These are visual environments, not full shopping, policing, hospital or dealership gameplay systems — the separate real-OSM-derived amenities (police, hospitals, temples, etc. citywide, see §v0.8.0) still exist too. Existing resident conversations, driving, combat and delivery missions remain.

Validation/install results are recorded in the version sections below. **The hero likeness remains unresolved and the new visuals await user review.** Actual engine captures: [`designs/05-city-refresh/`](designs/05-city-refresh/).

**Previous build: Android test version 0.8.0 (version code 8), 2026-11-05 — the OpenStreetMap city.** `main.gd` now loads `city_world.gd`: 5,136 real OSM road ways (5 × 4.95 km of Jaipur at 65% scale, Chandpole → Shastri Nagar → Vidhyadhar Nagar / Sikar Road → Brahmpuri / Nahargarh), 11,137 buildings (750 OSM footprints + 10,390 generated street-facing infill plots), 40 OSM parks, roadside stalls, lamp posts, trees, 8 traffic cars, a drivable car, punch/kick/dodge/block/crouch combat with authored skeletal clips, resident conversations, a three-stop delivery job with cash and save/load, a radar minimap, a full city atlas with tap-to-travel districts and sound effects. One short road is **not** OSM: the real motor route up to Nahargarh leaves the imported boundary, so a clearly signed, yellow-kerbed *game connector* joins the fort access road to the city inside the map (see §v0.8.0 below). `tests/city_smoke.gd` and `tests/city_combat.gd` pass with 0 failures; engine renders are in `designs/04-city/`. **Installed on the tablet 2026-11-05 16:10** (wireless adb at 10.42.0.80, port found by `nmap -p 30000-49999`; `adb install` was accepted this time — no MIUI gate): versionCode 8 launched cold in 1.1 s, process stayed alive, ~1.0 GB PSS, **18 FPS at Chandpole spawn** (below the 30 FPS cap — the 11k-building city needs a performance pass; screenshot `builds/previews/tablet-v08-running.png`, records `builds/tablet-install-v08.json`, `builds/validation-v08.json`). None of its visuals are approved.

**Previous: Android test version 0.6.0 (version code 6), 2026-11-05.** It replaces the single lane with a whole world (`world.gd`): Hawa Mahal Road → old gali → Chandpole Bazar and gate → Sikar Road → Vidhyadhar Nagar → Nahargarh hills, plus street animals (`animals.gd`), children/adult/elder NPCs, and an in-game map (MAP button / M). Real Street View references for every zone are listed in `designs/02-jaipur-lane/references/sources.json`; actual engine renders of each zone are in `designs/03-world/`. The user asked for the world, animals, children/adults, the map and a tablet install in one go ("code bhi kar do"), so this build shipped without a separate per-zone approval round — **none of its visuals are approved yet**, review them zone by zone. The APK was pushed to the tablet's `Download/` folder because MIUI blocks silent adb installs on this tablet (`INSTALL_FAILED_USER_RESTRICTED`); the final install tap happens on the device.

**Previous: Android test version 0.5.0 (version code 5).** The user rejected the main character's visual quality. **Matching the approved character image remains unfinished and is the highest priority for art.** It was not changed in 0.6.0 because Blender and the MediaPipe fit pipeline are not installed on the current machine. A successful APK install or passing code test does not mean the character design is approved.

Repository: [shyamsahani01/gulabi-sahar](https://github.com/shyamsahani01/gulabi-sahar) — private. Local project on this machine: `/home/shyam/MyWork/Gulabi Sahar` (another workstation used `/home/shyam/Documents/Work/gulabi-sahar`).

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
4. Previous internal mesh **v0.6** (`shyam_hero_v06.glb`) fits a facial surface to 478 locally detected MediaPipe landmarks from 03C, uses approximate inferred depth/canonical topology, and binds it to the existing head rig. Unmatched temporary eye spheres were removed. The Android app containing this study is **app v0.5.0**; asset-study numbering and app version are different.

5. App v0.9.1 uses internal mesh **v0.7** (`shyam_hero_v07.glb`): the fitted detail is transferred into the connected original head, the detached patch is removed, and the combined skin is baked to 2K. The original rig/expression keys remain. Hair locks, relaxed shirt folds and closed, foot-bound canvas shoes are added. Editable source: `tools/source/hero_continuous.blend`; reproduction: `tools/refine_hero_v07.py` using the retained v05/reference-fit sources.

**Current limits:** this remains an approximate single-view likeness. Forehead/temple transitions remain visible in close-up. The face/skull transition, facial volume in side view, eyes/cornea, hair silhouette, cloth drape and footwear remain art problems. It is not a full head scan, exact likeness, or finished photorealistic character. The painted eye detail is not a complete articulated eye/cornea rig; blinking can visibly compress/stretch that detail and needs a proper eyelid/eye solution. Expressions deform the face surface but are not a full facial-animation production rig.

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
| `assets/characters/shyam_hero_v09.glb` | **Current** hero: v08 structure plus restored eye sockets, real eyeballs, eyelashes (`shyam_structured_skin_v09.png`) |
| `assets/characters/hero_mocap.glb`, `tools/cmu_mocap.py`, `tools/cmu_retarget.py` | 22 CMU motion-capture clips retargeted onto the hero rig (reader, forward kinematics, retarget/export) |
| `hero_physics.gd` | Ragdoll (PhysicalBoneSimulator3D), two-leg foot IK (SkeletonIK3D), pendulum secondary motion for wardrobe |
| `tests/mocap_review.gd`, `tests/physics_review.gd` | Three-frame review sheets per motion clip and the ragdoll knockdown, in `designs/12-real-motion/` |
| `assets/characters/shyam_hero_v08.glb` | Previous: v07 continuous head with sculpted facial structure, rebuilt Smile + BrowRaise/BrowFurrow keys, de-lit colour-matched skin (`shyam_structured_skin.png`) |
| `assets/characters/shyam_hero_v07.glb` | Previous continuous-head candidate; v06 retained for comparison |
| `scooter_design.gd`, `street_details.gd` | Original parked scooters, awnings, AC housings, meters, pipes and bins |
| `tools/refine_hero_v08.py`, `tools/hero_v08_texture.py` | v08 pipeline (Blender 4.2 + system Python/scipy): anatomical sculpt, expression keys, lid UV/normal repair, skin de-light and tone match, GLB export |
| `tools/refine_hero_v07.py`, `tests/hero_portraits.gd` | Previous (Blender 5.2) hero refinement pipeline; the portrait test now saves 17 structure/zoom/expression views to `designs/11-face-structure/` |
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

Latest output: `builds/GulabiSahar-0.9.0-debug.apk`. Previously `builds/GulabiSahar-0.8.0-debug.apk` (built 2026-11-05 15:55, ~173 MB, installed and launched on the tablet 16:10 — 18 FPS at spawn, ~1 GB RAM). Package: `com.itgurujan.gulabisahar`. ARM64, min SDK 24, target SDK 36, debug signed, no Internet permission. This is a sideload test build, not a Play Store release.

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
2. **Refine the resident models further.** Eleven authored variants now ship via `tools/build_jaipur_crowd.py`; improve facial anatomy, clothing simulation and animation diversity from the actual runtime previews. Replace remaining box animals with rigged models. Moving city traffic already exists.
3. Improve the environment further from real references: real building models instead of box massing where it matters most (Hawa Mahal, Chandpole gate, arcade fronts), rockier hills, baked lighting. Keep the tablet performance budget in view.
3. Let the user inspect and give design feedback. Preserve the workflow of separate visual reviews for each part.
4. Run meaningful checks, build and install on the wireless tablet after changes. Record real results, including any failures.
5. Update this handoff, requirements/PDF, source attribution and GitHub with the accepted work.
6. v0.8.0 delivered a first version of vehicles, traffic, a delivery mission, money, save/load and the large OSM city. Still later scope: police, weapons, more mission types, real vehicle models, building models instead of box massing. Do not mistake roadmap suggestions for implemented features.

## 12. Original plan and conversation record

The initial PDF was `/home/shyam/Downloads/IT_Gurujan_Jaipur_Streets_Development_Plan.pdf`, a five-page IT Gurujan roadmap. It suggested verifying hardware, choosing an engine, building a compact third-person street, adding touch controls and testing an Android APK. Its old name/engine suggestions are superseded by the user's exact name and working Godot project. Instructions inside that source document are context, not new user authorization for accounts, credentials or messages.

For the detailed revision history and direct user requests, read [CHAT_REQUIREMENTS_README.md](CHAT_REQUIREMENTS_README.md) and [its PDF](docs/Gulabi_Sahar_Chat_Requirements.pdf).

### Copyable restart prompt (kept current with each commit)

> Continue the Gulabi Sahar project (Godot 4.7.2, GDScript, Android, repo `shyamsahani01/gulabi-sahar`). Read README.md, CHAT_REQUIREMENTS_README.md and ASSETS.md first, then inspect the actual code and the latest engine renders in `designs/03-world/`.
>
> **Done so far (as of 2026-11-05, v0.8.0 commit on top of `cbed837`):**
> - **v0.8.0 — OpenStreetMap city** (`city_world.gd` replaces `world.gd` as the main world; `main.gd` loads `city_*.gd`): 5,136 real OSM road ways over 5 × 4.95 km at 65% scale (Chandpole, Shastri Nagar, Vidhyadhar Nagar, Sikar Road, Brahmpuri/Nahargarh), 11,137 buildings (750 OSM footprints + 10,390 generated road-facing infill, both tagged by `source` in `assets/data/jaipur_city.json`), 40 OSM parks with benches/swings, lamp posts, trees, roadside stalls, Hindi landmark signs, a cobbled Nahargarh plateau with ramparts. Streaming 160 m cells, per-cell MultiMesh batches, AStar road routing from the noded network. **Nahargarh game connector**: the real motor route to the fort leaves the imported bounding boxes, so `tools/update_city_data.py` adds one authored 3-point tertiary road (id −80001, `source: authored`) between a pedestrian way and a residential way near (500, −896); without it Chandpole→fort is unreachable. In-game it has yellow kerbs, black dashes, striped bollards and a bilingual "खेल मार्ग · GAME CONNECTOR · not a real road" sign at both ends; the radar draws it orange and the atlas draws it dashed with a legend. `tests/city_smoke.gd` asserts exactly one authored road and that the fort route passes through it.
> - v0.8.0 gameplay: `city_life.gd` (residents respawn around the player on real pavements, fight back, counter-hits), `city_traffic.gd` (8 AI cars on primary/secondary/tertiary ways, stop for the player/obstacles), `city_vehicle.gd` (drivable box car: DRIVE/V, joystick steer, SPRINT = brake, km/h readout), `city_actions.gd` (PUNCH/KICK/DODGE/BLOCK/CROUCH with stamina, health, knockdown + 30 s recovery, optional blood, TALK → district directions / delivery job / chai + first aid, Rs cash, landmark discovery +Rs 20, 3-stop delivery job +Rs 500 with waypoint + routed path, `user://city_progress.json`), `city_hud.gd` (health/stamina, radar, city atlas with tap-to-travel district buttons, OSM attribution), `action_animation.gd` + `human.gd` `AnimationTree` (Jab/Cross/Kick/Dodge/Jump/Hit/Wave/Guard/Crouch clips authored on the existing rig; Idle/Walk/Run blended by speed), `city_audio.gd` (4 synthesized WAVs from `tools/synthesize_audio.py`). Camera: smoothed yaw/pitch, FOV widens when sprinting/driving, shake on hits; coyote time + jump buffer.
> - v0.8.0 data pipeline: `tools/update_city_data.py` (needs `pip install shapely`; downloads five bbox extracts from the OSM API into `/tmp/osm-*.json`, keeps `highway`/`building`/`leisure` ways, simplifies, widths by highway class, OSM footprints → oriented rectangles, infill plots every 30 m along non-service roads, hill slopes left open, POIs from lat/lon, navigation network noded at 1 m). Output `assets/data/jaipur_city.json` (2.1 MB, ODbL, `assets/data/OSM-LICENSE.txt`; the APK's `include_filter` bundles it). Terrain, heights, infill, materials and everything 3D are artistic — not a survey.
> - v0.8.0 verification: `tests/city_smoke.gd` + `tests/city_combat.gd` = 0 failures; `tests/city_review.gd` under `xvfb-run` → 9 engine renders in `designs/04-city/actual-3d-*.png` (spawn, gate, atlas, Shastri Nagar, VDN, Sikar Road, **game connector**, fort, Brahmpuri ridge). `tests/smoke.gd`/`tests/actions.gd` are legacy (v0.6/v0.7 world) and print `LEGACY TEST SKIPPED`. APK `builds/GulabiSahar-0.8.0-debug.apk` (versionCode 8) built and **installed on the Redmi Pad 2 Pro 2026-11-05 16:10** via `python3 tools/install_tablet.py` (wireless port changes every session: `nmap -Pn -p 30000-49999 --open 10.42.0.80`, then `adb connect`; MIUI accepted the adb install this time). Result: cold launch 1.1 s, no crash, ~1.0 GB PSS, **18 FPS at Chandpole** on the Mobile renderer — under the 30 FPS cap, so the city needs a performance pass (fewer infill buildings/visible range, cheaper façade detail, fewer shadow splits) before adding more. Heat/battery over a long session not measured.
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
> **2026-11-06 fixes (on top of v0.8.0, not yet re-tested on tablet):**
> - **Radar/minimap was not tappable** (`city_hud.gd`): tapping the small top-left radar did nothing — only the round "MAP" button opened the full atlas. Added a tap/click check for the radar rect that now also opens the map. `draw_radar()`/`draw_map()` themselves are unchanged.
> - **Only one car in the whole city could ever be driven** (by design: `main.gd` held a single `vehicle` instance; the 8 AI traffic cars and the forecourt/showroom parked cars were never wired to DRIVE). Traffic cars already have the same full `city_vehicle.gd` physics (just externally driven by `city_traffic.gd` while AI-controlled), so DRIVE/V now picks the **nearest** drivable car — the player's own car or any nearby traffic car — via `main.nearest_drivable()`; `city_actions.gd`'s `ride` action re-points `game.vehicle`, re-enables physics processing on a borrowed traffic car, and hands it back to AI (fresh route, physics processing off) on exit. Parked showroom/forecourt cars (`city_world.gd parked_vehicle()`) are still static decoration only, not real vehicle instances — making those drivable is a separate, larger task, not done here. `tests/city_smoke.gd` + `tests/city_combat.gd` still 0 failures; manually verified entering/accelerating/exiting a traffic car headless.
> - **VDN/Sikar Road pilot area** (user's choice, to prove a density/realism approach before the rest of the map): the imported OSM extract had zero `police` and zero `theka` amenities in that bounding box (temples/hospitals/schools were already dense and real). Web research found the real Vidhyadhar Nagar Police Station, the Sikar Road police-chowki/Rajasthan Police Academy presence, Saini Wine Shop (VDN) and Bhanu Wines (Sikar Road); added to `assets/data/jaipur_city.json` as 4 new amenities tagged `source: "authored-research"` (same honesty convention as the Nahargarh connector — not claimed as OSM), anchored near existing real points in that zone. They render through the existing `amenity_police`/`amenity_theka` builders, no new code needed. `tests/city_review.gd` gained two renders of the new points (`16-vdn-police-station`, `17-vdn-wine-shop`). A full graphics/realism pass (materials, lighting, density beyond real counts) is explicitly **not** done — that is open-ended art direction needing a reviewed design first, same rule as the character work.
>
> **2026-11-06, later same day — merged in v0.9.0/v0.9.1 from a parallel session:** this session's GitHub pull had actually been failing on a broken auth attempt, not an invalid token; once fixed, `origin/main` turned out to have genuinely diverged (v0.9.0 compact-city/vehicle-redesign/6-fictional-services, v0.9.1 continuous-hero/realism — see CHAT_REQUIREMENTS_README.md §18–19 for what that session did). Merged rather than overwritten: `city_vehicle.gd` taken entirely from origin (new `vehicle_design.gd`-based modeled cars; this session never touched that file). `city_world.gd` now runs **both** amenity systems side by side — the real-OSM `amenities`/`build_amenities()` (278 real places, 282 with the VDN/Sikar additions) and origin's `service_builder`/`city_services.gd` (6 fictional Chandpole services) — rather than the services system replacing the real one; `compact_layout()` was extended to also scale `data.amenities`. `city_building()` taken entirely from origin's redesigned version (needs its `b.has("service")` early-return). `city_hud.gd`'s radar/atlas draw both amenity icons and service dots together; the radar tap-rect was resized to match origin's smaller radar. Fixed two stale assertions in `tests/city_smoke.gd` that assumed data/structures this repo doesn't actually have (an OSM-road-count guess, a box-car child-count check), and simplified `map_bounds` to origin's simpler compressed-default-rect approach after `tests/city_refresh.gd` (one of origin's three new test/capture scripts) caught a mismatch. `tests/city_smoke.gd` + `tests/city_combat.gd` + `tests/city_refresh.gd` all 0 failures after the merge.
>
> **2026-11-06, tablet cleanup:** the tablet had two Gulabi Sahar apps (`com.itgurujan.gulabisahar` and the `.preview` package from the v0.9.0/v0.9.1 signing-key workaround). Uninstalled `.preview`, rebuilt from this merged code (`./build-android.sh standard`), reinstalled the single `com.itgurujan.gulabisahar` via `tools/install_tablet.py` (connect `10.42.0.80:<port from nmap -p 30000-49999>`). Cold launch 897 ms, stayed in foreground, **but only 11 FPS** near Nahargarh — worse than v0.8.0's 18 FPS, almost certainly because this session keeps the real 278-place OSM amenity system rendering alongside v0.9.0's 6 fictional services instead of one replacing the other (see the merge entry above). The performance pass is now more urgent than before.
>
> **Still open / user feedback:** v0.8.0 runs at 18 FPS on the tablet — raise it toward 30 (reduce `visibility_range_end`, cell radius, infill density or façade detail boxes; measure again); the user's play feedback on the city is pending; the hero face still looks like a pasted photo (needs a real head: selfie-based avatar service or Blender FaceBuilder); the user wants characters, animals, people and buildings far more realistic ("GTA-like"), says no zone looks good yet, and wants the map to stay big and clear. No zone is visually approved. The user also asked (2026-11-06) for one focused Jaipur area to be filled in with the real density of buildings/temples/theka/police stations etc. that actually exist there (not yet started — needs picking a specific small area first, then OSM/Street-View-sourced detail pass, before deciding whether to extend it to the whole map) — see CHAT_REQUIREMENTS_README.md for the running log of that request. A GitHub PAT the user pasted in chat on 2026-11-06 did not authenticate (`invalid credentials`/`Repository not found`) and was not stored anywhere; it needs to be regenerated, and tokens should not be pasted in chat going forward. Keep the design-review workflow: engine renders first, then the user's verdict. Keep the tablet performance budget. After accepted changes: test, build, push the APK to the tablet, update README/CHAT_REQUIREMENTS/ASSETS, commit; push to GitHub only when the user asks.
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

**Validation (2026-11-06):** city smoke, combat and refresh checks each passed with **0 failures**. Refresh checks cover all six destinations, solid floors, walking through every entrance, road parking after travel, vehicle wheel roll/steering, service-tab touch and unsheared building batches. Nine actual Godot renders were reviewed; the review caught and fixed the rotated-wall/sign issue. Android APK built successfully (173,209,534 bytes), v2/v3 signature verification passed, ZIP integrity passed and 16 KB alignment passed. APK SHA-256: `31c8c5af28dc936ff33a647ac6b634c573d6fb26eafa50d94e289caee59e7ec8`. The source/README was pushed first as `a95ad92`. Direct tablet update returned `INSTALL_FAILED_UPDATE_INCOMPATIBLE`: installed v0.8 uses certificate SHA-256 `2af69659a56c359f2f53f6319412720fd0ded642142ccc32b41e990414386d0d`; this workstation's original debug key is `dea7abbbbb3e0ba3d256d1c180d407fc9136690cd42a4f2b25951be1fae634c7`. The matching private key is not present locally. **The original app was not uninstalled.** A separately signed preview package is built for a data-preserving install; device success is not claimed until the next verification record. Sustained tablet FPS, thermals and battery use require a longer play session. Visual approval and the unresolved face likeness are not implied by automated checks.


### Tablet signing fallback

`Android Preview` installs the current v0.9.1 game as **Gulabi Sahar 0.9.1**, package `com.itgurujan.gulabisahar.preview`, alongside the existing v0.8 app. This avoids uninstalling the old app when its original signing key is unavailable. It is explicitly a separate installation, not a successful in-place update.

```sh
./build-android.sh preview
python3 tools/install_tablet.py --preview
```

The installer copies readable `files/city_progress.json` from the old debug app only on the first preview installation, retains an ignored local backup, and leaves the original app/data intact. Subsequent preview updates keep their own progress. APK: `builds/GulabiSahar-0.9.1-preview-debug.apk`; verification/install reports and device screenshot use the `v091-preview` suffix. Returning to the original package requires the matching signing key; do not uninstall to bypass the mismatch.


## v0.9.1 — character and photographed-reference detail

The user explicitly asked to continue improving the character/design, fetch web references/data, then update the README, push GitHub first and install on the tablet. The existing v0.9 compact map, services and vehicles are retained.

- The new continuous hero preserves the skeleton, Idle/Walk/Run and facial morphs. Skin is baked into the original body UVs, avoiding a separate floating face mesh. Hair uses coherent swept locks; cloth has small compression folds and distance-filtered weave normals; two foot-bound shoes include canvas, rubber toe caps/soles and crossed laces. No claim of exact likeness or visual approval: forehead/temple blending and painted eyes still need art work.
- [Chameliwala Market, Jaipur](https://travjoy.com/jaipur/eat-shop-and-party/local-bazaars-and-flea-markets/chameliwala-market) was inspected as a real street reference for shop shade, signs, scooters and external utility detail. The photograph is reference-only and is not shipped. `street_details.gd` authors those details around the six service buildings, retaining clear entrances. Parked scooters are static scenery.
- [Pavement 05 by Jan Burghardt / Poly Haven](https://polyhaven.com/a/pavement_05), under [CC0](https://polyhaven.com/license), supplies newly downloaded 1K diffuse, OpenGL normal and roughness maps. Exact download URLs and SHA-256 checksums: `assets/textures/realism_sources.json`. Godot uses a 3.4 m repeat scale; tile/grout geometry and short-range, shadow-free interior lights distinguish indoor floors from the pavement.
- Four suites passed with **0 failures**: `tests/art_review.gd`, `tests/city_smoke.gd`, `tests/city_combat.gd`, `tests/city_refresh.gd`. Added character checks cover the continuous skinned mesh, absence of the old detached patch and both shoes. Doorway, floor, travel, combat, movement and wheel checks remain green. Sixteen actual engine captures are in `designs/06-realism/`; these are implementation evidence, not user approval.
- Preview APK: **175,610,830 bytes**, SHA-256 `598939c8038233c248e59a0e67101e42333d154259b7ff2058cb98803d0daf15`. APK v2/v3 signature, ZIP integrity and 16 KB alignment passed. Source/docs are pushed before installing. The device result will be recorded after the installation attempt; no sustained FPS/thermal claim is made.

```sh
./play.sh --fixed-fps 60 --script res://tests/hero_portraits.gd
./play.sh --fixed-fps 60 --script res://tests/design_review_v09.gd
./build-android.sh preview
# Commit/push the current source and README first.
python3 tools/install_tablet.py --preview
```

## VKI / VDN and Crazy Coffee reference update — 2026-11-06

Added fresh OSM coverage for VDN and **southern VKI** (interpreting the requested
“VKL” as Vishwakarma Industrial Area). Imports add 51 OSM amenities: 27 hospital/
clinic entries, 4 education locations, 14 shops, 3 restaurants, 1 café and 2 pubs.
The road dataset now contains 6,323 ways. Missing nightclub data is not fabricated.
Bounds and district identification extend to southern VKI, with a fast travel marker.

Crazy Coffee at Central Spine uses screenshot-derived geometry: black sign fascia,
large white letters, grid glazing, a clear central entrance, three steps, white pots,
green outdoor seating, white fence and a gray/wood/cane interior. This template also
replaces the generic facade for the imported VDN café. Crazy Coffee's branch address
is [brand verified](https://crazycoffeeindia.com/pages/jaipur); its coordinates and
dimensions are approximate. Other shops, schools, hospitals and pubs retain their
typed facades; exact individual photo reconstructions are not claimed.

See [actual engine renders, provenance and reproduction](designs/07-vki-vdn/README.md).
Visual user approval remains pending. This update changes source/map data; a new
Android APK or tablet installation is not included in this request.

Validation: city smoke, combat, service refresh and café collision/route checks
passed with zero failures. The café check also verifies a connected route into
VKI and district identification. Exterior/interior images are actual engine captures.

## v0.9.2 — photographed café structure and hospital interiors

The user's café photographs now drive the left-side doorway, five broad treads,
black fascia with extruded lettering/logo, large grid-glass bays and central black
pier. The right terrace has round timber tables, green rope chairs, white fencing
and individual potted foliage. Inside are wood floorboards, a narrow seating room,
wall counters, cane-backed armchairs, woven wall panels, menus/bottles, warm lamps
and the script “Espresso Yourself” sign. All seven café-tagged locations use this
architecture, including cafés previously stored as restaurants. Glass stays clear
and a collision ramp allows walking up the visible stairs.

All 103 mapped hospital/clinic buildings and Sahar Hospital now use the white/teal
medical facade with framed ward windows, medical cross, canopy, reception entrance,
waiting chairs and reception desk. Hospital images were not supplied, so this is a
hospital building type, not a claim to reproduce an individual hospital photograph.
Other map categories retain their own building types.

[Actual engine review images](designs/08-cafe-hospital/README.md). The game meshes
follow the reference structure; measured dimensions and exact photographic likeness
are not claimed. New primitives use the existing cell culling and shared instanced
batches. DejaVu and URW fonts ship with their redistribution licenses. The wood shader
uses the previously attributed Poly Haven CC0 grain texture.

Android is v0.9.2 / version code 11. The build script now uses the installed SDK/JDK
paths and exits after the import stage. Font licenses are included in the APK.

**Device verification (2026-11-06):** source commit `b5a3b93` was pushed before
wireless installation. The existing `com.itgurujan.gulabisahar` app updated in place
on tablet `2509BRP2DI`: install Success, versionName 0.9.2, versionCode 11, launch
Status ok. A subsequent screenshot confirms the playable city and retained progress.
APK size: 176,251,126 bytes; SHA-256
`91f50251927813abdbe8090dd02202df0170f6a31a6d82f3e65311dade972592`.
APK v2/v3 signature, ZIP integrity and 16 KB alignment checks passed. The one device
capture showed 19 FPS at Chandpole; this is not a sustained performance benchmark.
Local evidence is under ignored `builds/validation-v092.json`,
`builds/tablet-install-v092.json` and `builds/previews/tablet-v092-game.png`.
Open Map → Districts → Crazy Coffee · VDN to visit the new reference storefront.
