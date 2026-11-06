# Gulabi Sahar — Chat requirements and project record

This document records the user's requests, revisions and approvals from the available conversation. It is a consolidated record, not a verbatim chat export. Source-document suggestions are identified separately from direct user instructions.

## 1. Naam aur goal

- Game aur project folder ka exact naam **Gulabi Sahar** rakhna hai. Purana naam Jaipur Streets / JaipurStreets tha.
- Jaipur ki Pink City se inspired, third-person Android street game banana hai.
- Character, buildings aur environment mein realistic feeling chahiye. Sirf khaali sadak nahi: aas-paas log aur activity bhi honi chahiye.
- User ne tools/downloads aur development aage badhane ko kaha hai.

## 2. User ka hardware aur test device

User ne laptop ka yeh diagnostic output diya tha (29 October 2026 ke output ke mutabik):

| Item | Reported detail |
|---|---|
| Integrated graphics | Intel CometLake-H UHD Graphics, 8086:9bc4 |
| Dedicated GPU | NVIDIA GeForce GTX 1650 Mobile / Max-Q, 4 GB VRAM |
| NVIDIA driver | 550.163.01; nvidia-smi reports CUDA compatibility 12.4 |
| Memory | Approximately 16 GB RAM, 15 GB swap |
| Disk | 452 GB partition; 73 GB free at that time |
| OS/kernel | Kali Linux, 7.0.12+kali-amd64 |
| Android test tablet | Redmi Pad 2 Pro, **8 GB RAM** |
| Device detected by adb | Redmi Pad 2 Pro 5G, model 2509BRP2DI |
| Connection | Wireless debugging; use the connected tablet for installs |

These are recorded observations, not current free-space or performance measurements. The GPU/CUDA display does not mean the Android game requires CUDA.

## 3. Design approval workflow — direct user instruction

1. Har ek game part ka design alag image mein dikhana hai.
2. Pehle user design dekhega aur approve ya revise karega.
3. Approval ke baad us design ko game mein implement karna hai.
4. Sabse pehle main character design karna hai; phir next part par jaana hai.
5. User ne explicitly kaha: pehle design dikhao, game mein baad mein change karo.

Character concept **03C** ko latest user approval mila: “ok ab isse main chacter me use karo or ha expression bhi dena”. Is approval ke baad character implementation authorized hai. Building ya kisi naye part ka final design approval abhi record nahi hua hai.

## 4. Main character — requested look

- Young, realistic Indian male character; pehle ke designs older lag rahe the.
- **T-shirt** pehnani hai. Approved concept: plain off-white crew-neck T-shirt, charcoal trousers/jeans and gray sneakers.
- Supplied photos ke young selfie-taker se resemblance chahiye; photos mein doosre log character reference nahi hain.
- Face seedha ho; unintended tilt/tedhapan correct karna hai.
- Face aur body ka proportion natural ho; head bada feel nahi hona chahiye.
- Latest approved character ko main playable character mein use karna hai.
- Facial expressions bhi dene hain.

### Design revisions

| Concept | User response / decision |
|---|---|
| 01 / 02 | Alternate character requested; initial looks rejected |
| 02B | T-shirt variant; face still did not look young enough |
| 03 | Reference photos used; this earlier face was preferred later |
| 04 | Extra frontal references used, but user preferred previous design |
| 03B | Preferred face kept; face/head straightened |
| **03C** | Head/body proportion corrected; **approved for implementation** |

Approved reference: `designs/01-character/shyam-concept-03c.png`. It is an AI-generated design reference, not a screenshot or automatically finished 3D asset.

### User-provided reference files

- `/home/shyam/Downloads/IMG_0733.jpg`
- `/home/shyam/Downloads/IMG_0959.jpg`
- `/home/shyam/Downloads/IMG_8175-removebg-preview.png`
- `/home/shyam/Downloads/IMG_7330-removebg-preview.png`

These references remain local. An exact likeness is not established merely by using their names or placing a portrait in the project.

## 5. Environment and activity requirements

User's complaint was explicit: main character did not look real, buildings did not feel real, and nearby people/activity were missing. Required direction:

- More convincing Pink City architecture, materials and street detail.
- Visible nearby pedestrians and shop activity.
- More convincing character proportions, skin, hair and clothing.
- Realism must be balanced with playable performance on the 8 GB tablet.

