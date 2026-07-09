// hinge_library.scad
// Parametric hinge library, plain OpenSCAD, no external includes.
// Loadable standalone in OpenSCAD and by OpenSCAD-gui (../OpenSCAD-gui).
//
// Hinge axis convention: barrel/knuckle axis runs along Y at x=0, z=knuckle
// radius, so the whole hinge sits flat on the Z=0 plane (printable as-is).
// Leaf 1 occupies X<0, leaf 2 occupies X>=0; each leaf is a separate solid
// so it can be positioned/unioned onto its own mating part, and the barrel
// clearances leave the joint free to rotate.

// ---------------------------------------------------------------------------
// 1. knuckle_hinge, print-in-place barrel hinge for box lids.
//    Interleaved knuckles on two leaves. By default the pin is integral to
//    leaf 1 (its knuckles are solid with the pin) and leaf 2's knuckles are
//    bored with radial clearance, so the printed part articulates with no
//    assembly. Set integral_pin=false for a bored-both-sides hinge with an
//    optional separately printed pin (print_pin=true).
// ---------------------------------------------------------------------------
module knuckle_hinge(
    leaf_length    = 40,   // length along Y (hinge axis)
    leaf_width     = 15,   // depth along X, per leaf, excluding barrel
    leaf_thickness = 3,
    knuckle_od     = 6,
    knuckle_count  = 5,    // total knuckles across both leaves (odd = pin captive at both ends)
    pin_d          = 0,    // pin diameter; 0 = auto (knuckle_od / 2)
    pin_clearance  = 0.25, // radial clearance between pin and knuckle bore
    knuckle_gap    = 0.3,  // axial clearance between adjacent knuckles, and leaf-to-barrel gap
    integral_pin   = true, // pin fused to leaf 1's knuckles (print-in-place)
    print_pin      = false,// integral_pin=false only: emit loose pin beside the hinge
    parts          = "both", // "both" | "leaf1" | "leaf2": emit one leaf only, so a caller
                             // can fuse each leaf onto a different part (lid vs box)
    fn             = 48
) {
    knuckle_r = knuckle_od / 2;
    axis_z    = knuckle_r;               // barrel rests on the Z=0 plane
    seg       = leaf_length / knuckle_count;
    pin_r     = (pin_d > 0 ? pin_d : knuckle_od / 2) / 2;
    bore_r    = pin_r + pin_clearance;
    edge      = knuckle_r + knuckle_gap; // leaf plate inner edge, clears the barrel

    module barrel_seg(i) {
        translate([0, -leaf_length/2 + i*seg + knuckle_gap/2, axis_z])
            rotate([-90, 0, 0])
                cylinder(h=seg - knuckle_gap, r=knuckle_r, $fn=fn);
    }

    // bridges the plate-to-barrel gap, only across this leaf's own knuckles
    module neck(sign, i) {
        translate([sign > 0 ? 0 : -(edge + 0.5),
                   -leaf_length/2 + i*seg + knuckle_gap/2, 0])
            cube([edge + 0.5, seg - knuckle_gap, leaf_thickness]);
    }

    module plate(sign) {
        translate([sign > 0 ? edge : -(edge + leaf_width), -leaf_length/2, 0])
            cube([leaf_width, leaf_length, leaf_thickness]);
    }

    // sign=-1 owns even-index knuckles (both ends when count is odd)
    module leaf(sign) {
        plate(sign);
        for (i = [0:knuckle_count-1])
            if ((i % 2 == 0) == (sign < 0)) {
                barrel_seg(i);
                neck(sign, i);
            }
    }

    module bore() {
        translate([0, -leaf_length/2 - 1, axis_z])
            rotate([-90, 0, 0])
                cylinder(h=leaf_length + 2, r=bore_r, $fn=fn);
    }

    // leaf 1 (X<0)
    if (parts != "leaf2") {
        if (integral_pin) {
            leaf(-1);
            translate([0, -leaf_length/2, axis_z])
                rotate([-90, 0, 0])
                    cylinder(h=leaf_length, r=pin_r, $fn=fn);
        } else {
            difference() { leaf(-1); bore(); }
        }
    }

    // leaf 2 (X>=0), always bored
    if (parts != "leaf1")
        difference() { leaf(1); bore(); }

    if (!integral_pin && print_pin)
        translate([-(edge + leaf_width + knuckle_od), 0, pin_r])
            rotate([-90, 0, 0])
                cylinder(h=leaf_length - knuckle_gap, r=pin_r, center=true, $fn=fn);
}

