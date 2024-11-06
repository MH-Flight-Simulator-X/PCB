///* [Rendering options] */
// Show placeholder PCB in OpenSCAD preview
show_pcb = false;
// Lid mounting method
lid_model = "cap"; // [cap, inner-fit]
// Conditional rendering
render = "lid"; // [all, case, lid]


/* [Dimensions] */
// Height of the PCB mounting stand-offs between the bottom of the case and the PCB
standoff_height = 5;
// PCB thickness
pcb_thickness = 1.6;
// Bottom layer thickness
floor_height = 2;
// Case wall thickness
wall_thickness = 1.2;
// Space between the top of the PCB and the top of the case
headroom = 0;

/* [Hidden] */
$fa=$preview ? 10 : 4;
$fs=0.2;
inner_height = floor_height + standoff_height + pcb_thickness + headroom;

module centered_hole_diameter(center_x, center_y, diameter) { // These holes are in the kicad coord system
    coords = [center_x, center_y];
    translate([coords[0], coords[1], -0.5])
        cylinder(h=floor_height + 1, d=diameter, center=false);
}

module centered_hole_radius(center_x, center_y, radius) { // These holes are in the kicad coord system
    coords = [center_x, center_y];
    translate([coords[0], coords[1], -0.5])
        cylinder(h=floor_height + 1, r=radius, center=false);
}

module wall (thickness, height) {
    linear_extrude(height, convexity=10) {
        difference() {
            offset(r=thickness)
                children();
            children();
        }
    }
}

module bottom(thickness, height) {
    linear_extrude(height, convexity=3) {
        offset(r=thickness)
            children();
    }
}

module lid(thickness, height, edge) {
    difference() {
        union() {
            linear_extrude(height, convexity=10) {
                offset(r=thickness)
                    children();
            }
            translate([0,0,-edge])
            difference() {
                linear_extrude(edge, convexity=10) {
                    offset(r=-0.2)
                    children();
                }
                translate([0,0, -0.5])
                linear_extrude(edge+1, convexity=10) {
                    offset(r=-1.2)
                    children();
                }
            }
        }

        // === Logo ===
        // Add this new section for the logo indentation
        translate([106, 22, height-1]) // Adjusted position for larger logo
        linear_extrude(1.1) { // 0.8mm deep indentation
            offset(r=0.1) // Slight offset for cleaner edges
            scale([0.07, -0.07, 1]) // Scale adjusted for complete logo with text
            import("case-logo.svg", center=true);
        }

        // === Buttons ===
        centered_hole_diameter(23, 119, 33.3); 

        // === Slider ===
        // Bottom holes
        centered_hole_radius(center_x = 62.025, center_y = 135.62, radius = 0.8);
        centered_hole_radius(center_x = 65.775, center_y = 135.62, radius = 0.8);

        // Pins
        centered_hole_radius(center_x = 63.9, center_y = 113.97, radius = 1);
        centered_hole_radius(center_x = 63.9, center_y = 31.77, radius = 1);

        // Top hole
        centered_hole_radius(center_x = 62.025, center_y = 8.12, radius = 0.8);


        // === Joystick ===

        // Top data holes
        centered_hole_diameter(center_x = 114.835, center_y = 116.42, diameter = 0.9);
        centered_hole_diameter(center_x = 117.335, center_y = 116.42, diameter = 0.9);
        centered_hole_diameter(center_x = 119.835, center_y = 116.42, diameter = 0.9);

        // Right Side data holes
        centered_hole_diameter(center_x = 126.065, center_y = 122.65, diameter = 0.9);
        centered_hole_diameter(center_x = 126.065, center_y = 125.15, diameter = 0.9);
        centered_hole_diameter(center_x = 126.065, center_y = 127.65, diameter = 0.9);

        // Button holes

        centered_hole_diameter(center_x = 114.085, center_y = 130.9, diameter = 1.2);
        centered_hole_diameter(center_x = 120.585, center_y = 130.9, diameter = 1.2);
        centered_hole_diameter(center_x = 114.085, center_y = 135.4, diameter = 1.2);
        centered_hole_diameter(center_x = 120.585, center_y = 135.4, diameter = 1.2);


        // Mounting holes
        centered_hole_diameter(center_x = 111.01, center_y = 120.15, diameter = 1.5);
        centered_hole_diameter(center_x = 123.66, center_y = 120.15, diameter = 1.5);
        centered_hole_diameter(center_x = 111.01, center_y = 130.15, diameter = 1.5);
        centered_hole_diameter(center_x = 123.66, center_y = 130.15, diameter = 1.5);



        

    }
}


module box(wall_thick, bottom_layers, height) {
    if (render == "all" || render == "case") {
        translate([0,0, bottom_layers])
            wall(wall_thick, height) children();
        bottom(wall_thick, bottom_layers) children();
    }
    
    if (render == "all" || render == "lid") {
        translate([0, 0, height+bottom_layers+0.1])
        lid(wall_thick, bottom_layers, lid_model == "inner-fit" ? headroom-2.5: bottom_layers) 
            children();
    }
}

module mount(drill, space, height) {
    translate([0,0,height/2])
        difference() {
            cylinder(h=height, r=(space/2), center=true);
            cylinder(h=(height*2), r=(drill/2), center=true);
            
            translate([0, 0, height/2+0.01])
                children();
        }
        
}

module connector(min_x, min_y, max_x, max_y, height) {
    size_x = max_x - min_x;
    size_y = max_y - min_y;
    translate([(min_x + max_x)/2, (min_y + max_y)/2, height/2])
        cube([size_x, size_y, height], center=true);
}

module pcb() {
    thickness = 1.6;

    color("#009900")
    difference() {
        linear_extrude(thickness) {
            polygon(points = [[0,0], [135.48,0], [135.48,143.5], [0,143.5]]);
        }
    }
}

module case_outline() {
    polygon(points = [[-1,-1], [136.48,-1], [136.48,144.5], [-1,144.5]]);
}

rotate([render == "lid" ? 180 : 0, 0, 0])
scale([1, -1, 1])
translate([-67.74, -71.75, 0]) {
    pcb_top = floor_height + standoff_height + pcb_thickness;

    difference() {
        box(wall_thickness, floor_height, inner_height) {
            case_outline();
        }

    }

    if (show_pcb && $preview) {
        translate([0, 0, floor_height + standoff_height])
            pcb();
    }

    if (render == "all" || render == "case") {
    }
}
