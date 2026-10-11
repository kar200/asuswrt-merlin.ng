/* SPDX-License-Identifier: GPL-2.0+ */
#include <common.h>
#include <asm/gpio.h>
#include <sercomm_led.h>

#if !defined(CONFIG_SPL_BUILD)

#define GPIO_STATUS_EN    2
#define GPIO_STATUS_R     27
#define GPIO_STATUS_G     59
#define GPIO_STATUS_B     22

#define GPIO_INET_G       1
#define GPIO_INET_R       62

static int g_led_gpios_requested = 0;

static void init_led_gpios(void)
{
	if (g_led_gpios_requested)
		return;

	gpio_request(GPIO_STATUS_EN, "status_en");
	gpio_request(GPIO_STATUS_R, "status_r");
	gpio_request(GPIO_STATUS_G, "status_g");
	gpio_request(GPIO_STATUS_B, "status_b");

	gpio_request(GPIO_INET_G, "inet_g");
	gpio_request(GPIO_INET_R, "inet_r");

	/* Turn off Internet LEDs */
	gpio_direction_output(GPIO_INET_G, 1);
	gpio_direction_output(GPIO_INET_R, 1);

	/* Turn off other peripheral LEDs: Phone (0, 13), IPTV (7), WPS (8, 9, 10) */
	gpio_request(0, "phone2_g");
	gpio_direction_output(0, 1);
	gpio_request(13, "phone1_g");
	gpio_direction_output(13, 1);
	gpio_request(7, "iptv_g");
	gpio_direction_output(7, 1);
	gpio_request(8, "wps_r");
	gpio_direction_output(8, 1);
	gpio_request(9, "wps_g");
	gpio_direction_output(9, 1);
	gpio_request(10, "wps_b");
	gpio_direction_output(10, 1);

	g_led_gpios_requested = 1;
}

void sercomm_status_led_set(enum sercomm_status_led_color color)
{
	init_led_gpios();

	switch (color) {
	case STATUS_LED_AMBER: /* Red + Green (Yellow) */
		gpio_direction_output(GPIO_STATUS_EN, 0);
		gpio_direction_output(GPIO_STATUS_R, 0);
		gpio_direction_output(GPIO_STATUS_G, 0);
		gpio_direction_output(GPIO_STATUS_B, 1);
		break;
	case STATUS_LED_BLUE:  /* Blue only */
		gpio_direction_output(GPIO_STATUS_EN, 0);
		gpio_direction_output(GPIO_STATUS_R, 1);
		gpio_direction_output(GPIO_STATUS_G, 1);
		gpio_direction_output(GPIO_STATUS_B, 0);
		break;
	case STATUS_LED_GREEN: /* Green only */
		gpio_direction_output(GPIO_STATUS_EN, 0);
		gpio_direction_output(GPIO_STATUS_R, 1);
		gpio_direction_output(GPIO_STATUS_G, 0);
		gpio_direction_output(GPIO_STATUS_B, 1);
		break;
	case STATUS_LED_WHITE: /* Red + Green + Blue */
		gpio_direction_output(GPIO_STATUS_EN, 0);
		gpio_direction_output(GPIO_STATUS_R, 0);
		gpio_direction_output(GPIO_STATUS_G, 0);
		gpio_direction_output(GPIO_STATUS_B, 0);
		break;
	case STATUS_LED_RED:   /* Red only */
		gpio_direction_output(GPIO_STATUS_EN, 0);
		gpio_direction_output(GPIO_STATUS_R, 0);
		gpio_direction_output(GPIO_STATUS_G, 1);
		gpio_direction_output(GPIO_STATUS_B, 1);
		break;
	case STATUS_LED_OFF:
	default:
		gpio_direction_output(GPIO_STATUS_EN, 1);
		gpio_direction_output(GPIO_STATUS_R, 1);
		gpio_direction_output(GPIO_STATUS_G, 1);
		gpio_direction_output(GPIO_STATUS_B, 1);
		break;
	}
}

void sercomm_internet_led_set(int link_up)
{
	init_led_gpios();

	/* Keep internet LEDs OFF in U-Boot */
	gpio_direction_output(GPIO_INET_G, 1); /* Green OFF */
	gpio_direction_output(GPIO_INET_R, 1); /* Red OFF */
}

#endif /* !CONFIG_SPL_BUILD */