// ---------------------------------------------------------------------------
// 2. piano_hinge, continuous knuckle hinge, cut to any length.
//    Same geometry as knuckle_hinge but knuckle_count is derived from length
//    and a fixed pitch, for long lids that need even load distribution.
// ---------------------------------------------------------------------------
module piano_hinge(
    length         = 100,
    leaf_width     = 12,
    leaf_thickness = 2,
    knuckle_od     = 5,
    knuckle_pitch  = 8,   // approx spacing between knuckle centers
    pin_d          = 0,
    pin_clearance  = 0.25,
    knuckle_gap    = 0.3,
    integral_pin   = true,
    print_pin      = false,
    parts          = "both",
    fn             = 32
) {
    // force an odd count so the pin is captive at both ends
    raw = max(3, round(length / knuckle_pitch));
    n   = raw % 2 == 0 ? raw + 1 : raw;
    knuckle_hinge(
        leaf_length    = length,
        leaf_width     = leaf_width,
        leaf_thickness = leaf_thickness,
        knuckle_od     = knuckle_od,
        knuckle_count  = n,
        pin_d          = pin_d,
        pin_clearance  = pin_clearance,
        knuckle_gap    = knuckle_gap,
        integral_pin   = integral_pin,
        print_pin      = print_pin,
        parts          = parts,
        fn             = fn
    );
}

// ---------------------------------------------------------------------------
// 3. living_hinge, flexible groove-cut strip hinge for thin-wall,
//    print-in-place lids. Relief grooves alternate top/bottom faces, each
//    leaving a web of web_thickness, so the strip flexes without tearing.
// ---------------------------------------------------------------------------
module living_hinge(
    width         = 40,  // along Y
    length        = 10,  // fold direction, along X
    thickness     = 2,   // parent wall thickness either side of the hinge
    web_thickness = 0.6, // flexible web left behind each groove cut
    groove_count  = 3,   // number of parallel relief grooves
    groove_width  = 1.2
) {
    cut_h   = thickness - web_thickness + 0.05; // overcut past the face
    spacing = length / (groove_count + 1);
    difference() {
        cube([length, width, thickness], center=true);
        for (i = [1:groove_count]) {
            x    = -length/2 + i*spacing;
            side = (i % 2 == 1) ? 1 : -1; // alternate: cut from top, then bottom
            translate([x, 0, side * (thickness/2 + 0.05 - cut_h/2)])
                cube([groove_width, width + 1, cut_h], center=true);
        }
    }
}

// ---------------------------------------------------------------------------
// 4. door_butt_hinge, traditional mortise-plate butt hinge, e.g. brass/steel
//    hardware pattern, for wooden doors/cabinets. Two flat leaves + knuckle
//    barrel + countersunk screw holes down each leaf centerline. Both sides
//    are bored; the loose pin prints beside the hinge (print_pin).
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
    pin_d           = 0,
    pin_clearance   = 0.3,
    knuckle_gap     = 0.3,
    print_pin       = true,
    fn              = 48
) {
    knuckle_r = knuckle_od / 2;
    edge      = knuckle_r + knuckle_gap;
    hole_x    = edge + leaf_width / 2;   // leaf centerline
    pitch     = leaf_length / (screws_per_leaf + 1);

    module screw_hole() {
        cylinder(h=leaf_thickness*3, r=screw_hole_d/2, center=true, $fn=fn);
        // countersink opens on the top face (z = leaf_thickness)
        translate([0, 0, leaf_thickness - screw_csk_depth])
            cylinder(h=screw_csk_depth + 0.05, r1=screw_hole_d/2, r2=screw_csk_d/2, $fn=fn);
    }

    difference() {
        knuckle_hinge(
            leaf_length    = leaf_length,
            leaf_width     = leaf_width,
            leaf_thickness = leaf_thickness,
            knuckle_od     = knuckle_od,
            knuckle_count  = knuckle_count,
            pin_d          = pin_d,
            pin_clearance  = pin_clearance,
            knuckle_gap    = knuckle_gap,
            integral_pin   = false,
            print_pin      = print_pin,
            fn             = fn
        );
        for (i = [1:screws_per_leaf], s = [-1, 1])
            translate([s * hole_x, -leaf_length/2 + i*pitch, 0])
                screw_hole();
    }
}

