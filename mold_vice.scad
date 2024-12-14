include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <mirror_copy.scad>

$fn=32;

mold_size = [30, 35, 25];

pusher_outer_radius = 12;
pusher_inner_radius = 8;
pusher_thickness = 2;
wall_thickness = 2;
hook_width = mold_size[0];
nut_thickness = 4;
screw_type = "M16,18";
screw_length = 16;
fit_dist=0.2;// like slop but a static value for fitting parts together
hook_to_box_thickness = wall_thickness;
hook_thickness = pusher_thickness+wall_thickness*2;
screw_diameter = 16;
box_width = mold_size[0]+wall_thickness*2;
box_depth = mold_size[1]+hook_thickness*2;
box_height = mold_size[2]+wall_thickness;

ZFO = 0.01;//z fighting offset

module pusher() {
    // cylindrical based with cone on top with screw with no head
    cylinder_height = 3;
    screw_part_inset= 2;
    translate([0,0,pusher_thickness/2.0]) {
        cylinder(r=pusher_outer_radius, h=pusher_thickness, center=true);
        translate([0,0,pusher_thickness/2.0+cylinder_height/2.0]) {
            cylinder(r1=pusher_inner_radius, r2=2.5, h=cylinder_height, center=true);
            translate([0,0,cylinder_height/2.0+screw_length/2.0-screw_part_inset])
                screw(screw_type, head="none", length=screw_length);
        }
    }

}

module mold_clasp_cutout(hook_thickness, z_offset=0, fit_dist=0) {
    xmirror(copy=true) {
        // angled hooks for clamp box
        translate([hook_width/2.0-hook_to_box_thickness/2.0, 0, hook_to_box_thickness/2.0+fit_dist/2.0]) {
            cube([hook_to_box_thickness+z_offset+fit_dist, hook_width+z_offset, hook_to_box_thickness+z_offset+fit_dist], center=true);
            translate([-hook_to_box_thickness/2.0, 0, hook_to_box_thickness-fit_dist/2.0])
                cube([hook_to_box_thickness*2+z_offset+fit_dist, hook_width+z_offset, hook_to_box_thickness+fit_dist+z_offset], center=true);
        }
    }
}

module hook() {
    // square with cylinder hole and cutout to slide cylinder into
    difference() {
        translate([0,0,hook_thickness/2.0]) 
            cube([hook_width, hook_width, hook_thickness], center=true);
        translate([0,0,hook_thickness/2.0])
            cylinder(r=pusher_outer_radius+fit_dist, h=pusher_thickness+fit_dist, center=true);
        translate([0,hook_width/2,hook_thickness/2.0])
            cube([pusher_outer_radius*2+fit_dist*2, hook_width, pusher_thickness+fit_dist], center=true);
        translate([0,0,wall_thickness/2.0])
            cylinder(r=pusher_inner_radius+fit_dist, h=wall_thickness+fit_dist, center=true);
        translate([0,hook_width/2,wall_thickness/2.0])
            cube([pusher_inner_radius*2+fit_dist*2, hook_width, wall_thickness+fit_dist], center=true);
    }
    translate([0,0,hook_thickness])
        mold_clasp_cutout(hook_thickness, fit_dist=0);
    // corner hooks for mold box

}

module clamp_case() {
    box_size = [box_width, box_depth, box_height];
    inset_size = [wall_thickness*2-fit_dist, wall_thickness*2-fit_dist, wall_thickness];
    diff("rem1")
    {
        diff("rem1-1")
            cuboid(box_size, anchor=BOTTOM)
                color("red") tag("rem1-1") align(CENTER,TOP,inside=true,shiftout=ZFO) cuboid(box_size-inset_size, anchor=TOP);
        diff("rem1-2")
            translate([0, -box_size[1]/2, box_size[2]/2])
                cyl(d=screw_diameter+nut_thickness*2,h=nut_thickness, anchor=TOP, orient=FRONT)
                    tag("rem1-2") attach([BOTTOM]) chamfer_cylinder_mask(d=screw_diameter+nut_thickness*2, chamfer=nut_thickness-wall_thickness);
        tag("rem1")
            translate([0, -box_size[1]/2, box_size[2]/2])
                screw_hole(screw_type,anchor=TOP, orient=FRONT,thread=true,bevel1="reverse", $slop=0.05);
    }
}

module model_box_base() {
    color("orange")
    translate([0,-mold_size[1]/2,0])
        difference() {
            cube(mold_size, center=true);
            color("blue")
            ymirror(copy=true)
                translate([0,mold_size[1]/2, 0])
                    rotate([90,0,0])
                        mold_clasp_cutout(hook_thickness, z_offset=0.1, fit_dist=fit_dist*2);
        }
}

module screw_test() {
    // make a simple screw hole
    hook_width = pusher_outer_radius*2+6;
    diff()
        cuboid([hook_width,nut_thickness,hook_width])
            attach(FRONT)
                screw_hole(screw_type,anchor=TOP,thread=true,bevel1="reverse", $slop=0.05);
}


// translate([0,0,hook_width/2])
//     rotate([90,0,0])
//         hook();

// translate([0,-hook_thickness,hook_width/2])
//     model_box_base();
//anchor(BOTTOM)
clamp_case();
//pusher();
//screw_test();
