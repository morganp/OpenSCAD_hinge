// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

knuckle_hinge(
    leaf_length    = 40,
    leaf_width     = 15,
    leaf_thickness = 3,
    knuckle_od     = 6,
    knuckle_count  = 5,
    pin_d          = 0,    // 0 = auto (knuckle_od / 2 = 3mm); set explicitly to suit a metal rod pin
    pin_clearance  = 0.25,
    integral_pin   = true
);
