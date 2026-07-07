// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

knuckle_hinge(
    leaf_length    = 40,
    leaf_width     = 15,
    leaf_thickness = 3,
    knuckle_od     = 6,
    knuckle_count  = 5,
    pin_clearance  = 0.25,
    integral_pin   = true
);