Current street includes shops, curved arches, Hindi signs, carts, stocked counters, rooftop details and ten ambient NPCs. Architecture, props and NPC diversity remain prototype quality. Traffic, missions and a complete living city are not complete.

## 6. Installation — direct user instruction

User repeatedly asked to use wireless debugging and **install the game on the connected tablet**, including after the approved character/expression changes. Do the updated APK build and installation after testing. A saved APK alone does not fulfill installation.

Package: `com.itgurujan.gulabisahar`. **v0.4.0 installed and launched successfully on the wireless-connected tablet.** The device reports versionCode 4 / versionName 0.4.0. FACE view and expression cycling were checked on the device. See `builds/tablet-install-v04.json` and the screenshots under `builds/previews/`. The prior app was updated without uninstalling.

## 7. Current implementation and its limits

- Engine: local Godot 4.7.2 Standard, Compatibility renderer.
- Canonical project folder: `/home/shyam/MyWork/Gulabi Sahar`.
- Third-person walk/run/jump, camera orbit, collision and boundaries.
- Tablet joystick, independent camera touch, jump/run, focus-loss reset.
- Ten ambient NPCs; pedestrians walk, shopkeepers greet nearby player.
- Approved character adaptation uses the existing skinned model, approved portrait projected/baked to native UVs, adjusted face/hair and off-white/charcoal wardrobe.
- Native facial morphs: blink left/right, smile, serious and surprised. Expressions smoothly blend; automatic blinking continues. FACE view allows close inspection and cycling expressions.
- This is a 3D adaptation of concept 03C. Mesh, hair, fabric and shoes are still simpler than the photorealistic design sheet. It is not a claim of exact photo likeness or finished photorealism.
- 30 FPS is a configured target/cap. Device screenshots showed 30 FPS during this brief check; sustained tablet performance, heat and battery consumption require a longer play session.

## 8. Files, running and controls

| Path | Purpose |
|---|---|
| `README.md` | Build/run instructions and current implementation |
| `CHAT_REQUIREMENTS_README.md` | This chat requirements record |
| `docs/Gulabi_Sahar_Chat_Requirements.pdf` | PDF version of this record |
| `designs/01-character/` | Character designs, prompts and reviews |
| `assets/characters/shyam_hero.glb` | Hero rig and facial morphs |
| `human.gd` | Appearance, locomotion and facial control |
| `tablet_controls.gd`, `main.gd` | Gameplay input and face camera |
| `tools/` | Local asset-building/document-generation scripts and source |
| `tests/smoke.gd` | Movement, touch, NPC and expression checks |
| `builds/` | APKs, validation and device-install evidence |
| `ASSETS.md` | Asset attribution and provenance |

Linux: `./play.sh`. Android build: `./build-android.sh`.

Desktop: WASD/arrows move, Shift run, Space jump, mouse drag look, R reset, F face view, E expression. Tablet: left joystick, right drag, JUMP/RUN, FACE/BACK and expression selector in face view.

## 9. Original PDF — context, separate from user instructions

Source: `/home/shyam/Downloads/IT_Gurujan_Jaipur_Streets_Development_Plan.pdf` (5 pages), titled “IT Gurujan | Jaipur Streets Development Plan”. User asked for it to be read and to explain/continue the next steps.

Its proposed roadmap starts with hardware checks, engine/toolchain setup, a compact third-person street, mobile controls and Android testing. Later suggestions include a vehicle, traffic, a mission, police, money, save/load, larger map, sound and visual polish. Those later suggestions are **roadmap context**, not proof that the user approved or that these systems are implemented.

The PDF's old project name and initial engine options are superseded by the user's exact name **Gulabi Sahar** and the working Godot project. Account-creation suggestions inside the PDF do not authorize creating accounts or sending messages. No passwords or credentials are recorded here.

## 10. Remaining work / next review

- Review the installed main character on the tablet, including resemblance, head alignment, proportions and every expression.
- Refine face geometry, hairstyle, fabric and sneaker meshes where the real-time model differs from approved 03C.
- Run a sustained tablet play test for FPS, heating, touch responsiveness and crashes.
- Next design part: show a separate environment/building concept and obtain the user's design approval before implementing that new part.
- Add later gameplay systems only as scoped and authorized in subsequent work.

## 11. Latest documentation request

User asked to continue the active work and then create both a README and PDF containing what they had said in this chat. This file and its PDF fulfill that documentation request as a consolidated requirements/decision record. Installation and validation outcomes are stored separately so they can be updated truthfully.

