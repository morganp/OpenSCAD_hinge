// hinge_library.scad
// Parametric hinge library — plain OpenSCAD, no external includes.
// Loadable standalone in OpenSCAD and by OpenSCAD-gui (../OpenSCAD-gui).
//
// Hinge axis convention: barrel/knuckle axis runs along Y, hinge lies flat
// (closed) in the XY plane at Z=0. Leaf 1 occupies X<0, leaf 2 occupies X>=0,
// so each leaf can be positioned/differenced onto its own mating part.

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

module _hinge_pin(length, radius, fn=32) {
    cylinder(h=length, r=radius, center=true, $fn=fn);
}

// ---------------------------------------------------------------------------
// 1. knuckle_hinge — print-in-place barrel hinge for box lids.
//    Interleaved knuckles on two leaves, joined by a central pin.
// ---------------------------------------------------------------------------
module knuckle_hinge(
    leaf_length   = 40,   // length along Y (hinge axis)
    leaf_width    = 15,   // depth along X, per leaf
    leaf_thickness= 3,
    knuckle_od    = 6,
    knuckle_count = 5,    // total knuckles across both leaves (odd = symmetric)
    pin_clearance = 0.25, // radial clearance between pin and knuckle bore
    print_pin     = true, // include the pin as a separate, rotated-free solid
    include_leaves= true, // false = knuckles/pin only, caller supplies its own leaves
    fn            = 48
) {
    knuckle_r  = knuckle_od / 2;
    gap        = knuckle_od * 0.06; // slight print clearance between adjacent knuckles
    seg_len    = leaf_length / knuckle_count;
    pin_r      = knuckle_r - leaf_thickness * 0.35;

    module knuckle_at(i, on_leaf_a) {
        y0 = -leaf_length/2 + i*seg_len;
        translate([0, y0 + gap/2, 0])
            cylinder(h=seg_len - gap, r=knuckle_r, $fn=fn);
    }

    // leaf plates (flat, sit under/behind the knuckle row)
    module leaf_plate(sign) {
        translate([sign * (leaf_width/2), 0, -leaf_thickness/2])
            cube([leaf_width, leaf_length, leaf_thickness], center=true);
    }

    difference() {
        union() {
            if (include_leaves) {
                translate([-knuckle_r, 0, 0]) leaf_plate(-1);
                translate([ knuckle_r, 0, 0]) leaf_plate(1);
            }
            translate([0, 0, 0])
                for (i = [0:knuckle_count-1])
                    if ((i % 2 == 0)) knuckle_at(i, true);
                    else knuckle_at(i, false);
        }
        // bore through all knuckles for the pin
        translate([0,0,0]) rotate([0,0,0])
            translate([0, -leaf_length/2 - 1, 0])
                rotate([-90,0,0])
                    cylinder(h=leaf_length + 2, r=pin_r + pin_clearance, $fn=fn);
    }

    if (print_pin) {
        translate([0, leaf_length/2 + knuckle_od, 0])
            rotate([-90,0,0])
                _hinge_pin(leaf_length - gap, pin_r, fn);
    }
}

// ---------------------------------------------------------------------------
// 2. piano_hinge — continuous knuckle hinge, cut to any length.
//    Same geometry as knuckle_hinge but knuckle_count is derived from length
//    and a fixed pitch, for long lids/lids that need even load distribution.
// ---------------------------------------------------------------------------
module piano_hinge(
    length        = 100,
    leaf_width    = 12,
    leaf_thickness= 2,
    knuckle_od    = 5,
    knuckle_pitch = 8,   // approx spacing between knuckle centers
    pin_clearance = 0.25,
    print_pin     = true,
    fn            = 32
) {
    n = max(3, round(length / knuckle_pitch));
    knuckle_hinge(
        leaf_length    = length,
        leaf_width     = leaf_width,
        leaf_thickness = leaf_thickness,
        knuckle_od     = knuckle_od,
        knuckle_count  = n,
        pin_clearance  = pin_clearance,
        print_pin      = print_pin,
        fn             = fn
    );
}

