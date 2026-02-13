# Assembly

The fightstick consists of a 3D-printed enclosure, Sanwa arcade components, and a [stm32f0-usbd-devboard](@@/p/stm32-usbd-devboards/stm32f0/) connected via point-to-point wiring. All buttons and the joystick microswitches connect to GPIO pins using the internal pull-up resistors of the STM32F042K4 -- no external resistors or additional circuitry is needed.

## Parts list

| Part | Quantity | Description |
|------|----------|-------------|
| [stm32f0-usbd-devboard](@@/p/stm32-usbd-devboards/stm32f0/) | 1 | STM32F042K4-based USB development board |
| Sanwa JLF-TP-8YT | 1 | Joystick lever with 5-pin wiring harness |
| Sanwa OBSF-30 | 8 | 30 mm pushbuttons (game buttons) |
| Sanwa OBSF-24 | 4 | 24 mm pushbuttons (control buttons) |
| M4 screws with nuts | 4 | Joystick mounting screws |
| M3 self-tapping screws | 11 | Enclosure base plate screws |
| M2 self-tapping screws | 4 | Development board mounting screws |

## 3D-printed enclosure

The enclosure is a two-part design modeled in OpenSCAD: a panel (top shell with button/joystick cutouts) and a flat base plate. The source files are in the `3d-models/` directory.

| File | Description |
|------|-------------|
| `panel.scad` | Top shell with joystick mounting, button holes, USB cutout, and screw bases |
| `base.scad` | Flat base plate with screw holes |
| `settings.scad` | Shared dimensions and parameters |

The enclosure dimensions are 250 mm x 180 mm x 50 mm with 3 mm wall thickness. The panel includes:

- 1x 22 mm joystick shaft hole with 4x M4 mounting posts
- 8x 30 mm game button holes in a staggered fighting game layout
- 4x 24 mm control button holes on the back face
- A USB connector cutout on the left side wall
- A 3.2 mm LED hole on the left side wall
- M2 screw standoffs for the development board
- M3 screw bases for the base plate

Pre-generated STL files (`panel.stl` and `base.stl`) are included in the repository.

## Wiring

Each button and joystick microswitch connects between the corresponding devboard GPIO pin and GND. All GPIO inputs use the MCU's internal pull-up resistors, so no external pull-ups are needed. When a button is pressed, it pulls the pin to ground.

### Devboard pin assignments

```
                          DEVBOARD
                +--------------------------+
                |          +----+          |
                |          |USB |          |
                |          +----+          |
  GND <---------| 1  (GND)       (GND)  24 |---------> GND
                | 2  (3V3)       (+5V)  23 |
 LEFT <---------| 3  (B3)        (A10)  22 |
RIGHT <---------| 4  (B4)         (A9)  21 |---------> BTN12
 DOWN <---------| 5  (B5)         (A8)  20 |---------> BTN11
   UP <---------| 6  (B6)         (B1)  19 |---------> BTN10
                | 7  (B7)         (B0)  18 |---------> BTN09
                | 8  (F1)         (A7)  17 |---------> BTN08
                | 9  (F0)         (A6)  16 |---------> BTN07
BTN01 <---------| 10 (A0)         (A5)  15 |---------> BTN06
BTN02 <---------| 11 (A1)         (A4)  14 |---------> BTN05
BTN03 <---------| 12 (A2)         (A3)  13 |---------> BTN04
                +--------------------------+
```

> [!NOTE]
> Pins 7 (B7), 8 (F1), 9 (F0), and 22 (A10) are unused. Pin 2 (3V3) and pin 23 (+5V) are power outputs and must NOT be connected to buttons.

### Joystick wiring

The Sanwa JLF-TP-8YT comes with a 5-pin wiring harness. Connect the joystick harness to the devboard as follows:

| Joystick signal | Devboard pin |
|-----------------|--------------|
| LEFT | Pin 3 (B3) |
| RIGHT | Pin 4 (B4) |
| DOWN | Pin 5 (B5) |
| UP | Pin 6 (B6) |
| GND (black wire) | Pin 1 or 24 (GND) |

### Game buttons (OBSF-30)

The eight 30 mm game buttons are arranged in a staggered layout on the panel. Each button has two terminals: connect one terminal to the corresponding GPIO pin and the other to GND.

| Button | Devboard pin |
|--------|--------------|
| BTN01 | Pin 10 (A0) |
| BTN02 | Pin 11 (A1) |
| BTN03 | Pin 12 (A2) |
| BTN04 | Pin 13 (A3) |
| BTN05 | Pin 14 (A4) |
| BTN06 | Pin 15 (A5) |
| BTN07 | Pin 16 (A6) |
| BTN08 | Pin 17 (A7) |

### Control buttons (OBSF-24)

The four 24 mm control buttons are mounted on the back face of the enclosure. Each button connects the same way as the game buttons.

| Button | Devboard pin |
|--------|--------------|
| BTN09 | Pin 18 (B0) |
| BTN10 | Pin 19 (B1) |
| BTN11 | Pin 20 (A8) |
| BTN12 | Pin 21 (A9) |

> [!NOTE]
> BTN09 and BTN10 have a special function: holding both at power-on enters USB DFU mode for firmware updates. See [Firmware](30_firmware.md) for details.

### Status LED

The development board's on-board LED (PA15) indicates USB enumeration status. It turns on when the device receives a USB address from the host and turns off on USB bus reset. No additional wiring is needed for the LED -- it is visible through a 3.2 mm hole in the left side wall of the enclosure.
