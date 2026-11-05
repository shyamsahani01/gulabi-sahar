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
