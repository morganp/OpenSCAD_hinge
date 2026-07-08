# OpenSCAD_hinge

Parametric hinge library in plain OpenSCAD (no external libraries — must load in
[OpenSCAD-gui](../OpenSCAD-gui), a custom JS-based OpenSCAD engine that does **not** support
BOSL2 or other `use`/`include` third-party libs beyond its drag-drop `.scad` file provider).

## Constraint: no BOSL2

Unlike other OpenSCAD projects in this workspace, do **not** `include <BOSL2/std.scad>` here.
OpenSCAD-gui resolves `include`/`use` only against files dropped into its own file provider,
keyed by lowercased basename — it has no bundled library set. Every module in this repo must be
self-contained vanilla OpenSCAD so it renders identically in real OpenSCAD and in OpenSCAD-gui.

## Layout

- `hinge_library.scad` — main library, one module per hinge type, all vanilla OpenSCAD.
- `examples/` — one demo file per hinge type, `include`s the library and instantiates it with
  sane defaults for preview.
- `renders/` — PNG preview per hinge type, regenerate with:
  `openscad -o renders/<name>.png --imgsize=800,600 examples/<name>_demo.scad`

## Hinge types

| Module | Use case |
|--------|----------|
| `knuckle_hinge()` | print-in-place barrel hinge for box lids, interleaved knuckles + pin |
| `piano_hinge()` | continuous knuckle hinge, cut to any length, for long lids |
| `living_hinge()` | flexible groove-cut strip hinge, thin-wall print-in-place lids |
| `door_butt_hinge()` | traditional mortise-plate butt hinge w/ countersunk screw holes, for wooden doors/cabinets |
| `snap_lid_hinge()` | pin-less snap-fit hinge for box lids, no assembly |
| `removable_hinge()` | lift-off hinge, pin leaf + socket leaf, door removes without tools |
| `crate_hinge()` | rugged-box / sci-fi crate external lug hinge, raised axis for 180°+ opening |

## Conventions

- All modules parameterised: leaf/plate dimensions, knuckle diameter/count, pin clearance,
  screw hole size/count, `$fn` passed through, no hardcoded constants.
- Origin/orientation: hinge sits along the X axis, hinge axis (barrel) parallel to Y, closed
  flat in the XY plane at Z=0, so two leaves can be booleaned onto two mating parts directly.
- Units: mm.
- Every example file starts with `// @github: morganp/OpenSCAD_hinge` directly above its
  `include` line. OpenSCAD-gui scans that tag to auto-fetch the library when the file is
  opened outside a full-repo deep link (and re-emits it in generated code), so copied
  snippets stay self-resolving. Real OpenSCAD ignores it as a comment.

## Workflow

- Add new hinge type: new module in `hinge_library.scad` + matching `examples/<name>_demo.scad`
  + rendered PNG in `renders/` + row in the table above.
- Test load path: this repo must also open standalone in real OpenSCAD (`openscad
  examples/<name>_demo.scad`) as a regression check against the OpenSCAD-gui engine.
