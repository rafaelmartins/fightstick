/*
 * SPDX-FileCopyrightText: 2026 Rafael G. Martins <rafael@rafaelmartins.eng.br>
 * SPDX-License-Identifier: CERN-OHL-S-2.0
 */

include <lib/screw-base.scad>
include <settings.scad>


difference() {
    union() {
        difference() {
            minkowski() {
                translate([panel_cut, panel_cut, 0])
                    cube([length - 2 * panel_cut, width - 2 * panel_cut, height - thickness - panel_cut]);
                cylinder(r1=0, r2=panel_cut, h=panel_cut);
            }

            translate([0, 0, thickness])
                minkowski() {
                    translate([panel_cut, panel_cut, 0])
                        cube([length - 2 * panel_cut, width - 2 * panel_cut, height - thickness - panel_cut]);
                    cylinder(r1=0, r2=panel_cut - thickness, h=panel_cut - thickness);
                }
        }

        translate([joystick_x0, joystick_y0, 0]) {
            translate([-joystick_width_screw_d / 2, -joystick_length_screw_d / 2, 0])
                cylinder(h=thickness + joystick_screw_base_h, d=joystick_screw_base_d);
            translate([-joystick_width_screw_d / 2, joystick_length_screw_d / 2, 0])
                cylinder(h=thickness + joystick_screw_base_h, d=joystick_screw_base_d);
            translate([joystick_width_screw_d / 2, -joystick_length_screw_d / 2, 0])
                cylinder(h=thickness + joystick_screw_base_h, d=joystick_screw_base_d);
            translate([joystick_width_screw_d / 2, joystick_length_screw_d / 2, 0])
                cylinder(h=thickness + joystick_screw_base_h, d=joystick_screw_base_d);
        }

        for (i=[0:3])
            if (i != 2)
                translate([base_screw_padding_x + i * base_length_screw_distance, base_screw_dim / 2, height - thickness])
                    rotate([0, 0, 90])
                        screw_base(dim=base_screw_dim, screw_d=base_screw_d, screw_h=base_screw_h);

        for (i=[0:3])
            translate([base_screw_padding_x + i * base_length_screw_distance, width - base_screw_dim / 2, height - thickness])
                rotate([0, 0, -90])
                    screw_base(dim=base_screw_dim, screw_d=base_screw_d, screw_h=base_screw_h);

        for (i=[0:1])
             translate([base_screw_dim / 2, base_screw_padding_y + i * base_width_screw_distance, height - thickness])
                 screw_base(dim=base_screw_dim, screw_d=base_screw_d, screw_h=base_screw_h);

        for (i=[0:1])
             translate([length - base_screw_dim / 2, base_screw_padding_y + i * base_width_screw_distance, height - thickness])
                 rotate([0, 0, 180])
                     screw_base(dim=base_screw_dim, screw_d=base_screw_d, screw_h=base_screw_h);

        for (i=[0:1])
            for (j=[0:1])
                translate([devboard_pcb_padding_x + devboard_screw_padding_front_x + i * devboard_screw_distance_x,
                           devboard_pcb_padding_y + devboard_screw_padding_y + j * devboard_screw_distance_y,
                           thickness])
                    cylinder(h=devboard_screw_base_h, d=devboard_screw_base_d);

        translate([devboard_base_distance_x, devboard_base_distance_y, thickness])
            cube([devboard_base_length, devboard_base_width, devboard_base_height]);
    }

    for (i=[0:1])
        for (j=[0:1])
            translate([devboard_pcb_padding_x + devboard_screw_padding_front_x + i * devboard_screw_distance_x,
                       devboard_pcb_padding_y + devboard_screw_padding_y + j * devboard_screw_distance_y,
                       thickness])
                cylinder(h=devboard_screw_base_h, d=devboard_screw_d * 0.9);

    translate([0, devboard_pcb_padding_y + devboard_width - devboard_distance_usb - usb_width / 2,
               thickness + devboard_screw_base_h - usb_height + 0.2])
        cube([thickness, usb_width, usb_height]);

    translate([0, devboard_pcb_padding_y + devboard_width - devboard_distance_led,
               thickness + devboard_screw_base_h - led_d / 2])
        rotate([-90, 0, -90])
            cylinder(h=thickness, d=led_d);

    translate([base_screw_padding_x + base_length_screw_distance, 0, 3 + (height - thickness) / 2])
        for (i=[0:button_control_count - 1])
            translate([(2 * base_length_screw_distance - (button_control_count - 1) * button_control_distance) / 2 +
                       i * button_control_distance, 0, 0])
                rotate([-90, 0, 0])
                    cylinder(h=thickness + 0.1, d=button_control_d);

    translate([joystick_x0, joystick_y0, 0]) {
        cylinder(h=thickness, d=joystick_hole_d);

        translate([-joystick_width_screw_d / 2, -joystick_length_screw_d / 2, 0]) {
            cylinder(h=joystick_screw_head_h, d=joystick_screw_head_d);
            cylinder(h=thickness + joystick_screw_base_h, d=joystick_screw_d * 1.1);
        }
        translate([-joystick_width_screw_d / 2, joystick_length_screw_d / 2, 0]) {
            cylinder(h=joystick_screw_head_h, d=joystick_screw_head_d);
            cylinder(h=thickness + joystick_screw_base_h, d=joystick_screw_d * 1.1);
        }
        translate([joystick_width_screw_d / 2, -joystick_length_screw_d / 2, 0]) {
            cylinder(h=joystick_screw_head_h, d=joystick_screw_head_d);
            cylinder(h=thickness + joystick_screw_base_h, d=joystick_screw_d * 1.1);
        }
        translate([joystick_width_screw_d / 2, joystick_length_screw_d / 2, 0]) {
            cylinder(h=joystick_screw_head_h, d=joystick_screw_head_d);
            cylinder(h=thickness + joystick_screw_base_h, d=joystick_screw_d * 1.1);
        }

        translate([59, 14, 0]) {
            cylinder(h=thickness, d=button_game_d);
            translate([7, -38.5, 0])
                cylinder(h=thickness, d=button_game_d);
            translate([33, -14, 0]) {
                cylinder(h=thickness, d=button_game_d);
                translate([7, -38.5, 0])
                    cylinder(h=thickness, d=button_game_d);
                translate([36, 6, 0]) {
                    cylinder(h=thickness, d=button_game_d);
                    translate([6.5, -38.5, 0])
                        cylinder(h=thickness, d=button_game_d);
                    translate([34, 15, 0]) {
                        cylinder(h=thickness, d=button_game_d);
                        translate([6.5, -38.5, 0])
                            cylinder(h=thickness, d=button_game_d);
                    }
                }
            }
        }
    }

    translate([usb_cutout_padding_x, usb_cutout_padding_y, usb_cutout_padding_z])
        cube([usb_cutout_thickness, usb_cutout_length, usb_cutout_height]);
}
