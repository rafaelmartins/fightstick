# Firmware

The fightstick firmware is a bare-metal C application targeting the STM32F042K4 microcontroller on the [stm32f0-usbd-devboard](@@/p/stm32-usbd-devboards/stm32f0/). It implements a USB HID gamepad with a 2-axis digital joystick and 12 buttons. The firmware uses no HAL or RTOS -- it directly accesses peripheral registers via CMSIS headers and relies on the [usbd-fs-stm32](@@/p/usbd-fs-stm32/) library for USB device functionality.

## Building from source

### Prerequisites

- CMake 3.25 or later
- ARM GNU Toolchain (`arm-none-eabi`)
- Ninja (recommended) or Make

The build system automatically fetches [cmake-cmsis-stm32](@@/p/cmake-cmsis-stm32/) and [usbd-fs-stm32](@@/p/usbd-fs-stm32/) via CMake's FetchContent mechanism. No manual dependency installation is needed beyond the toolchain.

### Configure and build

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -G Ninja
cmake --build build
```

### Output artifacts

| File | Description |
|------|-------------|
| `fightstick.elf` | ELF binary |
| `fightstick.bin` | Raw binary |
| `fightstick.hex` | Intel HEX |
| `fightstick.dfu` | DFU with suffix (for `dfu-util`) |
| `fightstick.map` | Linker map |

### Memory layout

| Region | Start address | Size |
|--------|---------------|------|
| Flash | `0x08000000` | 16 KB |
| RAM | `0x20000000` | 6 KB |

## Flashing

### Using ST-Link

See the [Hardware Build Manual](@@/hardware/build-manual/) for general ST-Link instructions. The cmake target for ST-Link flashing using `st-flash` binary from the open-source `stlink` tools:

```bash
cmake --build build --target fightstick-stlink-write
```

### Using USB DFU

The STM32F042K4 has a built-in USB DFU bootloader in system memory. There are two ways to enter DFU mode:

- **Empty MCU** -- a new, unprogrammed STM32F042K4 boots directly into its system memory DFU bootloader, so it is ready to flash immediately
- **Button combination** -- hold BTN09 (pin 18, B0) and BTN10 (pin 19, B1) simultaneously while powering on or resetting the device

When the firmware detects both BTN09 and BTN10 held at startup, it writes a magic value (`0xdeadbeef`) to an RTC backup register and triggers a software reset. On the subsequent boot, the firmware reads this value and jumps to the system bootloader at `0x1FFFC400`.

See the [Hardware Build Manual](@@/hardware/build-manual/) for general DFU flashing instructions using `dfu-util`.

## Architecture overview

### Clock configuration

The firmware configures the system clock to use the HSI48 internal oscillator directly at 48 MHz with no PLL. Both AHB and APB buses run at 48 MHz (prescaler /1). One flash wait state is enabled as required for 48 MHz operation.

### Peripheral map

| Peripheral | Function |
|------------|----------|
| GPIOA PA0--PA9 | Button inputs (BTN01--BTN08, BTN11, BTN12) with internal pull-ups |
| GPIOA PA15 | Status LED output (active high) |
| GPIOB PB0--PB1 | Button inputs (BTN09, BTN10) with internal pull-ups |
| GPIOB PB3--PB6 | Joystick direction inputs (LEFT, RIGHT, DOWN, UP) with internal pull-ups |
| TIM17 | HID idle rate timer (one-pulse mode) |
| USB | Full-speed USB device peripheral |
| RTC BKP0R | Bootloader entry flag register |

### Main loop

The `main()` function initializes GPIO ports with pull-ups, checks for the DFU button combination, then configures the clock, idle timer, and USB peripheral. The main loop calls `usbd_task()` continuously to process USB events.

On each USB IN token for endpoint 1, the `usbd_in_cb()` callback reads all 16 GPIO inputs and constructs the HID report. The report is only sent when the input state changes or when the HID idle timer expires, reducing unnecessary USB traffic.

### Main source files

| File | Purpose |
|------|---------|
| `main.c` | GPIO initialization, clock setup, USB callbacks, input polling, and main loop |
| `descriptors.c` | USB device, configuration, interface, HID, and endpoint descriptors; HID report descriptor; string descriptors |
| `bootloader.c` | DFU bootloader entry logic using RTC backup register and system memory jump |
| `idle.c` | HID idle rate implementation using TIM17 in one-pulse mode |

## USB HID protocol

### Device identity

| Field | Value |
|-------|-------|
| USB version | 2.0 Full-Speed |
| Device class | HID (interface-level) |
| VID | `0x1d50` |
| PID | `0x619a` |
| Manufacturer | rgm.io |
| Product | fightstick |
| Serial number | STM32 internal unique ID |
| Max power | 40 mA (bus-powered) |
| HID version | 1.11 |

### Endpoints

| Direction | Type | Max packet size | Interval |
|-----------|------|-----------------|----------|
| EP1 IN | Interrupt | 64 bytes | 1 ms |

### HID report descriptor

The device uses the Generic Desktop / Gamepad usage page with a single input report.

| Report ID | Kind | Size | Description |
|-----------|------|------|-------------|
| 1 | Input | 2 bytes (+ 1 byte report ID) | Joystick axes and buttons |

Report layout (3 bytes total):

| Byte | Bits | Field | Values |
|------|------|-------|--------|
| 0 | 7:0 | Report ID | Always `0x01` |
| 1 | 1:0 | X axis | -1 (left), 0 (center), 1 (right) |
| 1 | 3:2 | Y axis | -1 (up), 0 (center), 1 (down) |
| 1 | 4 | Button 1 | 0 = released, 1 = pressed |
| 1 | 5 | Button 2 | 0 = released, 1 = pressed |
| 1 | 6 | Button 3 | 0 = released, 1 = pressed |
| 1 | 7 | Button 4 | 0 = released, 1 = pressed |
| 2 | 0 | Button 5 | 0 = released, 1 = pressed |
| 2 | 1 | Button 6 | 0 = released, 1 = pressed |
| 2 | 2 | Button 7 | 0 = released, 1 = pressed |
| 2 | 3 | Button 8 | 0 = released, 1 = pressed |
| 2 | 4 | Button 9 | 0 = released, 1 = pressed |
| 2 | 5 | Button 10 | 0 = released, 1 = pressed |
| 2 | 6 | Button 11 | 0 = released, 1 = pressed |
| 2 | 7 | Button 12 | 0 = released, 1 = pressed |

### Idle rate

The firmware implements HID Set_Idle and Get_Idle requests. The default idle rate is 500 ms (idle value 125). When the idle rate is non-zero, the firmware sends the current report periodically even if no input state has changed. When set to 0, reports are only sent on input changes.
