///* [Rendering options] */
// Show placeholder PCB in OpenSCAD preview
show_pcb = false;
// Lid mounting method
lid_model = "cap"; // [cap, inner-fit]
// Conditional rendering
render = "case"; // [all, case, lid]

/* [Dimensions] */
// Height of the PCB mounting stand-offs between the bottom of the case and the PCB
standoff_height = 5;
// PCB thickness
pcb_thickness = 1.6;
// Bottom layer thickness
floor_height = 2;
// Case wall thickness
wall_thickness = 2;
// Space between the top of the PCB and the top of the case
headroom = 45;

/* [Hidden] */
$fa = $preview ? 10 : 4;
$fs = 0.2;
inner_height = floor_height + standoff_height + pcb_thickness + headroom;

module centered_hole_diameter(center_x, center_y, diameter)
{ // These holes are in the kicad coord system
    coords = [ center_x, center_y ];
    translate([ coords[0], coords[1], -0.5 ]){
        cylinder(h = floor_height + 1, d = diameter, center = false);
        cylinder(h = floor_height, d1 = diameter + 6, d2 = diameter, center = false);
    }
}

module centered_hole_radius(center_x, center_y, center_z, radius)
{ // These holes are in the kicad coord system
    coords = [ center_x, center_y ];
    translate([ coords[0], coords[1], center_z ])
    {
    cylinder(h = (floor_height + 1) * 2, r = radius, center = false);
    // translate([0, 0, -0.6]) 
    cylinder(h = (floor_height), r1 = radius +3, r2 = radius,  center = false);
    }
}

module wall(thickness, height)
{
    linear_extrude(height, convexity = 10)
    {
        difference()
        {
            offset(r = thickness) children();
            children();
        }
    }
}

module bottom(thickness, height)
{
    linear_extrude(height, convexity = 3)
    {
        offset(r = thickness) children();
    }
}

module joystick()
{
    centered_hole_diameter(center_x = 114.835, center_y = 116.42, diameter = 1.2);
    centered_hole_diameter(center_x = 117.335, center_y = 116.42, diameter = 1.2);
    centered_hole_diameter(center_x = 119.835, center_y = 116.42, diameter = 1.2);

    // Right Side data holes
    centered_hole_diameter(center_x = 126.065, center_y = 122.65, diameter = 1.2);
    centered_hole_diameter(center_x = 126.065, center_y = 125.15, diameter = 1.2);
    centered_hole_diameter(center_x = 126.065, center_y = 127.65, diameter = 1.2);

    // Button holes
    centered_hole_diameter(center_x = 114.085, center_y = 130.9, diameter = 1.4);
    centered_hole_diameter(center_x = 120.585, center_y = 130.9, diameter = 1.4);
    centered_hole_diameter(center_x = 114.085, center_y = 135.4, diameter = 1.4);
    centered_hole_diameter(center_x = 120.585, center_y = 135.4, diameter = 1.4);

    // Mounting holes
    centered_hole_diameter(center_x = 111.01, center_y = 120.15, diameter = 1.5);
    centered_hole_diameter(center_x = 123.66, center_y = 120.15, diameter = 1.5);
    centered_hole_diameter(center_x = 111.01, center_y = 130.15, diameter = 1.5);
    centered_hole_diameter(center_x = 123.66, center_y = 130.15, diameter = 1.5);
}

module slider(recess_depth, recess_width, recess_length, recess_x, recess_y, reccess_w_l_offset)
{

    translate([ recess_x, recess_y, 0 ])
    {
        difference()
        {
            difference()
            {
                // Outer shell of recess
                translate([ 0, 0, -recess_depth ])
                    cube([ recess_width + 2 * wall_thickness, recess_length + 2 * wall_thickness, recess_depth ]);
                // Inner cavity of recess
                translate([ wall_thickness, wall_thickness, -recess_depth + wall_thickness ])
                    cube([ recess_width, recess_length, recess_depth + 1 ]);
            }

            // Inner hole coords
            data_pin_x = (recess_width - 3.75) / 2 + wall_thickness;
            data_pin_y_top = wall_thickness + reccess_w_l_offset / 2;

            recess_center_y = wall_thickness + reccess_w_l_offset / 2 + 127.5 / 2;

            centered_hole_radius(center_x = data_pin_x, center_y = data_pin_y_top, center_z = -(recess_depth + 1),
                                 radius = 0.8);

            // Pins
            centered_hole_radius(center_x = data_pin_x, center_y = data_pin_y_top + 127.5,
                                 center_z = -(recess_depth + 1), radius = 0.8);
            centered_hole_radius(center_x = data_pin_x + 3.75, center_y = data_pin_y_top + 127.5,
                                 center_z = -(recess_depth + 1), radius = 0.8);

            // Bottom Hole
            centered_hole_radius(center_x = recess_width / 2 + wall_thickness, center_y = recess_center_y + 42.1,
                                 center_z = -(recess_depth + 1), radius = 1);

            // Top hole
            centered_hole_radius(center_x = recess_width / 2 + wall_thickness, center_y = recess_center_y - 40.1,
                                 center_z = -(recess_depth + 1), radius = 1);
        }
    }
}

