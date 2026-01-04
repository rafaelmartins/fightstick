/*
 * SPDX-FileCopyrightText: 2026 Rafael G. Martins <rafael@rafaelmartins.eng.br>
 * SPDX-License-Identifier: CERN-OHL-S-2.0
 */

include <settings.scad>


translate([0, width, thickness]) rotate([180, 0, 0]) difference() {
    minkowski() {
        translate([panel_cut, panel_cut, 0])
            cube([length - 2 * panel_cut, width - 2 * panel_cut, thickness - 1]);
        cylinder(r=panel_cut, h=1);
    }

    for (i=[0:3])
        if (i != 2)
            translate([base_screw_padding_x + i * base_length_screw_distance, base_screw_dim / 2, 0])
                cylinder(h=thickness, d=base_screw_d * 1.1);

    for (i=[0:3])
        translate([base_screw_padding_x + i * base_length_screw_distance, width - base_screw_dim / 2, 0])
            cylinder(h=thickness, d=base_screw_d * 1.1);

    for (i=[0:1])
         translate([base_screw_dim / 2, base_screw_padding_y + i * base_width_screw_distance, 0])
             cylinder(h=thickness, d=base_screw_d * 1.1);

    for (i=[0:1])
         translate([length - base_screw_dim / 2, base_screw_padding_y + i * base_width_screw_distance, 0])
             cylinder(h=thickness, d=base_screw_d * 1.1);
}