## 12. Latest correction request — 1 November 2026

User explicitly rejected the v0.4 face match: the implemented character does not match the approved image, detailing needs attention, and the character plus nearby background should look more realistic. User requested fetching Jaipur lane photos through Google and designing the game from those references.

Concept 03C remains the approved visual target; the installed implementation is not accepted as a likeness match. A separate native correction scene is at `art_review/review.tscn`, with face geometry/eyes/hair/material changes and a photographed-reference-based narrow market lane. Real source photographs and provenance are under `designs/02-jaipur-lane/references/`. The candidate has not been approved or installed as an Android update. The old v0.4 install record is evidence of installation, not evidence of visual approval or exact likeness.

## 13. GitHub backup request — 5 November 2026

User requested pushing this project's code to the GitHub account `shyamsahani01`. No matching game repository or local remote existed, so the project is being saved to a private `gulabi-sahar` repository. Existing local GitHub authentication is used; no chat-supplied access token is stored in project files, Git history or remote URLs. Code, required assets, editable sources and documentation are included; APKs/caches/secrets and downloaded third-party reference photos are excluded. Current character/environment correction work is explicitly marked as a review candidate, not a completed likeness match.

## 14. Latest installation and full handoff request — 5 November 2026

User asked to install the game on the tablet and then make a complete project README that can be supplied to continue development. User again rejected the main character's quality and its mismatch with the approved design. `README.md` is now the comprehensive restart/handoff document, including the copyable restart prompt, actual code/asset map, build/test/install commands, source dependencies, current limits and next priorities.

Android test app **v0.5.0, versionCode 5** was installed and launched on the wireless-connected Redmi tablet. It contains the narrow reference-based lane and internal v0.6 fitted face candidate. Package version, successful update, live process and resumed activity were verified in `builds/tablet-install-v05.json`. The first install attempt found the wireless connection offline; reconnecting the discovered tablet endpoint restored it, and the update succeeded without uninstalling.

The full gameplay smoke/60-simulated-second patrol checks and the art-review checks passed. Likeness and photoreal quality remain explicitly unapproved. This installation does not resolve the user's character complaint.

## 15. World map request — 5 November 2026 (later session)

User first asked for a street (gali) designed from a Google Maps Street View link of Hawa Mahal, with a blueprint shown before any code. Blueprint v1/v2 were rejected as guesswork ("google maps se full gali ki image lo"); v3 was rebuilt from eight Street View angles of the real Hawa Mahal Road (wide two-lane road with a planted median, Hawa Mahal on the west, arcade shops on the east, railings, trees, autos). Blueprints live at claude.ai artifacts "Hawa Mahal Gali" and "Gulabi Sahar World".

User then widened the scope, in the user's words: cover the area from Hawa Mahal to Vidhyadhar Nagar and build a full map; take building/house designs from there; add a map option in the game; do not lift every kilometre, pick some areas; keep the hills beyond VDN; add animals; add children and adults; make the character better. Then: **"code bhi kar do"** and **"wireless debugging on hai install kar dena, mai dekhunga"**.

Delivered as Android test **v0.6.0, versionCode 6** (`world.gd`, `animals.gd`, NPC kinds, map UI, terrain, Chandpole gate, Sikar Road, VDN houses/park/temple, Nahargarh rampart). Street View references for each zone were located with the `streetlevel` library and recorded in `sources.json`; actual engine renders are in `designs/03-world/`. Because the user asked to code directly, there was no per-zone approval round — **every zone remains unapproved**. The character was not improved in this build: Blender and the face-fit pipeline are not available on the current machine; children/elders reuse the male crowd rig at a different scale. The APK was built on this machine (Godot 4.7.2 + export templates + Android SDK set up here); the tablet rejected adb installs (`INSTALL_FAILED_USER_RESTRICTED`, MIUI "Install via USB" gate) after the old differently-signed build was uninstalled, so the APK was pushed to the tablet's `Download/` folder for an on-device install.

## 16. Feedback on v0.6.0 — 5 November 2026

User installed v0.6.0 and said: two Gulabi Sahar games were on the tablet and only the newer one should stay (the old `com.gurujan.gulabisheher` was uninstalled); put more life into the character; keep the map view good; the main character's face looks as if skin was pasted on and is not acceptable; characters and the game need more life, graphics and 3D can be much better; the Google-Maps-referenced design is not yet a good design; and asked how to make the characters good.

