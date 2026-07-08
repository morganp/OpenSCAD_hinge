// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

removable_hinge(
    leaf_length     = 40,
    leaf_width      = 16,
    leaf_thickness  = 3,
    knuckle_od      = 9,
    pin_clearance   = 0.3,
    knuckle_gap     = 0.4,
    screws_per_leaf = 2
);
