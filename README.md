# OpenSCAD_hinge

Parametric hinge library, plain OpenSCAD (no `BOSL2`, no third-party `include`s), for boxes,
lids, and wooden doors/cabinets. Loadable standalone in real OpenSCAD and by
[OpenSCAD-gui](../OpenSCAD-gui) (a custom JS OpenSCAD engine that resolves `include`/`use`
against its own drag-drop file provider and does not bundle BOSL2).

All modules live in `hinge_library.scad`. Each hinge type has a demo file under `examples/`
and a rendered preview under `renders/`.

## Usage

```openscad
include <hinge_library.scad>

knuckle_hinge(leaf_length=40, leaf_width=15, leaf_thickness=3, knuckle_od=6, knuckle_count=5);
```

Hinge axis convention: the barrel/knuckle axis runs along **Y** at x=0, z=knuckle radius, so
the closed hinge sits flat on the **Z=0** plane (printable as-is, barrel resting on the bed).
Leaf 1 occupies X<0, leaf 2 occupies X≥0, and the two leaves are separate solids with print
clearances, so each can be positioned/unioned directly onto its mating part. Units are mm.

---

## knuckle_hinge — print-in-place box lid hinge

Interleaved barrel knuckles across two leaves. By default the pin is integral to leaf 1 (its
knuckles are solid with the pin) and leaf 2's knuckles are bored with radial clearance, so the
part prints in place and articulates with no assembly. Set `integral_pin=false` for a
bored-both-sides hinge with an optional separately printed pin.

![knuckle_hinge render](renders/knuckle_hinge.png)
![knuckle_hinge schematic](schematics/knuckle_hinge_schematic.png)