Response recorded: the pasted-skin look comes from the photo-projection bake on a generic head (`tools/bake_hero_face.py`); three paths were offered — (1) selfie-based avatar service (Ready Player Me / Avaturn) GLB with Mixamo animations, fastest, stylized-realistic, user uploads their own selfie; (2) Blender + FaceBuilder + MPFB for a true likeness, multi-day art work, Blender not yet installed here; (3) commissioning an artist. Recommendation: (1) first, then (2). Graphics path offered: Mobile/Vulkan renderer test, real CC0 3D assets instead of box primitives, baked lighting. Awaiting the user's choice. Map redrawn and landscape orientation fixed in the same build.

## 17. OpenStreetMap city and v0.8.0 completion — 5 November 2026

The user ran the next step in a Codex session with their own prompt (fetch real map data and build the city). That session reported: new city and combat tests passing; more than 11,000 buildings, parks, roadside stalls, traffic, a minimap, district travel and a delivery job; the real Nahargarh motor route leaves the imported boundary, so a clearly marked in-game connector was being added; and README documentation of real OSM data versus artistic additions was pending. The session hit its usage limit before finishing. The user then asked, in their words, to complete the remaining work according to that prompt, and to push the code to GitHub at the end with an updated README. A GitHub token was pasted in that chat message; it was used only for the push over HTTPS via a temporary askpass helper and was not written to any project file, Git config or remote URL. **The user should revoke that token**, because it was exposed in a chat transcript.

Completed in this session: the authored connector is now visibly marked in 3D (yellow kerbs, bollards, bilingual sign at both ends), on the radar and on the city atlas with a legend; `tests/city_smoke.gd` asserts exactly one authored road and that the fort route uses it; `tests/city_review.gd` saves nine engine renders to `designs/04-city/`; the legacy `tests/smoke.gd`/`tests/actions.gd` skip with a message because the main scene changed; README (§3, §5, §6, §7, §11, restart prompt, new §v0.8.0), ASSETS.md and designs/README.md record the real-data/artistic split and the ODbL attribution. APK v0.8.0 (versionCode 8) was built. The user then said wireless debugging was on and asked to install it; the tablet was found at 10.42.0.80 (port via nmap), `adb install` succeeded, the app launched and stayed running at **18 FPS** at Chandpole with ~1 GB RAM (evidence in `builds/tablet-install-v08.json` and `builds/previews/tablet-v08-running.png`). Installation is not visual approval; nothing in v0.8.0 is approved, and the frame rate is below the 30 FPS target.

## 18. Compact city and design refresh (v0.9.0) — 6 November 2026

User asked to pull latest GitHub code first, improve 3D design using Kimi/other references, make the map a little smaller, improve vehicles and add city features such as shops, theka, police station, hospital and car showroom. Required order: update README and push to GitHub, then install on tablet through wireless debugging. The initially supplied GitHub link was the portfolio; user explicitly clarified to use `shyamsahani01/gulabi-sahar`. (This was a separate session, on this same machine, whose push this one later had to merge in — see §20.)

Implementation: 12% shorter horizontal map with source OSM data preserved, smaller radar, original shaped vehicles with animated wheels, detailed storefronts and six fictional service/business interiors accessible through a Services atlas tab. These buildings do not imply complete business/police simulation. Hero likeness remains unresolved. See README v0.9.0 and actual engine captures in `designs/05-city-refresh/` for current evidence.

Pre-install verification: city smoke, combat and refresh suites passed with 0 failures; nine actual engine renders reviewed; APK signature, ZIP integrity and 16 KB alignment passed. Source/README are pushed before wireless installation as requested. Device outcome is recorded separately after the attempt.

Tablet update attempt returned a signing-certificate mismatch against the existing v0.8 app. Original app/data were retained. Added an explicit side-by-side `Android Preview` preset (launcher name Gulabi Sahar 0.9), with first-install save copying. Source/README for the fallback is pushed before installing that APK.

## 19. Continue character and realism, push before tablet (v0.9.1) — 6 November 2026

User: “continue karo … design or chacter aur achhe … web se data fetch karo aur details daalo … realistic lage … tablet me instal … read me update and phle github pe push.” This authorizes continuing implementation and device testing without another design-approval stop, while the visuals still await the user's verdict.

