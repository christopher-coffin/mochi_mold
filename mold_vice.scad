include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <mirror_copy.scad>

$fn=32;


chef_hat = ["src_models/Fred_chef.stl", [30, 35, 40], [0, 0, -2.11]];
top_hat = ["src_models/fixed_Fred_the_Frog_with_a_Top_Hat.stl", [30, 35, 40], [0, 2, -2.11]];
resculpted = ["src_models/FredResculpted.stl", [30, 35, 25], [0, 0, -0.11]];
snail = ["src_models/fixed_FredthefrogbutSnail2.stl", [44, 56, 40], [0, -13, -0.11]];
crystal = ["src_models/Crystal_frog-2.stl", [30, 35, 30], [0, 0, -2.11]];
sunhat = ["src_models/fixed_FredTheFrogButSunhat.stl", [30, 35, 30], [-0, -0, -0.11]];
cold = ["src_models/fixed_Fred_but_cold.stl", [30, 37, 30], [-0, -0, 12.5]];

data = resculpted;

model_file = data[0];
mold_size = data[1];
pos_adjustment = data[2];

pusher_outer_radius = mold_size[0]/2.0-4;
pusher_inner_radius = pusher_outer_radius-3;
pusher_thickness = 2;
wall_thickness = 2;
hook_width = mold_size[0];
nut_thickness = 4;
screw_type = "M16,18";
screw_length = 12;
fit_dist=0.1;// like slop but a static value for fitting parts together
hook_to_box_thickness = wall_thickness;
hook_thickness = pusher_thickness+wall_thickness*2;
screw_diameter = 16;
screwable_dist = 5;
box_width = mold_size[0]+wall_thickness*2;
box_depth = mold_size[1]+screwable_dist+hook_thickness*2;
box_height = mold_size[2]+wall_thickness;

ZFO = 0.01;//z fighting offset


module pusher() {
    // cylindrical based with cone on top with screw with no head
    cylinder_height = 3;
    screw_part_inset= -2;
    translate([0,0,pusher_thickness/2.0]) {
        cylinder(r=pusher_outer_radius, h=pusher_thickness, center=true);
        translate([0,0,pusher_thickness/2.0+cylinder_height/2.0]) {
            cylinder(r1=pusher_inner_radius, r2=2.5, h=cylinder_height, center=true);
            translate([0,0,cylinder_height/2.0+screw_length/2.0-screw_part_inset])
                screw(screw_type, head="hex", length=screw_length, head_undersize=13);
        }
    }

}

module mold_clasp_cutout(hook_thickness, z_offset=0, fit_dist=0) {
    xmirror(copy=true) {
        // angled hooks for clamp box
        translate([hook_width/2.0-hook_to_box_thickness/2.0, 0, hook_to_box_thickness/2.0+fit_dist/2.0]) {
            cube([hook_to_box_thickness+z_offset+fit_dist, mold_size[2]+z_offset, hook_to_box_thickness+z_offset+fit_dist], center=true);
            translate([-hook_to_box_thickness/2.0, 0, hook_to_box_thickness-fit_dist/2.0])
                cube([hook_to_box_thickness*2+z_offset+fit_dist, mold_size[2]+z_offset, hook_to_box_thickness+fit_dist+z_offset], center=true);
        }
    }
}

module hook() {
    // square with cylinder hole and cutout to slide cylinder into
    outer_cutout_depth = wall_thickness+fit_dist;
    inner_cutout_depth = pusher_thickness+fit_dist;
    difference() {
        //base cube
        translate([0,hook_thickness/2.0,0]) 
            cube([mold_size[0], hook_thickness, mold_size[2]], center=true);
        // middle cutout
        translate([0,wall_thickness+inner_cutout_depth/2.0, 0])
            rotate([90,0,0])
                cylinder(r=pusher_outer_radius+fit_dist, h=inner_cutout_depth, center=true);
        translate([0, wall_thickness+inner_cutout_depth/2.0, mold_size[2]/2.0])
            cube([(pusher_outer_radius+fit_dist)*2, inner_cutout_depth, mold_size[2]], center=true);
        // outer cutout
        translate([0, outer_cutout_depth/2.0, 0])
            rotate([90,0,0])
                cylinder(r=pusher_inner_radius+fit_dist, h=outer_cutout_depth+ZFO, center=true);
        translate([0, outer_cutout_depth/2.0, mold_size[2]/2.0])
            cube([(pusher_inner_radius+fit_dist)*2, outer_cutout_depth+ZFO, mold_size[2]], center=true);
    }
    translate([0,hook_thickness,0])
        rotate([-90,0,0])
            mold_clasp_cutout(hook_thickness, fit_dist=0);
    // corner hooks for mold box

}

module clamp_case() {
    box_size = [box_width, box_depth, box_height];
    inset_size = [wall_thickness*2, wall_thickness*2, wall_thickness];
    bottom_cutout_size = inset_size+[7, 14, 10];
    diff("rem1")
    {
        diff("rem1-1")
            cuboid(box_size, anchor=BOTTOM){
                color("red") tag("rem1-1") align(CENTER,TOP,inside=true,shiftout=ZFO) cuboid(box_size-inset_size, anchor=TOP);
                color("red") tag("rem1-1") align(CENTER,BOTTOM,inside=true,shiftout=ZFO) cuboid(box_size-bottom_cutout_size, anchor=BOTTOM);               
            }
        diff("rem1-2")
            translate([0, -box_size[1]/2, box_size[2]/2+wall_thickness/2.0])
                cyl(d=screw_diameter+nut_thickness*2,h=nut_thickness, anchor=TOP, orient=FRONT)
                    tag("rem1-2") attach([BOTTOM]) chamfer_cylinder_mask(d=screw_diameter+nut_thickness*2, chamfer=nut_thickness-wall_thickness);
        tag("rem1")
            translate([0, -box_size[1]/2, box_size[2]/2+wall_thickness/2.0])
                screw_hole(screw_type,anchor=TOP, orient=FRONT,thread=true,bevel1="reverse", $slop=0.05);
    }
    translate([0, box_size[1]/2-wall_thickness, box_size[2]/2+wall_thickness/2.0])
        rotate([90,0,0])
            mold_clasp_cutout();
}

module mold_box_base() {
    color("orange")
        difference() {
            cuboid(mold_size, anchor=BOTTOM);
            color("blue")
            ymirror(copy=true)
                translate([0,mold_size[1]/2,mold_size[2]/2])
                    rotate([90,0,0])
                        mold_clasp_cutout(hook_thickness, z_offset=0.1, fit_dist=fit_dist*2);
            translate(pos_adjustment)
                import(model_file);
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


// translate([0,0,mold_size[2]/2])
//     hook();
front_half()
//back_half()
    mold_box_base();
//clamp_case();
//pusher();
//screw_test();
