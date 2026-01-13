// SPDX-FileCopyrightText: 2026 Rafael G. Martins <rafael@rafaelmartins.eng.br>
// SPDX-License-Identifier: BSD-3-Clause

#include <assert.h>
#include <stdlib.h>

#include <stm32f0xx.h>

#include <usbd.h>
#include <usb-std-hid.h>

#include "bootloader.h"
#include "idle.h"

static uint32_t sreport = 0;
static union {
    struct __attribute__((packed)) {
        uint8_t id;
        int8_t x : 2;
        int8_t y : 2;
        bool btn01 : 1;
        bool btn02 : 1;
        bool btn03 : 1;
        bool btn04 : 1;
        bool btn05 : 1;
        bool btn06 : 1;
        bool btn07 : 1;
        bool btn08 : 1;
        bool btn09 : 1;
        bool btn10 : 1;
        bool btn11 : 1;
        bool btn12 : 1;
    } s;
    uint32_t r;
} report = {
    .s.id = 1,
};
static_assert(sizeof(report.s) == 3);


void
clock_init(void)
{
    // 1 flash wait cycle required to operate @ 48MHz (RM0091 section 3.5.1)
    FLASH->ACR &= ~FLASH_ACR_LATENCY;
    FLASH->ACR |= FLASH_ACR_LATENCY;
    while ((FLASH->ACR & FLASH_ACR_LATENCY) != FLASH_ACR_LATENCY);

    RCC->CR2 |= RCC_CR2_HSI48ON;
    while ((RCC->CR2 & RCC_CR2_HSI48RDY) != RCC_CR2_HSI48RDY);

    RCC->CFGR &= ~(RCC_CFGR_HPRE | RCC_CFGR_PPRE | RCC_CFGR_SW);
    RCC->CFGR |= RCC_CFGR_HPRE_DIV1 | RCC_CFGR_PPRE_DIV1 | RCC_CFGR_SW_HSI48;
    while((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_HSI48);

    SystemCoreClock = 48000000;
}


void
usbd_in_cb(uint8_t ept)
{
    if (ept != 1)
        return;

    // B3 - LEFT
    // B4 - RIGHT
    // B5 - DOWN
    // B6 - UP
    // A0 - BTN01
    // A1 - BTN02
    // A2 - BTN03
    // A3 - BTN04
    // A4 - BTN05
    // A5 - BTN06
    // A6 - BTN07
    // A7 - BTN08
    // B0 - BTN09
    // B1 - BTN10
    // A8 - BTN11
    // A9 - BTN12

    report.s.x = (GPIOB->IDR & GPIO_IDR_4) == 0 ? 1 : ((GPIOB->IDR & GPIO_IDR_3) == 0 ? -1 : 0);
    report.s.y = (GPIOB->IDR & GPIO_IDR_5) == 0 ? 1 : ((GPIOB->IDR & GPIO_IDR_6) == 0 ? -1 : 0);
    report.s.btn01 = (GPIOA->IDR & GPIO_IDR_0) == 0;
    report.s.btn02 = (GPIOA->IDR & GPIO_IDR_1) == 0;
    report.s.btn03 = (GPIOA->IDR & GPIO_IDR_2) == 0;
    report.s.btn04 = (GPIOA->IDR & GPIO_IDR_3) == 0;
    report.s.btn05 = (GPIOA->IDR & GPIO_IDR_4) == 0;
    report.s.btn06 = (GPIOA->IDR & GPIO_IDR_5) == 0;
    report.s.btn07 = (GPIOA->IDR & GPIO_IDR_6) == 0;
    report.s.btn08 = (GPIOA->IDR & GPIO_IDR_7) == 0;
    report.s.btn09 = (GPIOB->IDR & GPIO_IDR_0) == 0;
    report.s.btn10 = (GPIOB->IDR & GPIO_IDR_1) == 0;
    report.s.btn11 = (GPIOA->IDR & GPIO_IDR_8) == 0;
    report.s.btn12 = (GPIOA->IDR & GPIO_IDR_9) == 0;

    if (idle_request() || report.r != sreport) {
        sreport = report.r;
        usbd_in(ept, &report.s, sizeof(report.s));
    }
}


bool
usbd_ctrl_request_handle_class_cb(usb_ctrl_request_t *req)
{
    switch (req->bRequest) {
    case USB_REQ_HID_SET_IDLE:
        if (((req->bmRequestType & USB_REQ_DIR_MASK) == USB_REQ_DIR_DEVICE_TO_HOST) ||
            (req->wIndex != 0) ||
            ((((uint8_t) req->wValue) != 0) && (((uint8_t) req->wValue) != 1)))
            break;

        idle_set((uint8_t) (req->wValue >> 8));
        return true;

    case USB_REQ_HID_GET_IDLE:
        {
            if (((req->bmRequestType & USB_REQ_DIR_MASK) == USB_REQ_DIR_HOST_TO_DEVICE) ||
                (req->wIndex != 0) ||
                ((((uint8_t) req->wValue) != 0) && (((uint8_t) req->wValue) != 1)))
                break;

            uint8_t data = idle_get();
            usbd_control_in(&data, sizeof(data), req->wLength);
            return true;
        }
    }
    return false;
}


void
usbd_reset_hook_cb(bool before)
{
    if (!before)
        return;

    sreport = 0;
    GPIOA->BSRR = GPIO_BSRR_BR_15;
}


void
usbd_set_address_hook_cb(uint8_t addr)
{
    (void) addr;
    GPIOA->BSRR = GPIO_BSRR_BS_15;
}


int
main(void)
{
    bootloader_entry();

    RCC->AHBENR |= RCC_AHBENR_GPIOAEN | RCC_AHBENR_GPIOBEN;

    GPIOA->MODER &= ~GPIO_MODER_MODER15;
    GPIOA->MODER |= GPIO_MODER_MODER15_0;
    GPIOA->BSRR = GPIO_BSRR_BR_15;

    GPIOA->PUPDR |=
        GPIO_PUPDR_PUPDR0_0 | GPIO_PUPDR_PUPDR1_0 | GPIO_PUPDR_PUPDR2_0 |
        GPIO_PUPDR_PUPDR3_0 | GPIO_PUPDR_PUPDR4_0 | GPIO_PUPDR_PUPDR5_0 |
        GPIO_PUPDR_PUPDR6_0 | GPIO_PUPDR_PUPDR7_0 | GPIO_PUPDR_PUPDR8_0 |
        GPIO_PUPDR_PUPDR9_0;
    GPIOB->PUPDR |=
        GPIO_PUPDR_PUPDR0_0 | GPIO_PUPDR_PUPDR1_0 | GPIO_PUPDR_PUPDR3_0 |
        GPIO_PUPDR_PUPDR4_0 | GPIO_PUPDR_PUPDR5_0 | GPIO_PUPDR_PUPDR6_0;

    // wait a little bit until the pull-ups are stable.
    for (__IO uint16_t i = 0xffff; i; i--);

    if ((GPIOB->IDR & (GPIO_IDR_0 | GPIO_IDR_1)) == 0)
        bootloader_reset();

    clock_init();
    idle_init();
    usbd_init();

    while (true)
        usbd_task();

    return 0;
}
