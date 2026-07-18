// @github: morganp/OpenSCAD_hinge
include <../hinge_library.scad>

piano_hinge(
    length        = 100,
    leaf_width    = 12,
    leaf_thickness= 2,
    knuckle_od    = 5,
    knuckle_pitch = 8,
    pin_d         = 0,    // 0 = auto (knuckle_od / 2 = 2.5mm); set explicitly to suit a metal rod pin
    integral_pin  = true
);