**[▶ Open in SCAD Studio](https://lizard-spock.co.uk/openscad-gui/?github=morganp/OpenSCAD_hinge/examples/knuckle_hinge_demo.scad)** — view this demo in the browser, no install.

| Parameter | Default | Meaning |
|---|---|---|
| `leaf_length` | 40 | Hinge length along the axis (Y) |
| `leaf_width` | 15 | Depth of each leaf plate (X), per leaf |
| `leaf_thickness` | 3 | Leaf plate thickness (Z) |
| `knuckle_od` | 6 | Knuckle/barrel outer diameter |
| `knuckle_count` | 5 | Number of knuckles across both leaves (odd = pin captive at both ends) |
| `pin_d` | 0 | Pin diameter; 0 = auto (`knuckle_od / 2`) |
| `pin_clearance` | 0.25 | Radial clearance between pin and knuckle bore |
| `knuckle_gap` | 0.3 | Axial clearance between adjacent knuckles, and leaf-to-barrel gap |
| `integral_pin` | true | Pin fused to leaf 1's knuckles (print-in-place, no assembly) |
| `print_pin` | false | With `integral_pin=false`: emit a loose pin beside the hinge |
| `parts` | "both" | `"both"` / `"leaf1"` / `"leaf2"`: emit one leaf only, for fusing each leaf onto a different mating part |
| `fn` | 48 | `$fn`-style circle resolution for knuckles and pin |

---

## piano_hinge — continuous knuckle hinge, cut to any length

Same knuckle geometry as `knuckle_hinge`, but knuckle count is derived from `length` and a
target `knuckle_pitch`, for long lids needing even load distribution.

![piano_hinge render](renders/piano_hinge.png)
![piano_hinge schematic](schematics/piano_hinge_schematic.png)

**[▶ Open in SCAD Studio](https://lizard-spock.co.uk/openscad-gui/?github=morganp/OpenSCAD_hinge/examples/piano_hinge_demo.scad)** — view this demo in the browser, no install.

| Parameter | Default | Meaning |
|---|---|---|
| `length` | 100 | Total hinge length along the axis |
| `leaf_width` | 12 | Depth of each leaf plate |
| `leaf_thickness` | 2 | Leaf plate thickness |
| `knuckle_od` | 5 | Knuckle outer diameter |
| `knuckle_pitch` | 8 | Target spacing between knuckle centers — knuckle count derived from `length / knuckle_pitch`, rounded up to odd, not set directly |
| `pin_d` | 0 | Pin diameter; 0 = auto |
| `pin_clearance` | 0.25 | Radial clearance between pin and bore |
| `knuckle_gap` | 0.3 | Axial knuckle clearance and leaf-to-barrel gap |
| `integral_pin` | true | Print-in-place pin fused to leaf 1 |
| `print_pin` | false | With `integral_pin=false`: emit a loose pin beside the hinge |
| `parts` | "both" | `"both"` / `"leaf1"` / `"leaf2"`: emit one leaf only, for fusing each leaf onto a different mating part |
| `fn` | 32 | Circle resolution |

---

## living_hinge — flexible groove-cut strip hinge

Thin-wall, print-in-place fold hinge: parallel relief grooves alternate between the top and
bottom faces, each leaving a `web_thickness` web, so the strip flexes without a pin or
assembly.

![living_hinge render](renders/living_hinge.png)
![living_hinge schematic](schematics/living_hinge_schematic.png)

**[▶ Open in SCAD Studio](https://lizard-spock.co.uk/openscad-gui/?github=morganp/OpenSCAD_hinge/examples/living_hinge_demo.scad)** — view this demo in the browser, no install.

| Parameter | Default | Meaning |
|---|---|---|
| `width` | 40 | Extent along the hinge axis (Y) |
| `length` | 10 | Extent across the fold direction (X) |
| `thickness` | 2 | Parent wall thickness either side of the hinge |
| `web_thickness` | 0.6 | Thickness of the flexible web left after each groove cut |
| `groove_count` | 3 | Number of parallel relief grooves |
| `groove_width` | 1.2 | Width of each groove cut |

---

## door_butt_hinge — traditional mortise-plate hinge for wooden doors/cabinets

Hardware-pattern butt hinge: flat leaves, a knuckle barrel (built on `knuckle_hinge` with
`integral_pin=false`, both sides bored), a loose pin printed beside the hinge, and countersunk
screw holes down each leaf centerline. Model to spec for routing a mortise, or print directly
in a rigid filament.

![door_butt_hinge render](renders/door_butt_hinge.png)
![door_butt_hinge schematic](schematics/door_butt_hinge_schematic.png)

**[▶ Open in SCAD Studio](https://lizard-spock.co.uk/openscad-gui/?github=morganp/OpenSCAD_hinge/examples/door_butt_hinge_demo.scad)** — view this demo in the browser, no install.

| Parameter | Default | Meaning |
|---|---|---|
| `leaf_length` | 76 | Hinge length (e.g. 76mm ≈ a 3" hinge) |
| `leaf_width` | 28 | Depth of each leaf plate |
| `leaf_thickness` | 2.5 | Leaf plate thickness |
| `knuckle_od` | 8 | Knuckle outer diameter |
| `knuckle_count` | 5 | Number of knuckles |
| `screw_hole_d` | 3.5 | Screw through-hole diameter |
| `screw_csk_d` | 6.5 | Countersink diameter |
| `screw_csk_depth` | 1.5 | Countersink funnel depth |
| `screws_per_leaf` | 4 | Screw holes per leaf, evenly spaced down the centerline |
| `pin_d` | 0 | Pin diameter; 0 = auto |
| `pin_clearance` | 0.3 | Radial clearance between pin and bore |
| `knuckle_gap` | 0.3 | Axial knuckle clearance and leaf-to-barrel gap |
| `print_pin` | true | Emit the loose pin beside the hinge |
| `fn` | 48 | Circle resolution |

---

## snap_lid_hinge — pin-less friction/snap hinge for box lids

A thinned flex web flush with the top surface (so the lid folds up and over the top edge),
plus an over-center detent bump under the web, so a lid snaps open/closed without a pin or
any assembly step.

![snap_lid_hinge render](renders/snap_lid_hinge.png)
![snap_lid_hinge schematic](schematics/snap_lid_hinge_schematic.png)

**[▶ Open in SCAD Studio](https://lizard-spock.co.uk/openscad-gui/?github=morganp/OpenSCAD_hinge/examples/snap_lid_hinge_demo.scad)** — view this demo in the browser, no install.

| Parameter | Default | Meaning |
|---|---|---|
| `width` | 30 | Extrusion depth along the hinge axis |
| `box_leaf_len` | 8 | Leaf length printed/glued into the box wall |
| `lid_leaf_len` | 8 | Leaf length printed/glued into the lid wall |
| `leaf_thickness` | 3 | Leaf thickness |
| `web_length` | 3 | Flex web length between the two leaves |
| `web_thickness` | 0.8 | Flex web thickness |
| `bump_r` | 0.6 | Over-center detent bump radius, gives the snap feel |

---

## removable_hinge — lift-off hinge, door removes without tools

Loose-joint hinge in two fully separable leaves, the pattern used for printer-enclosure and
cabinet doors that must come off without tools. Leaf 1 carries the lower barrel half with an
integral pin pointing up the axis; leaf 2 carries the upper barrel half with a blind bore open
at its lower end, so the door drops on and lifts straight off. Countersunk screw holes down
each leaf centerline.

![removable_hinge render](renders/removable_hinge.png)
![removable_hinge schematic](schematics/removable_hinge_schematic.png)

**[▶ Open in SCAD Studio](https://lizard-spock.co.uk/openscad-gui/?github=morganp/OpenSCAD_hinge/examples/removable_hinge_demo.scad)** — view this demo in the browser, no install.

| Parameter | Default | Meaning |
|---|---|---|
| `leaf_length` | 40 | Hinge length along the axis (Y); each leaf's barrel half takes ~half |
| `leaf_width` | 16 | Depth of each leaf plate |
| `leaf_thickness` | 3 | Leaf plate thickness |
| `knuckle_od` | 9 | Barrel outer diameter |
| `pin_d` | 0 | Pin diameter; 0 = auto (`knuckle_od / 2`) |
| `pin_clearance` | 0.3 | Radial clearance between pin and socket bore |
| `knuckle_gap` | 0.4 | Axial gap between the two barrel halves, and leaf-to-barrel gap |
| `pin_engagement` | 0 | Pin depth inside the socket; 0 = auto (blind bore, full depth) |
| `screw_hole_d` | 3.5 | Screw through-hole diameter |
| `screw_csk_d` | 6.5 | Countersink diameter |
| `screw_csk_depth` | 1.5 | Countersink funnel depth |
| `screws_per_leaf` | 2 | Screw holes per leaf |
| `fn` | 48 | Circle resolution |

---

## crate_hinge — rugged-box / sci-fi crate external lug hinge

External hinge in the rugged-box style: the barrel is raised above the mounting straps on
trapezoidal lug ribs, so the lid swings past 180° and the hardware reads as chunky external
detail. Leaf 1 owns the outer knuckles, leaf 2 the middle one(s); both sides are bored for a
loose pin (metal rod, screw, or the printed pin emitted beside the hinge). Cap-head
counterbored screw holes sit on the outer strip of each strap, clear of the lug ribs.

![crate_hinge render](renders/crate_hinge.png)
![crate_hinge schematic](schematics/crate_hinge_schematic.png)

**[▶ Open in SCAD Studio](https://lizard-spock.co.uk/openscad-gui/?github=morganp/OpenSCAD_hinge/examples/crate_hinge_demo.scad)** — view this demo in the browser, no install.

| Parameter | Default | Meaning |
|---|---|---|
| `leaf_length` | 36 | Hinge length along the axis (Y) |
| `strap_width` | 16 | Mounting strap depth (X), per leaf |
| `strap_thickness` | 3.5 | Strap thickness |
| `knuckle_od` | 9 | Knuckle/lug barrel outer diameter |
| `knuckle_count` | 3 | Number of knuckles (odd = pin captive lugs at both ends on leaf 1) |
| `axis_height` | 0 | Hinge axis height above Z=0; 0 = auto (`knuckle_od`) |
| `pin_d` | 4 | Pin diameter, e.g. 4mm rod; 0 = auto (`knuckle_od / 2`) |
| `pin_clearance` | 0.25 | Radial clearance between pin and bore |
| `knuckle_gap` | 0.4 | Axial clearance between adjacent lugs |
| `screw_hole_d` | 3.2 | Screw through-hole diameter |
| `screw_cb_d` | 6.2 | Cap-head counterbore diameter |
| `screw_cb_depth` | 1.5 | Counterbore depth |
| `screws_per_leaf` | 2 | Screw holes per strap, on the outer strip; 0 = none (e.g. when fusing straps onto printed parts) |
| `print_pin` | true | Emit a loose printed pin beside the hinge |
| `parts` | "both" | `"both"` / `"leaf1"` / `"leaf2"`: emit one leaf only, for fusing each leaf onto a different mating part |
| `fn` | 48 | Circle resolution |

---

## Regenerating previews

```sh
openscad -o renders/<name>.png --imgsize=800,600 --autocenter --viewall examples/<name>_demo.scad
```

Schematics are hand-authored SVGs in `schematics/`, rasterized with `rsvg-convert -o out.png in.svg`.
