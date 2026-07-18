// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

// Micro variant: 2mm knuckle/leaf thickness, 0.8mm pin. Tightened
// clearances suit the small scale; fine-nozzle (0.25/0.4mm) print.
flush_knuckle_hinge(
    leaf_length       = 20,
    leaf_width        = 8,
    knuckle_od        = 2,
    knuckle_count     = 5,
    pin_d             = 0.8,  // suits a 0.8mm metal rod or filament pin; 0 = auto (knuckle_od / 2)
    pin_clearance     = 0.15,
    knuckle_gap       = 0.25,
    scallop_clearance = 0.2,
    back_relief       = 0.35,  // top-face notch depth just outside the seam lip, frees swing past 90 degrees
    back_relief_width = 0.2,   // notch width outward from the lip; rest of the knuckle stays full height
    integral_pin      = true,
    parts             = "both" // "both" print-in-place; "leaf1" | "leaf2" lone bored leaf
                                // for fusing onto a part, then "pin" for the loose pin and
                                // "caps" for a pair of gluable rod-pin end caps

);
