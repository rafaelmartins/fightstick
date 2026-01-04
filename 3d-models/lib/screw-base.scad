/*
 * SPDX-FileCopyrightText: 2026 Rafael G. Martins <rafael@rafaelmartins.eng.br>
 * SPDX-License-Identifier: CERN-OHL-S-2.0
 */

module screw_base(dim, screw_d, screw_h) {
    translate([0, 0, -screw_h])
        difference() {
            translate([-dim / 2, -dim / 2, 0]) {
                rotate([-90, 0, 0])
                    linear_extrude(dim)
                        polygon([[0, 0], [0, dim], [dim, 0]]);

                cube([dim, dim, screw_h]);
            }

            cylinder(h=screw_h, d=screw_d * 0.9);
        }
}
