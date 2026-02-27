# SPDX-FileCopyrightText: 2026 Rafael G. Martins <rafael@rafaelmartins.eng.br>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.25)

include(FetchContent)

FetchContent_Declare(usbd_fs_stm32
    GIT_REPOSITORY https://github.com/rafaelmartins/usbd-fs-stm32.git
    GIT_TAG 4a1295d85854eaa0729ba3e531d1fa69adfa0025
)
FetchContent_MakeAvailable(
    usbd_fs_stm32
)

add_executable(fightstick
    bootloader.c
    descriptors.c
    idle.c
    main.c
)

target_compile_definitions(usbd-fs-stm32 INTERFACE
    USBD_EP1_IN_SIZE=64
    USBD_EP1_TYPE=INTERRUPT
)

target_link_libraries(fightstick PRIVATE
    usbd-fs-stm32
)

target_compile_options(fightstick PRIVATE
    -Wall
    -Wextra
    -Werror
)

set_property(TARGET fightstick
    PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE
)

cmsis_stm32_target(fightstick
    DEVICE STM32F042x6
    VERSION 20251118033700
    LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/STM32F042KxTx_FLASH.ld
    ADDITIONAL_OUTPUTS BIN MAP IHEX DFU
    SHOW_SIZE ON
    STLINK ON
    INSTALL ON
)

