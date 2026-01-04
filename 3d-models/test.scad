/*
 * SPDX-FileCopyrightText: 2026 Rafael G. Martins <rafael@rafaelmartins.eng.br>
 * SPDX-License-Identifier: CERN-OHL-S-2.0
 */

include <settings.scad>

import("base.stl");

translate([0, width, height])
    rotate([180, 0, 0])
        import("panel.stl");
