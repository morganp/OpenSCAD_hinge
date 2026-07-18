// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

flush_knuckle_hinge(
    leaf_length       = 40,
    leaf_width        = 15,
    knuckle_od        = 6,
    knuckle_count     = 5,
    pin_d             = 0,    // 0 = auto (knuckle_od / 2 = 3mm); set explicitly to suit a metal rod pin
    pin_clearance     = 0.25,
    knuckle_gap       = 0.3,
    scallop_clearance = 0.3,
    integral_pin      = true,
    parts             = "both" // "both" print-in-place; "leaf1" | "leaf2" lone bored leaf
                               // for fusing onto a part, then "pin" for the loose pin and
                               // "caps" for a pair of gluable rod-pin end caps

);
