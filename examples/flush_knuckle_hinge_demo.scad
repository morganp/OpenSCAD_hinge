// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

flush_knuckle_hinge(
    leaf_length       = 40,
    leaf_width        = 15,
    knuckle_od        = 6,
    knuckle_count     = 5,
    pin_clearance     = 0.25,
    knuckle_gap       = 0.3,
    scallop_clearance = 0.3,
    integral_pin      = true
);