// ---------------------------------------------------------------------------
// 5. snap_lid_hinge, pin-less flex hinge for box lids: a thin web flush with
//    the top surface (so the lid folds up and over) plus an over-center
//    detent bump under the web that gives a snap feel. No assembly required.
// ---------------------------------------------------------------------------
module snap_lid_hinge(
    width          = 30,  // along Y
    box_leaf_len   = 8,   // leaf glued/printed into the box wall
    lid_leaf_len   = 8,   // leaf glued/printed into the lid wall
    leaf_thickness = 3,
    web_length     = 3,   // flex web length between leaves, along X
    web_thickness  = 0.8,
    bump_r         = 0.6  // over-center detent bump radius
) {
    total_len = box_leaf_len + web_length + lid_leaf_len;
    x0        = -total_len / 2;
    web_x     = x0 + box_leaf_len + web_length/2;
    web_top   = leaf_thickness / 2; // web flush with top surface = fold line

    // box-side leaf
    translate([x0 + box_leaf_len/2, 0, 0])
        cube([box_leaf_len, width, leaf_thickness], center=true);

    // flex web, flush with the top surface
    translate([web_x, 0, web_top - web_thickness/2])
        cube([web_length, width, web_thickness], center=true);

    // over-center detent bump on the underside of the web, axis along Y
    translate([web_x, 0, web_top - web_thickness])
        rotate([90, 0, 0])
            cylinder(h=width * 0.6, r=bump_r, center=true, $fn=24);

    // lid-side leaf
    translate([x0 + box_leaf_len + web_length + lid_leaf_len/2, 0, 0])
        cube([lid_leaf_len, width, leaf_thickness], center=true);
}

// ---------------------------------------------------------------------------
// 6. removable_hinge, lift-off (loose-joint) hinge, two fully separable
//    leaves, e.g. for printer/enclosure doors that must come off without
//    tools. Leaf 1 (X<0) carries the lower barrel half with an integral pin
//    sticking up along +Y; leaf 2 (X>=0) carries the upper barrel half with
//    a blind bore open at its lower end, so the door drops on and lifts off.
//    Countersunk screw holes down each leaf centerline. Print each leaf
//    separately, barrel axis vertical, no supports needed on the socket if
//    the bore chamfer is bridged, or flat with supports under the barrel.
// ---------------------------------------------------------------------------
module removable_hinge(
    leaf_length     = 40,   // along Y; each leaf's barrel half takes ~half
    leaf_width      = 16,
    leaf_thickness  = 3,
    knuckle_od      = 9,
    pin_d           = 0,    // 0 = auto (knuckle_od / 2)
    pin_clearance   = 0.3,  // radial clearance between pin and socket bore
    knuckle_gap     = 0.4,  // axial gap between barrel halves + leaf-to-barrel gap
    pin_engagement  = 0,    // pin depth inside the socket; 0 = auto (blind bore, full depth)
    screw_hole_d    = 3.5,
    screw_csk_d     = 6.5,
    screw_csk_depth = 1.5,
    screws_per_leaf = 2,
    fn              = 48
) {
    knuckle_r  = knuckle_od / 2;
    axis_z     = knuckle_r;                 // barrel rests on the Z=0 plane
    edge       = knuckle_r + knuckle_gap;
    half       = leaf_length / 2;
    pin_r      = (pin_d > 0 ? pin_d : knuckle_od / 2) / 2;
    bore_r     = pin_r + pin_clearance;
    barrel_len = half - knuckle_gap / 2;    // each barrel half's axial length
    engage     = pin_engagement > 0 ? pin_engagement
                                    : barrel_len - knuckle_gap; // leave a blind top wall

    module plate(sign) {
        translate([sign > 0 ? edge : -(edge + leaf_width), -half, 0])
            cube([leaf_width, leaf_length, leaf_thickness]);
    }

    // bridges the plate-to-barrel gap, only across this leaf's own barrel half
    module neck(sign, y0) {
        translate([sign > 0 ? 0 : -(edge + 0.5), y0, 0])
            cube([edge + 0.5, barrel_len, leaf_thickness]);
    }

    module barrel(y0) {
        translate([0, y0, axis_z])
            rotate([-90, 0, 0])
                cylinder(h=barrel_len, r=knuckle_r, $fn=fn);
    }

    module screw_holes(sign) {
        pitch = leaf_length / (screws_per_leaf + 1);
        for (i = [1:screws_per_leaf])
            translate([sign * (edge + leaf_width/2), -half + i*pitch, 0]) {
                cylinder(h=leaf_thickness*3, r=screw_hole_d/2, center=true, $fn=fn);
                translate([0, 0, leaf_thickness - screw_csk_depth])
                    cylinder(h=screw_csk_depth + 0.05,
                             r1=screw_hole_d/2, r2=screw_csk_d/2, $fn=fn);
            }
    }

    // leaf 1 (X<0): lower barrel half, pin integral, pointing up along +Y
    difference() {
        union() {
            plate(-1);
            barrel(-half);
            neck(-1, -half);
            translate([0, -half, axis_z])
                rotate([-90, 0, 0])
                    cylinder(h=barrel_len + knuckle_gap + engage, r=pin_r, $fn=fn);
        }
        screw_holes(-1);
    }

    // leaf 2 (X>=0): upper barrel half, blind bore open at its lower end
    difference() {
        union() {
            plate(1);
            barrel(knuckle_gap/2);
            neck(1, knuckle_gap/2);
        }
        translate([0, knuckle_gap/2 - 0.05, axis_z])
            rotate([-90, 0, 0])
                cylinder(h=engage + 0.05, r=bore_r, $fn=fn);
        screw_holes(1);
    }
}

