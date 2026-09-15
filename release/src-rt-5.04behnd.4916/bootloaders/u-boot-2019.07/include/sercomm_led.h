/* SPDX-License-Identifier: GPL-2.0+ */
#ifndef __SERCOMM_LED_H__
#define __SERCOMM_LED_H__

enum sercomm_status_led_color {
	STATUS_LED_OFF,
	STATUS_LED_AMBER,  /* Booting / HW Init: Red + Green */
	STATUS_LED_BLUE,   /* Console Ready / Interactive: Blue */
	STATUS_LED_GREEN,  /* OS / Kernel Handover: Green */
	STATUS_LED_WHITE,  /* Rescue / Recovery: Red + Green + Blue */
	STATUS_LED_RED,    /* Fault / Error: Red */
};

#if !defined(CONFIG_SPL_BUILD)
void sercomm_status_led_set(enum sercomm_status_led_color color);
void sercomm_internet_led_set(int link_up);
#else
static inline void sercomm_status_led_set(enum sercomm_status_led_color color) {}
static inline void sercomm_internet_led_set(int link_up) {}
#endif

#endif /* __SERCOMM_LED_H__ */

