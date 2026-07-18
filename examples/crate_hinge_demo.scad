// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

crate_hinge(
    leaf_length     = 36,
    strap_width     = 16,
    strap_thickness = 3.5,
    knuckle_od      = 9,
    knuckle_count   = 3,
    pin_d           = 4,    // sized for a 4mm metal rod; 0 = auto (knuckle_od / 2)
    pin_clearance   = 0.25,
    knuckle_gap     = 0.4,
    screws_per_leaf = 2,
    print_pin       = true
);
