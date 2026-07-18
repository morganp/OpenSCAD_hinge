// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

door_butt_hinge(
    leaf_length    = 76,
    leaf_width     = 28,
    leaf_thickness = 2.5,
    knuckle_od     = 8,
    knuckle_count  = 5,
    pin_d          = 0,    // 0 = auto (knuckle_od / 2 = 4mm); set explicitly to suit a metal rod pin
    screw_hole_d   = 3.5,
    screw_csk_d    = 6.5,
    screws_per_leaf= 4
);
