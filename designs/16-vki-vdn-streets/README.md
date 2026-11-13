# VKI / VDN street-by-street work — 13 November 2026

## Saved evidence

Eight downloaded, visually inspected reference photographs are grouped under `references/`:

1. `01-vki-workshop-lane/`: street gates, steel warehouse frame and loading bays.
2. `02-vdn-central-spine/`: commercial facade and Vidyadhar Enclave B-11.
3. `03-vdn-sikar-commercial/`: Sun N Moon facade.
4. `04-vdn-cafe-frontage/`: terrace seating and a window counter.

See `reference-contact-sheet.jpg` and `sources.json` for exact source pages, image URLs, SHA-256 checksums and download status. These are reference photographs from area listings, **not verified photos of Road Number 5**. They informed original geometry; they are not texture assets or exported game content. Copyright remains with the sources.

Google Street View thumbnail requests returned HTTP 403. No new Google 360 capture was saved and no ordinary photo is labeled a panorama. `sources.json` retains the project's historical panorama links and the eight intended headings; their current coverage is unverified. `street-index.json` records every imported OSM way with a coordinate-derived Google Maps panorama link, original geometry and work status. A link is a survey starting point, not proof of imagery availability.

## One street at a time

**Pass 01 — VKI Road Number 5**, OSM way `374927752`: five existing building footprints around the road midpoint get a scoped workshop facade pass. Glazed upper office bands, grey frame columns, window mullions, eaves, rainwater downpipes, loading thresholds and painted forecourt markings are modeled from the reference vocabulary. Existing road and building placement remain the imported game layout. This is an artistic reconstruction, not a surveyed replica. Previews: `streets/01-vki-road-5/01-street-overview.png` and `02-workshop-frontage.png`.

The remaining streets are queued, not marked complete. Next passes: VDN Central Spine frontage, Sikar commercial facade, then cafe frontage. For each street:

1. Verify its street ID, ground location and available 360 coverage.
2. Save heading-based frontage/junction/footpath images in that street's folder with source metadata.
3. Record observable proportions, materials, entrances, signage and street furniture; separate guesses from evidence.
4. Model a short continuous section, preserving walkable road and entrance clearance.
5. Save matching in-engine views; inspect walk/drive collision, navigation and draw cost before advancing.

## Runtime previews

- `01-context-controls.png`: nearby actions and collapsed combat controls.
- `02-modern-atlas.png`: searchable map, player direction, recenter and scale.
- `03-all-wine-shops.png`: separate entries for all two wine shops currently in the game dataset.
- `04-street-selection.png`: selected road at street-level zoom.
- `05-road-5-pilot.png`: the first geographically scoped facade pass.
- `06-visible-driver.png`, `07-driver-side.png`: the actual hero seated behind the vehicle glass.

The map lists all available game amenities, services, dining destinations, districts and road segments. It does not claim a complete live business directory of Jaipur; unmapped real businesses still need verified data. Select first, then choose Show route or GO HERE. Road travel tries a clear point on the selected segment; obstructed arrivals fall back to a nearby safe road. Disconnected navigation graphs report that no connected route was found.

Reproduce downloads: `python3 tools/collect_street_references.py`.
Reproduce captures: `xvfb-run -a ./play.sh --rendering-method gl_compatibility --script tests/navigation_capture.gd`.
Reproduce behavior checks: `./play.sh --headless --script tests/map_navigation.gd`.

## Validation

`map_navigation`, `city_smoke`, `city_refresh`, `city_combat`, and `vehicle_geometry` pass with zero failures. The navigation check includes the real native GUI click path, 32x anchor zoom, all road segments, both available wine shops, clear-ground arrivals, driver attachment/rotation, restored collisions and viewport-contained travel buttons. Geometry checks cover all five vehicle families and explicitly reject a painted body slab through the driver torso.

Runtime captures use desktop OpenGL compatibility rendering. The APK is built and signed, but this version has not been installed or performance-tested on the tablet. Actual Android touch/pinch and virtual-keyboard behavior still need device validation.
