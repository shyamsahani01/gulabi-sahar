# Crazy Cafe rebuild and hero body motion — 2026-11-06 (app 0.9.3)

Reference: the user's two generated screenshots of a "Crazy Cafe" (street facade and the
interior seen from the door). They are the visual target for `cafe_reference.gd`; the
earlier "Crazy Coffee" template (08-cafe-hospital) is replaced.

Actual engine renders (`tests/cafe_capture.gd`, 1280×800, Compatibility renderer):

| File | What it shows |
|---|---|
| `01-exterior-street.png` | Rust-plaster upper storey, two shuttered walnut windows, cup mark, black fascia with CRAZY CAFE and the framed plaque, full-height black-framed glazing, lit stone steps, white planters, lamp-post banner |
| `02-exterior-terrace.png` | Fenced turf terrace, round wooden table, white wire chairs, plants |
| `03-interior-from-door.png` | Grey microcement walls, chestnut planks, ceiling spots, COFFEE lettering and coffee-plant mural, chalkboard menu, AC, wall counter with cane stools, cane booths, back-wall sign and neon script |
| `04-interior-left-wall.png` | Counter, stools, chalkboard menu, seated guest, palms |
| `05-interior-booths.png` | Cane feature panel, cone sconces, three booths with grey cushions, walnut tables, flowers, menu cards |
| `06-counter-through-glass.png` | Second bay: slatted counter, quartz top, pastry case, espresso machine, pendant lamps, shelves, barista, street-facing chalkboard |
| `07-hero-seated-booth.png` | Player sitting on a booth chair (SIT button / G): hips on the seat, feet on the floor, hands on thighs |
| `08-talking-game-camera.png` | Conversation framing: over-the-shoulder camera, speech line and choices, guest keeps sitting, hero's head tracks the partner |
| `09-hero-speaking.png` | Hero gesturing while a chosen line is spoken |
| `10-jump-airborne.png` / `11-jump-landing.png` | Jump dip → launch → tucked airborne loop → knee-bend landing (hard landing from height has a longer recovery) |
| `12-cafe-street-hud.png` | HUD with the new SIT action |

What is modeled vs. inferred: dimensions, exact furniture counts and colours are inferred
from the two screenshots; the menu prices are in rupees instead of the dollar prices in
the reference. All seven mapped café locations share this template with their own names.
Nothing here is visually approved yet; review against the two reference images.

Validation: `tests/hero_motion.gd` (46 checks), `tests/cafe_review.gd`, `tests/city_smoke.gd`,
`tests/city_combat.gd`, `tests/city_refresh.gd` all pass with 0 failures.

```sh
./play.sh --headless --fixed-fps 60 --script res://tests/hero_motion.gd
xvfb-run -a -s '-screen 0 1280x800x24' ./play.sh --fixed-fps 60 --script res://tests/cafe_capture.gd
./build-android.sh && python3 tools/install_tablet.py
```