// ---------------------------------------------------------------------------
// 7. crate_hinge, rugged-box / sci-fi crate external lug hinge. The barrel
//    is raised above the mounting straps on trapezoidal lug ribs, so a lid
//    can swing past 180 degrees and the hardware reads as chunky external
//    detail. Leaf 1 owns the outer knuckles, leaf 2 the middle one(s); both
//    sides are bored for a loose pin (metal rod, screw, or the printed pin
//    emitted beside the hinge). Cap-head counterbored screw holes sit on the
//    outer strip of each strap, clear of the lug ribs.
// ---------------------------------------------------------------------------
module crate_hinge(
    leaf_length     = 36,   // along Y (hinge axis)
    strap_width     = 16,   // mounting strap depth along X, per leaf
    strap_thickness = 3.5,
    knuckle_od      = 9,
    knuckle_count   = 3,    // odd = pin captive lugs at both ends on leaf 1
    axis_height     = 0,    // hinge axis height above Z=0; 0 = auto (knuckle_od)
    pin_d           = 4,    // e.g. 4mm rod; 0 = auto (knuckle_od / 2)
    pin_clearance   = 0.25,
    knuckle_gap     = 0.4,  // axial clearance between adjacent lugs
    screw_hole_d    = 3.2,
    screw_cb_d      = 6.2,  // cap-head counterbore diameter
    screw_cb_depth  = 1.5,
    screws_per_leaf = 2,
    print_pin       = true, // emit a loose printed pin beside the hinge
    parts           = "both", // "both" | "leaf1" | "leaf2": emit one leaf only, so a caller
                              // can fuse each leaf onto a different part (lid vs box)
    fn              = 48
) {
    knuckle_r = knuckle_od / 2;
    axis_z    = axis_height > 0 ? axis_height : knuckle_od;
    edge      = knuckle_r + knuckle_gap;
    seg       = leaf_length / knuckle_count;
    pin_r     = (pin_d > 0 ? pin_d : knuckle_od / 2) / 2;
    bore_r    = pin_r + pin_clearance;
    lug_base  = knuckle_od; // lug rib footprint depth on the strap

    module strap(sign) {
        translate([sign > 0 ? edge : -(edge + strap_width), -leaf_length/2, 0])
            cube([strap_width, leaf_length, strap_thickness]);
    }

    // trapezoidal rib from the strap up to the raised barrel knuckle
    module lug(sign, i) {
        y0 = -leaf_length/2 + i*seg + knuckle_gap/2;
        hull() {
            translate([0, y0, axis_z])
                rotate([-90, 0, 0])
                    cylinder(h=seg - knuckle_gap, r=knuckle_r, $fn=fn);
            translate([sign > 0 ? edge : -(edge + lug_base), y0, 0])
                cube([lug_base, seg - knuckle_gap, strap_thickness]);
        }
    }

    // sign=-1 owns even-index knuckles (both ends when count is odd)
    module leaf(sign) {
        strap(sign);
        for (i = [0:knuckle_count-1])
            if ((i % 2 == 0) == (sign < 0))
                lug(sign, i);
    }

    module bore() {
        translate([0, -leaf_length/2 - 1, axis_z])
            rotate([-90, 0, 0])
                cylinder(h=leaf_length + 2, r=bore_r, $fn=fn);
    }

    // screw holes on the outer strip of the strap, clear of the lug ribs
    module screw_holes(sign) {
        pitch  = leaf_length / (screws_per_leaf + 1);
        hole_x = edge + lug_base + (strap_width - lug_base) / 2;
        if (screws_per_leaf > 0)
            for (i = [1:screws_per_leaf])
                translate([sign * hole_x, -leaf_length/2 + i*pitch, 0]) {
                    cylinder(h=strap_thickness*3, r=screw_hole_d/2, center=true, $fn=fn);
                    translate([0, 0, strap_thickness - screw_cb_depth])
                        cylinder(h=screw_cb_depth + 0.05, r=screw_cb_d/2, $fn=fn);
                }
    }

    for (s = (parts == "leaf1" ? [-1] : parts == "leaf2" ? [1] : [-1, 1]))
        difference() {
            leaf(s);
            bore();
            screw_holes(s);
        }

    if (print_pin)
        translate([-(edge + strap_width + knuckle_od), 0, pin_r])
            rotate([-90, 0, 0])
                cylinder(h=leaf_length - knuckle_gap, r=pin_r, center=true, $fn=fn);
}
