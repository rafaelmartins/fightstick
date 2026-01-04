/*
 * SPDX-FileCopyrightText: 2026 Rafael G. Martins <rafael@rafaelmartins.eng.br>
 * SPDX-License-Identifier: CERN-OHL-S-2.0
 */

button_control_count = 4;

length = 250;
width = 180;
height = 50;

thickness = 3;

panel_cut = 10;

button_control_d = 24;
button_control_distance = 30;
button_game_d = 30;

joystick_hole_d = 22;
joystick_width = 53;
joystick_length = 95;
joystick_width_screw_d = 41;
joystick_length_screw_d = 83;

joystick_x0 = 18 + joystick_width / 2;
joystick_y0 = width / 2;

joystick_screw_head_h = 2.8;
joystick_screw_head_d = 7.8;
joystick_screw_d = 4;
joystick_screw_base_h = 2;
joystick_screw_base_d = 25;

base_screw_padding_x = 15;
base_screw_padding_y = 60;
base_screw_dim = 9;
base_screw_d = 3;
base_screw_h = 16;
base_length_screw_distance = (length - 30) / 3;
base_width_screw_distance = (width - 120);

led_d = 3.2;
usb_height = 4.4;
usb_width = 8.2;

usb_cutout_padding_x = 1.6;
usb_cutout_padding_y = 12;
usb_cutout_padding_z = 18;
usb_cutout_thickness = thickness - 1.6;
usb_cutout_length = 28;
usb_cutout_height = 14;

devboard_pcb_height = 1.6;
devboard_width = 23.114;
devboard_length = 51.943;
devboard_screw_padding_front_x = 7.874;
devboard_screw_padding_back_x = 7.366;
devboard_screw_padding_y = 2.921;
devboard_screw_distance_y = 2 * 8.636;
devboard_screw_distance_x = 36.703;
devboard_screw_base_d = 5;
devboard_screw_base_h = height / 2;
devboard_screw_d = 2;
devboard_distance_usb = devboard_screw_padding_y + 8.636;
devboard_distance_led = devboard_screw_padding_y + 1.524;
devboard_pcb_padding_x = 1.7;
devboard_pcb_padding_y = 14;
devboard_base_distance_x = panel_cut - 3;
devboard_base_distance_y = usb_cutout_padding_y + 2.4;
devboard_base_length = devboard_screw_distance_x + 5.1;
devboard_base_width = usb_cutout_length - 5.7;
devboard_base_height = usb_cutout_padding_z - thickness;

$fn=50;