// ---------------------------------------------------------------------------
// 3. living_hinge — flexible groove-cut strip hinge for thin-wall,
//    print-in-place lids (PP/PLA-flex style, snaps back after folding).
// ---------------------------------------------------------------------------
module living_hinge(
    width       = 40,   // along Y
    length      = 10,   // fold direction, along X
    thickness   = 2,    // parent wall thickness either side of the hinge
    web_thickness = 0.6,// thin flexible web left after the groove cuts
    groove_count  = 3,  // number of parallel relief grooves
    groove_width  = 1.2
) {
    difference() {
        cube([length, width, thickness], center=true);
        spacing = length / (groove_count + 1);
        for (i = [1:groove_count]) {
            x = -length/2 + i*spacing;
            translate([x, 0, thickness/2 - web_thickness/2])
                cube([groove_width, width + 1, web_thickness + 1], center=true);
            translate([x, 0, -(thickness/2 - web_thickness/2)])
                cube([groove_width, width + 1, web_thickness + 1], center=true);
        }
    }
}

// ---------------------------------------------------------------------------
// 4. door_butt_hinge — traditional mortise-plate butt hinge, e.g. brass/steel
//    hardware pattern, for wooden doors/cabinets. Two flat leaves + knuckle
//    barrel + countersunk screw holes. Not print-in-place: model to spec for
//    routing a mortise, or print as a functional part in a rigid filament.
// ---------------------------------------------------------------------------
module door_butt_hinge(
    leaf_length     = 76,   // e.g. 3" hinge
    leaf_width      = 28,
    leaf_thickness  = 2.5,
    knuckle_od      = 8,
    knuckle_count   = 5,
    screw_hole_d    = 3.5,
    screw_csk_d     = 6.5,
    screw_csk_depth = 1.5,
    screws_per_leaf = 4,
    pin_clearance   = 0.3,
    fn              = 48
) {
    knuckle_r = knuckle_od/2;

    module leaf_with_holes(sign) {
        difference() {
            translate([sign * (leaf_width/2 + 0), 0, -leaf_thickness/2])
                cube([leaf_width, leaf_length, leaf_thickness], center=true);
            // screw holes down the centerline of the leaf, evenly spaced
            inset = leaf_length / (screws_per_leaf + 1);
            for (i = [1:screws_per_leaf]) {
                y = -leaf_length/2 + i*inset;
                x = sign * (leaf_width/2 + knuckle_r*0.4 + leaf_width*0.25);
                translate([x, y, 0]) {
                    cylinder(h=leaf_thickness*3, r=screw_hole_d/2, center=true, $fn=fn);
                    translate([0,0,leaf_thickness/2 - screw_csk_depth/2 + 0.01])
                        cylinder(h=screw_csk_depth+0.02, r1=screw_hole_d/2, r2=screw_csk_d/2, $fn=fn);
                }
            }
        }
    }

    knuckle_hinge(
        leaf_length    = leaf_length,
        leaf_width     = leaf_width,
        leaf_thickness = leaf_thickness,
        knuckle_od     = knuckle_od,
        knuckle_count  = knuckle_count,
        pin_clearance  = pin_clearance,
        print_pin      = true,
        include_leaves = false,
        fn             = fn
    );

    // leaves with countersunk screw holes, in place of knuckle_hinge's plain plates
    translate([-knuckle_r,0,0]) leaf_with_holes(-1);
    translate([ knuckle_r,0,0]) leaf_with_holes(1);
}

// ---------------------------------------------------------------------------
// 5. snap_lid_hinge — pin-less friction/snap hinge for box lids: a thinned
//    flex web plus an over-center bump so the lid snaps open/closed without
//    a separate pin. No assembly required.
// ---------------------------------------------------------------------------
module snap_lid_hinge(
    width          = 30,   // along Y
    box_leaf_len   = 8,    // leaf glued/printed into the box wall
    lid_leaf_len   = 8,    // leaf glued/printed into the lid wall
    leaf_thickness = 3,
    web_length     = 3,    // flex web length between leaves, along X
    web_thickness  = 0.8,
    bump_r         = 0.6   // over-center detent bump radius
) {
    total_len = box_leaf_len + web_length + lid_leaf_len;
    x0 = -total_len/2;

    union() {
        // box-side leaf
        translate([x0 + box_leaf_len/2, 0, 0])
            cube([box_leaf_len, width, leaf_thickness], center=true);

        // flex web (thin, centered on Z so it sits mid-wall)
        translate([x0 + box_leaf_len + web_length/2, 0, 0])
            cube([web_length, width, web_thickness], center=true);

        // over-center detent bump on the web
        translate([x0 + box_leaf_len + web_length/2, 0, leaf_thickness/2 - web_thickness/2])
            rotate([0,90,0])
                cylinder(h=width, r=bump_r, center=true, $fn=24);

        // lid-side leaf
        translate([x0 + box_leaf_len + web_length + lid_leaf_len/2, 0, 0])
            cube([lid_leaf_len, width, leaf_thickness], center=true);
    }
}
