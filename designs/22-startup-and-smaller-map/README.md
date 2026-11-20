# Smaller playable map, startup loader and place interactions — 0.9.14

20 November 2026. The user clarified that the **playable area** should shrink while graphics continue improving. This pass changes the boundary, preserves object scale, exposes startup progress, and adds usable campus/reception/park locations.

## What changed

- Playable area **4.15272 → 2.89432 game km²**, a **30.303% reduction**. The narrower VKI–VDN corridor keeps the five district destinations and Cinestar/Funstar, extends south to the imported education area, and removes outer neighbourhoods. The existing runtime scale remains 0.88. Source datasets are retained. See [scope and removed locations](map-scope.json); regenerate with `python3 tools/build_small_city.py`.
- 1,528 source road polylines, 2,509 building records, 65 source amenities and seven park polygons. Runtime adds the two cinema destinations. Five education names share three campus shells: overlapping Biyani point records remain searchable without stacking duplicate buildings. Place names are archived OSM data, not fresh tenancy verification.
- `startup.tscn` paints a lightweight overlay before threaded resource loading. Progress then follows actual city construction stages. Construction yields between batches; player, NPC and traffic processing stay disabled until the world is ready. The first rendered world frames remain covered. Resource failure shows a retry button. Percentages are weighted work stages, not a time estimate.
- A spatial grid replaces full-city obstacle/road scans for arrival and verge checks; exact geometry checks still decide clearance. Flat terrain uses two-triangle patches instead of needless dense grids. No graphics setting was reduced to obtain the smaller map.
- Shared plaster, concrete, asphalt, masonry and ground materials retain restrained normal/roughness detail, metre-scale tiling and mipmaps. The old grass asset is a **plant atlas**, unsuitable as a tiled lawn; ground grass now reuses the existing CC0 scrubland surface with an appropriate tint. No Google image pixels are game textures.
- Three campus shells have central gates, open courtyards, reception corridors, separate framed windows/shades, planters and usable benches. This architecture is game-authored, not a surveyed reconstruction of these institutions.
- At a hospital reception, **VISIT → First aid** restores health/stamina for Rs 25; full health and insufficient funds do not charge. Campus reception supports a walk-up check-in. Place panels lock movement and close cleanly. Campus visit records currently last for the session.
- Parks have registered usable seats; the atlas now has cinema, school/college and park filters/search aliases. The map-edition migration retains cash/outfit and resets old location indices and delivery progress safely.

## Review

[Loader: resources](loading-resources.png) · [Loader: city](loading-city.png) · [Playable view](first-playable-view.png) · [Campus](college-courtyard.png)

The pre-change headless laptop profile measured resource loading **978 ms**, synchronous scene construction **14,691 ms**, and first population **728 ms**. An initial optimized profile measured **856 / 9,366 / 846 ms** respectively. These are individual development measurements, not tablet FPS or guaranteed startup times. [Rendered startup profile](startup-profile.json) includes yielding, rendering and initial shader work, so its total is not directly comparable to the headless construction number.

Validation: spatial index versus 4,000 brute-force queries; compact bounds/navigation/save migration; startup progress/handover/failure UI/grounding; campus gate/reception clearance; paid hospital care and insufficient-funds handling; park sitting; atlas and driving; existing city and cinema regressions. Final results and device delivery are recorded in `validation.json` and `tablet-delivery.json` when completed. The missing-resource startup test intentionally emits resource-load errors while verifying the retry UI. Godot reports existing ObjectDB shutdown warnings; no claim is made that all resource leaks are resolved.

## Tablet delivery — 20 November

**0.9.14 / versionCode 23 installed in place and launched over wireless ADB** on the Redmi 2509BRP2DI. The existing package/signing identity was retained. APK archive, signature and alignment checks passed. Loader and gameplay were visually verified with the tablet unlocked; the game remained the foreground activity.

[Tablet loader](tablet-loading.png) · [Tablet gameplay](tablet-gameplay.png) · [Delivery evidence](tablet-delivery.json) · [Regression results](validation.json)

The first device launch after installation took **59.646 seconds from loader start to handover** (1.930 seconds resource loading). Neighbourhood construction took 13.363 seconds and places to visit 14.538 seconds; subsequent character/vehicle/resident work and first rendering also contribute. The loader fixes the blank/frozen presentation, but startup is **still long**. These measurements do not establish a tablet startup speedup or gameplay FPS. Spatial optimization is a start; loading only the nearby world first is still needed.

Remote `def6e2a` was merged, preserving the asphalt/concrete PBR restoration and its pavement texture selection; relief/roughness were tuned with the broader material pass. Source, original authored assets, tests and review documentation are included; Google reference pixels, APK binaries and device identifiers/network addresses are kept out of the repository delivery.

## Realistic graphics: remaining work

This is **not GTA-level or a finished photoreal map**. Generic background buildings and rounded placeholder vegetation remain. Cinemas retain accessible entrance vestibules; ticket purchase, screenings and surveyed auditoriums are not implemented. Teaching rooms and hospital wards are not complete interiors. The detailed Cinestar Blender/GLB candidate in [pack 21](../21-cinestar-model-study/README.md) is still isolated from the playable world.

Next art work should replace the common building/vegetation kit across the compact area, use distinct silhouette and facade depth with consistent PBR materials, and integrate detailed landmarks with collision and LODs. Near-area asset streaming and device GPU/frame-time profiling are needed as density grows. Every art pass should include actual gameplay captures and on-device checks; a good standalone render does not establish whole-game realism.