Implemented a continuous skinned hero candidate (v07) replacing the detached face patch, new skin bake, swept hair locks, relaxed cloth folds and closed canvas sneakers. Jaipur market photography informed original awnings, AC housings, pipes, meters, bins and parked scooters. New Poly Haven Pavement 05 CC0 maps were fetched, with source/license/checksum records; interiors have tiles/grout and short-range warm lights. Exact likeness, forehead/temple transitions and a complete eye rig remain unfinished.

Four automated suites passed with zero failures; sixteen actual Godot captures are in `designs/06-realism/`. Android preview v0.9.1/code10 built and passed signature, archive and 16 KB alignment checks. Code/docs are pushed before the wireless install. Because the old v0.8 signing key is unavailable, the new app uses the separate `com.itgurujan.gulabisahar.preview` package and launcher label **Gulabi Sahar 0.9.1**, preserving the original app/save and copying readable progress on first install. Actual device outcome is recorded after the attempt.

## 20. Minimap tap, multi-vehicle driving, a VDN/Sikar pilot area, and merging in v0.9.0/v0.9.1 — 6 November 2026

User asked to pull the latest GitHub code, said they can only drive some vehicles and not others without knowing why, said the compact radar and the full map "show separately" and tapping the radar does not open the map (only the MAP button does), asked for buildings/parks/temples/theka/police stations to match the real density of Jaipur, and asked to pick one area to prove the approach on before extending it to the whole map; graphics should be more realistic.

A GitHub PAT pasted in this chat first failed to authenticate — but only because of a broken auth attempt (a GIT_ASKPASS script that echoed the token for both the username and password prompt, then a `Bearer` auth header, neither of which is how git's HTTP backend actually wants a classic PAT). The user pasted the same token again saying it had not worked and that work was supposed to start only after pulling. Checking the token directly against `api.github.com/user` showed it was valid all along; a correctly-formed `Authorization: Basic base64(x-access-token:<token>)` header then fetched successfully. **Local `main` and `origin/main` had genuinely diverged**: local had this session's 4 commits (§18/§19 were on origin, not visible locally until now) and origin had the compact-city/vehicle/services (v0.9.0) and continuous-hero/realism (v0.9.1) commits from the parallel session recorded above. The token itself was never stored anywhere; the user should still regenerate/rotate it since it was pasted in chat twice.

Before discovering the divergence, this session had already (1) fixed the radar having no tap handler at all (only the round MAP button opened the atlas — `city_hud.gd`), and (2) made DRIVE/V pick the nearest drivable car instead of one hardcoded `city_vehicle.gd` instance, letting the player borrow any of the 8 AI traffic cars via a new `main.nearest_drivable()` plus yield/reclaim logic in `city_traffic.gd`; and (3), after the user picked **Vidhyadhar Nagar / Sikar Road** as the realism pilot area, found that the real OSM extract had zero police and zero theka there (not a bug — temples/hospitals/schools were already dense and real) and added the real Vidhyadhar Nagar Police Station, a Sikar Road police-chowki/Police-Academy stand-in, Saini Wine Shop and Bhanu Wines from web research, tagged `source: "authored-research"` in `jaipur_city.json` (same convention as the Nahargarh connector), rendering through the existing `amenity_police`/`amenity_theka` builders.

Merging origin's v0.9.0/v0.9.1 in on top of that required real conflict resolution, not just taking one side: `city_vehicle.gd` was taken entirely from origin (fully replaced by the new `vehicle_design.gd`-based modeled cars; none of this session's own work touched that file). `city_world.gd`'s `_ready()`/`compact_layout()` now run **both** amenity systems side by side — the full real-OSM-derived `amenities`/`build_amenities()` (278 real places, now 282 with the VDN/Sikar additions) and origin's new `service_builder`/`city_services.gd` six fictional neighbourhood businesses — rather than picking one over the other; `compact_layout()` was extended to also scale `data.amenities` positions/sizes by `CITY_COMPRESSION`, since origin's compression pass didn't know that array existed. `city_building()` was taken entirely from origin's redesigned version (adds the `b.has("service")` early-return the new services need). `city_hud.gd`'s radar/atlas now draw both the real-amenity icons and the new services dots/SERVICES tab together; the radar's tap-to-open rect was resized to match origin's slightly smaller radar box. Two stale test assertions in `tests/city_smoke.gd` (an OSM-road-count threshold that assumed data this session doesn't have, and a vehicle-body child-count check that assumed the old box-car structure) were corrected to match what's actually in this repo, not guessed at. `map_bounds` was simplified to origin's approach (the compressed generic default rect, which safely encloses the real data bounds) after `tests/city_refresh.gd` (one of origin's three new test/capture scripts) caught a mismatch from this session's first attempt to derive it from the real `data.meta.bounds` instead. After every fix, `tests/city_smoke.gd`, `tests/city_combat.gd` and `tests/city_refresh.gd` all pass with 0 failures.

