// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

snap_lid_hinge(
    width          = 30,
    box_leaf_len   = 8,
    lid_leaf_len   = 8,
    leaf_thickness = 3,
    web_length     = 3,
    web_thickness  = 0.8,
    bump_r         = 0.6
);
