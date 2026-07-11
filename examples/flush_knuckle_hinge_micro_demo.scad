// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

// Micro variant: 2mm knuckle/leaf thickness, 0.8mm pin. Tightened
// clearances suit the small scale; fine-nozzle (0.25/0.4mm) print.
flush_knuckle_hinge(
    leaf_length       = 20,
    leaf_width        = 8,
    knuckle_od        = 2,
    knuckle_count     = 5,
    pin_d             = 0.8,
    pin_clearance     = 0.15,
    knuckle_gap       = 0.25,
    scallop_clearance = 0.2,
    integral_pin      = true,
    parts             = "both" // "leaf1" | "leaf2" to emit one leaf for fusing onto a part
);
