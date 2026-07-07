include <../hinge_library.scad>

// shown embedded in a token slab of parent material either side, so the
// groove geometry is visible in context
union() {
    translate([-15, 0, 0]) cube([20, 40, 2], center=true);
    translate([15, 0, 0]) cube([20, 40, 2], center=true);
    living_hinge(
        width         = 40,
        length        = 10,
        thickness     = 2,
        web_thickness = 0.6,
        groove_count  = 3,
        groove_width  = 1.2
    );
}
