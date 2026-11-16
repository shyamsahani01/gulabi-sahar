# Sector 2 / Central Spine — street progress

Updated 15 November 2026. **Latest release 0.9.11 / code 20 includes Sector 2, Cinestar and Times Square exterior passes; installed and launched on the Redmi tablet.** These releases implement three exterior/short-section passes; entire roads and surrounding lanes remain unfinished.

## Progress by section

| Section | Actual references | Game status | Delivery |
|---|---|---|---|
| Sector 2 supplied panorama / OSM 261520097 | 52 photos; 4 distinct positions with overlapping full 360° horizontal sweeps | First section implemented on existing compact-map plots | 0.9.9 installed; GitHub push recorded in git history |
| Cinestar frontage and approach | Main camera and two approach positions; directional sweeps plus entrance/roof details | Exterior implemented; surrounding lane unfinished | 0.9.10 installed |
| Funstar / Times Square Mall frontage and approach | Main camera and two approach positions; directional sweeps plus entrance/roof details | Exterior implemented; surrounding lanes unfinished | 0.9.11 installed |
| Remaining Central Spine and side lanes | Not yet surveyed end to end | Queued | No claim of completion |

## Actual photographs

**126 photographs total: 52 Sector 2, 37 Cinestar and 37 Funstar.** Open [the local gallery](reference-gallery.html); click a photograph for the 1920×1080 original. [Primary-lane manifest](captures.json) and [cinema-area manifest](cinema-area/captures.json) retain source/resolved URLs, panorama IDs, attribution and checksums. Captures use actual headed Google Chrome on an isolated display and direct page screenshots. March 2026 imagery is visible in the reference pages. These are overlapping directional screenshots, not a stitched spherical panorama or a complete survey of all alleys.

The first section uses four panorama positions from 26.963279 to 26.9637656 (about 64 m along the street). The original camera is 26.9634146, 75.7797631. The imported OSM road is much longer; full-road completion is explicitly pending. Initial browser/thumbnail failures are retained in [sources.json](sources.json) and `evidence/` as history, not counted as reference photographs. Large Google images stay local and are ignored by Git/Android export; source manifests and capture tools are committed.

## Game implementation

`sector2_street.gd` adds a cream/rose tower with paired curved balconies, vertical fins, glazed retail podium, shop signs, an open ground-level passage, nearby shop facades, black/yellow median kerbs, Y-shaped lamps, raised wires and a small kiosk where placement is clear. Geometry is original; no Google photos are used as textures. Existing road vertices and amenity IDs are preserved. The tower is adapted to the existing Dr. Kanodia clinic placeholder: its dimensions and tenant correspondence are **not surveyed**. It is a photo-informed first pass rather than an exact building reconstruction.

In the game open the atlas, search **Sector 2**, select **Central Spine · Sector 2**, then **GO HERE**. The road label is locally authored; it is not an OSM name edit.

Actual engine renders: [tower](engine-01-tower.png), [street](engine-02-street.png), [entrance](engine-03-frontage.png). These show the shipped geometry; visual user approval and tablet FPS measurement are still pending.

## Validation and release

[Validation record](validation.json): `sector2_street`, `city_refresh` and `map_navigation` pass with zero failures. Checks cover map search, connected route, safe grounded travel, original road/amenity preservation, open central entrance and unobstructed carriageways. Android export, APK signature, 16 KB alignment and archive checks pass. Reference photos/design tools are excluded from the APK.

`builds/GulabiSahar-0.9.9-debug.apk` was installed with `adb install -r` on model 2509BRP2DI over wireless debugging. Version code 18, launcher startup and a running process were verified. Existing package/signing identity and app data were retained. Installation evidence is in `builds/tablet-install-v099.json` (local) and summarized in the committed validation record.

## Per-lane workflow

1. Verify the road and capture multiple real positions, including junctions and both ends, with overlapping 360° horizontal directions and needed facade/ground detail.
2. Inspect imagery, record source/date/coverage and distinguish visible facts from approximated geometry.
3. Model the captured section; check walking, driving, map travel and runtime views.
4. Update this README and the street index as soon as the section is ready; mark a full lane complete only after its full length is covered.
5. Test/build, push original code and docs to GitHub, and update the existing tablet app. User explicitly authorized this sequence on 15 November.

Capture tools: `tools/capture_sector2_refs.py`, `tools/capture_sector2_nearby.py`, `tools/capture_cinema_references.py`. Run with a Playwright Python environment and headed Chrome, e.g. `xvfb-run -a /tmp/gulabi-maps-browser/bin/python tools/capture_cinema_references.py`. Rebuild gallery with `python3 tools/build_sector2_gallery.py`.

## Cinestar pass — 0.9.10 / code 19

37 reference photos from three full 360° camera positions informed `cinema_frontages.gd`: circular upper openings, pale gridded facade panels, paired columns, rooftop name, side arches, storefronts and entry steps. The map now finds **Cinestar**; **GO HERE** reaches a clear connected road nearby. The original imported streets and named places remain; only overlapping generated infill was replaced. Position follows the Maps place pin with an approximately one-unit offset for clearance; footprint/height are fitted compact-map estimates. No cinema auditorium has been surveyed or fabricated.

Runtime views: [front](engine-cinestar-front.png), [approach](engine-cinestar-approach.png), [entrance](engine-cinestar-entrance.png). [Build, test and tablet evidence](validation-cinestar.json). Cinema navigation, entrance and neighboring service-lane/footway checks pass; Sector 2 regression also passes. Version 0.9.10 was installed over 0.9.9 without uninstalling the app. GitHub delivery is recorded in the corresponding commit history.

## Funstar / Times Square pass — 0.9.11 / code 20

37 inspected photos from three full 360° camera positions inform the Times Square exterior: long rose facade, repeated tall pilasters and rounded glazing, gallery railings, ground-floor shop bands and ARG/Times Square rooftop text. **Funstar** and **Times Square** both find the same destination in the atlas. The existing imported footprint (OSM 1497498145) is retained; the building height, repeated unseen elevations, simplified vestibule and individual shop-bay placement are approximated. The photographed exterior does not establish a Funstar facade sign or auditorium layout; neither was invented.

Runtime views: [front](engine-funstar-front.png), [corner approach](engine-funstar-approach.png), [entrance](engine-funstar-entrance.png). Cinema/road/doorway tests, Sector 2 regression and map/driver navigation pass with zero failures. [APK/device evidence](validation-funstar.json) records the signed APK, successful in-place wireless installation, version code 20 and running app. Full road/side-lane completion remains pending; [street progress](street-progress.json) tracks it explicitly.

Delivery follow-up, 16 November 2026: final 0.9.11 APK includes the rear shop-glazing offset correction and was installed successfully. The initial 0.9.11 tablet touch flow (Funstar search, selection and GO HERE) reached the mall and showed 30 FPS in one screenshot; this is not a sustained performance measurement.
