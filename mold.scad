include <BOSL2/std.scad>

// screw and nut sizes for m6 screws
screw_diameter= 6.4; // add in some fudge for fit
nut_thickness = 5;
nut_diameter = 11.55;

chef_hat = ["src_models/Fred_chef.stl", [30, 35, 40], [0, 0, -2.11]];
top_hat = ["src_models/fixed_Fred_the_Frog_with_a_Top_Hat.stl", [30, 35, 40], [0, 2, -2.11]];
resculpted = ["src_models/FredResculpted.stl", [30, 35, 25], [0, 0, -0.11]];
snail = ["src_models/fixed_FredthefrogbutSnail2.stl", [44, 56, 40], [0, -13, -0.11]];
crystal = ["src_models/Crystal_frog-2.stl", [30, 35, 30], [0, 0, -2.11]];
sunhat = ["src_models/fixed_FredTheFrogButSunhat.stl", [30, 35, 30], [-0, -0, -0.11]];
cold = ["src_models/fixed_Fred_but_cold.stl", [30, 37, 30], [-0, -0, 12.5]];

data = chef_hat;

model_file = data[0];
mold_size = data[1];
pos_adjustment = data[2];

// cutout ridge for alignment
ridge_depth = 5;
ridge_thickness = 2;
fudge = 0.01;

// add side bars for screwholes to tighten the mold
side_bar_width = nut_diameter + 2;
translate([0, mold_size[1]/4, 0])
    translate([mold_size[0]/2.0+side_bar_width/2.0, 0, -side_bar_width/2.0])
        cube([side_bar_width, mold_size[1]/2.0, side_bar_width], center=true);
// add slope to the side bars to connect them via the corners
translate([mold_size[0]/2.0,0,0])
    scale([1,-1,1])
        rotate([0,0,-90])
            wedge([mold_size[1]/2.0, side_bar_width, mold_size[2]/2.0]);

module boder(fit_dist=0) {
    color("red")
        translate([0,-ridge_depth/2.0, mold_size[2]/2])
            difference() {
                cube([mold_size[0]+fudge, ridge_depth+fit_dist, mold_size[2]+fudge], center=true);
                translate([0,0,-ridge_thickness/2.0])
                    cube([mold_size[0]-ridge_thickness*2-fit_dist, ridge_depth+fudge, mold_size[2]-ridge_thickness+fudge-fit_dist], center=true);
            }
}

//import(model_file);
rotate([0,180,0]) 
    translate([0, 0,-mold_size[2]])
    {
        difference() {
            translate([0, mold_size[1]/4, mold_size[2]/2])
                cube([mold_size[0], mold_size[1]/2.0, mold_size[2]], center=true);
            translate(pos_adjustment)
                           import(model_file);
        }
        boder();

        translate([mold_size[0]+5, 0, 0])
            rotate([0,0,180])
                difference() {
                    translate([0, -mold_size[1]/4, mold_size[2]/2])
                        cube([mold_size[0], mold_size[1]/2.0, mold_size[2]], center=true);
                    boder(fit_dist=0.1);
                    translate(pos_adjustment)
                       import(model_file);
                }
    }