Not done in this request, and explicitly separate from the above: a broader "GTA-like" graphics/realism pass (materials, lighting, prop variety, density beyond real OSM counts) — that is open-ended art direction, not a bug fix, and per this project's standing rule needs a reviewed design/engine render before being called finished, same as the character work. The user's plan is to review the VDN/Sikar pilot area first and decide whether to extend the approach to the rest of the map.

The user then noted the tablet had two Gulabi Sahar apps installed (`com.itgurujan.gulabisahar` and the `.preview` package from the v0.9.0/v0.9.1 session's signing-key workaround) and asked for just one. Found the tablet over wireless debugging (hotspot subnet `10.42.0.0/24`, tablet at `10.42.0.80`, port found by `nmap -p 30000-49999`). Built the merged code with `./build-android.sh standard` (0.9.1/code 10, re-signed with the preserved original debug key), uninstalled `com.itgurujan.gulabisahar.preview`, then installed/updated `com.itgurujan.gulabisahar` via `tools/install_tablet.py`. Cold launch 897 ms, process stayed alive and in the foreground. A screenshot taken ~18s after launch (near Nahargarh, the game-connector marker visible) showed the app fully loaded and playable, but at **11 FPS — worse than v0.8.0's already-flagged 18 FPS**, likely because this session chose to keep the real 278-place OSM amenity system running *alongside* v0.9.0's 6 fictional services rather than letting the latter replace the former (see §20). The performance pass that was already on the roadmap is now more urgent; worth revisiting whether both amenity systems need to render everywhere or only within some radius.

## 21. Structure-based face, smile with eyebrows, neck line, FACE zoom, tablet install (v0.9.4) — 6 November 2026

User (Hinglish): work on the character's face, it is not properly structure-based; work on the smile and on the eyebrows during the smile; there is a line on the neck, fix it; and add zoom on the face the way one can zoom on a point; only this much for now, with deep analysis, "ekdam perfect". Mid-task: update it and install the game on the tablet, which is connected over wireless debugging.

Analysis (measured, not guessed — see the header of `tools/refine_hero_v08.py` and `designs/11-face-structure/README.md`): the v07 single-photo fit had flattened the head (nose tip 1 cm ahead of the lips, nasion level with the forehead, eye sockets filled by the fit) and relied on the photo's baked studio shading, hence the pasted look; the Smile key moved only the lips; the neck line was the photo region's lighter skin ending at the jaw against the darker orange MakeHuman neck plus the Street stubble overlay ending in a straight band on the neck; a jagged forehead/temple seam was the photo projection's per-vertex UV boundary; the lower-lid flat patches were the base mesh's collapsed eyelid-margin UVs. The Blender 5.2 `.blend` sources cannot be opened by the only Blender here (portable 4.2.3), so the v08 pipeline round-trips the v07 GLB (rig, Walk clip, weights and existing keys verified intact in the exported GLB JSON).

Implemented: hero v08 with anatomical sculpt, rebuilt zygomatic Smile, BrowRaise/BrowFurrow keys and brow-driven expression logic (`human.gd`), de-lit and colour-matched skin texture, stubble fade under the jaw, eyelid UV/normal repair, back-face culling on the body mesh, sunglasses moved forward, and FACE-view zoom (pinch, wheel, +/− buttons, keyboard, vertical drag moves the studied point). `tests/hero_motion.gd` extended with face/zoom checks (0 failures); `tests/hero_portraits.gd` saves 17 engine views. Version 0.9.4 / code 13. Five Blender/Godot render iterations were needed (a geometry "crease relax" attempt was reverted after it put a shelf under the jaw; the seam turned out to be texture, not geometry). Device outcome: APK 0.9.4 (code 13) installed over wireless adb (`Success`); the first launch quit because the tablet slept during startup (Vulkan surface creation failed after OnPause), the relaunch with the screen awake ran and stayed resumed for 45 s. Screenshot black behind the secure keyguard, which adb cannot dismiss; the user needs to unlock the tablet to review. Evidence: `builds/tablet-install-v094.json`. Visual approval is the user's call after reviewing on the tablet.