module lid(thickness, height, edge)
{
    reccess_w_l_offset = 4; // Offset of the recess with 4 because of 3d printer limitations
    recess_depth = 8;       // How far the recess protrudes down
    recess_width = 8.4 + reccess_w_l_offset;
    recess_length = 128 + reccess_w_l_offset;
    recess_x = 5; // X position of the recess
    recess_y = 0; // Y position of the recess

    difference()
    {
        union()
        {
            // Main lid body
            linear_extrude(height, convexity = 10)
            {
                offset(r = thickness) children();
            }

            // Edge lip
            translate([ 0, 0, -edge ]) difference()
            {
                linear_extrude(edge, convexity = 10)
                {
                    offset(r = -0.2) children();
                }
                translate([ 0, 0, -0.5 ]) linear_extrude(edge + 1, convexity = 10)
                {
                    offset(r = -1.2) children();
                }
            }

            // Add the slider in the recess
            slider(recess_depth, recess_width, recess_length, recess_x, recess_y, reccess_w_l_offset);
        }

        // Extrude inner cavity from rest of lid
        translate([ recess_x, recess_y, 0 ])
            translate([ wall_thickness, wall_thickness, -recess_depth + wall_thickness ])
                cube([ recess_width, recess_length, recess_depth + 1 + wall_thickness ]);

        // === Logo ===
        translate([ 80, 22, height - 1 ]) linear_extrude(1.1)
        {
            offset(r = 0.1) scale([ 0.12, -0.12, 1 ]) import("case-logo.svg", center = true);
        }

        // === Buttons ===
        translate([ 55, 119, height - 5 ]) cylinder(r = 33.3 / 2, h = 10, $fn = 6);

        // === Joystick ===
        translate([ 0, 0, 0 ]) joystick();
    }
}

module box(wall_thick, bottom_layers, height)
{
    if (render == "all" || render == "case")
    {
        difference()
        {
            union()
            {
                translate([ 0, 0, bottom_layers ]) wall(wall_thick, height) children();
                bottom(wall_thick, bottom_layers) children();
            }
        }
    }

    if (render == "all" || render == "lid")
    {
        translate([ 0, 0, height + bottom_layers + 0.1 ])
            lid(wall_thick, bottom_layers, lid_model == "inner-fit" ? headroom - 2.5 : bottom_layers) children();
    }
}

module mount(drill, space, height)
{
    translate([ 0, 0, height / 2 ]) difference()
    {
        cylinder(h = height, r = (space / 2), center = true);
        cylinder(h = (height * 2), r = (drill / 2), center = true);

        translate([ 0, 0, height / 2 + 0.01 ]) children();
    }
}

module connector(min_x, min_y, max_x, max_y, height)
{
    size_x = max_x - min_x;
    size_y = max_y - min_y;
    translate([ (min_x + max_x) / 2, (min_y + max_y) / 2, height / 2 ]) cube([ size_x, size_y, height ], center = true);
}

module pcb()
{
    thickness = 1.6;

    color("#009900") difference()
    {
        linear_extrude(thickness)
        {
            polygon(points = [ [ 0, 0 ], [ 135.48, 0 ], [ 135.48, 143.5 ], [ 0, 143.5 ] ]);
        }
    }
}

module case_outline()
{
    polygon(points = [ [ -1, -1 ], [ 136.48, -1 ], [ 136.48, 144.5 ], [ -1, 144.5 ] ]);
}

rotate([ render == "lid" ? 180 : 0, 0, 0 ]) scale([ 1, -1, 1 ]) translate([ -67.74, -71.75, 0 ])
{
    pcb_top = floor_height + standoff_height + pcb_thickness;

    difference()
    {
        box(wall_thickness, floor_height, inner_height)
        {
            case_outline();
        }

        // Add square hole in wall at y=0
        // Accounting for the translation and scaling
        scale([ 1, -1, 1 ])                          // Match the case's scaling
            translate([ 68.74 - 8, 0, 30 ])          // Position relative to the case
            cube([ 16, wall_thickness * 2 + 1, 3 ]); // Make hole slightly wider than wall
    }

    if (show_pcb && $preview)
    {
        translate([ 0, 0, floor_height + standoff_height ]) pcb();
    }
}