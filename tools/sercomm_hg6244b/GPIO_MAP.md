# HG6244B v2 (Sercomm / BCM68360_B1) — GPIO map

Board: Sercomm HG6244B v2, Broadcom BCM68360_B1 (= BCM6856), CFE boardtype `968360BG`.
All numbers below are **SoC GPIO pin numbers**. The only bank exposed is `gpioc`, so
U-Boot writes them as `&gpioc <N>` / `gpioc<N>`, and `<N>` is the same number CFE prints.

## Source of truth

Dumped from the **stock CFE** with `sc_gpio d` (Sercomm's "GPIO Map Table"), and
cross-checked against U-Boot's own `gpio status -a`.

To re-dump:

```
# in CFE (press a key at "Press any key to stop auto run")
sc_gpio d          # whole map table
sc_gpio r <pin>    # read one pin
sc_gpio w <pin> <0|1>
sc_gpio o/i <pin>  # set output / input

# in U-Boot
gpio status -a
gpio input <pin>
```

### Why the two numbering spaces are the same

CFE's table lists 11 LEDs; U-Boot's `gpio status -a` reports those same pins carrying
matching names from `arch/arm/mach-bcmbca/bcm6856/sercomm_led.c`
(`gpioc13=phone1_g`, `gpioc0=phone2_g`, `gpioc8=wps_r`, `gpioc9=wps_g`, `gpioc10=wps_b`,
`gpioc7=iptv_g`, `gpioc62=inet_r`, `gpioc1=inet_g`, `gpioc27=status_r`, `gpioc59=status_g`,
`gpioc22=status_b). That one-to-one agreement confirms `gpioc N` == CFE `GPIO_PIN`.

## Full map (stock CFE `sc_gpio d`)

| Name | CFE ID | GPIO pin | U-Boot name | Direction @ boot |
|---|---|---|---|---|
| PHONE2_LED_G | 2 | 0 | `phone2_g` | output |
| INTERNET_LED_G | 7 | 1 | `inet_g` | output |
| STATUS (enable) | 9 | 2 | `status_en` | output |
| IPTV_LED_G | 6 | 7 | `iptv_g` | output |
| WPS_RGB_R | 3 | 8 | `wps_r` | output |
| WPS_RGB_G | 4 | 9 | `wps_g` | output |
| WPS_RGB_B | 5 | 10 | `wps_b` | output |
| PHONE1_LED_G | 1 | 13 | `phone1_g` | output |
| STATUS_B | 12 | 22 | `status_b` | output |
| **PB_RESET** | **100** | **26** | — | input |
| STATUS_R | 10 | 27 | `status_r` | output |
| **PB_WPS** | **101** | **28** | — | input |
| STATUS_G | 11 | 59 | `status_g` | output |
| INTERNET_LED_R | 8 | 62 | `inet_r` | output |
| **PB_WIFI** | **102** | **81** | — | input |

Buttons are **active low** (idle reads 1).

## U-Boot LED implementation

`arch/arm/mach-bcmbca/bcm6856/sercomm_led.c` (editable source, not a prebuilt blob):

```c
#define GPIO_STATUS_EN    2
#define GPIO_STATUS_R     27
#define GPIO_STATUS_G     59
#define GPIO_STATUS_B     22
#define GPIO_INET_G       1
#define GPIO_INET_R       62
```

It also claims `phone2_g=0`, `phone1_g=13`, `iptv_g=7`, `wps_r=8`, `wps_g=9`, `wps_b=10`.

`sercomm_status_led_set()` drives the RGB status LED. Note all four lines are driven,
and the enable is active low too — the raw levels are:

| colour | EN(2) | R(27) | G(59) | B(22) | meaning |
|---|---|---|---|---|---|
| `STATUS_LED_OFF` | 1 | 1 | 1 | 1 | off |
| `STATUS_LED_AMBER` | 0 | 0 | 0 | 1 | Red+Green — booting / HW init |
| `STATUS_LED_BLUE` | 0 | 1 | 1 | 0 | console ready / interactive |
| `STATUS_LED_GREEN` | 0 | 1 | 0 | 1 | OS / kernel handover |
| `STATUS_LED_WHITE` | 0 | 0 | 0 | 0 | rescue / recovery |
| `STATUS_LED_RED` | 0 | 0 | 1 | 1 | fault / error |

`common/main.c: main_loop()` calls `sercomm_status_led_set(STATUS_LED_AMBER)` at entry.

## Buttons as wired in U-Boot

`arch/arm/dts/bcm96856.dts`:

| Button | GPIO | DTS node | Action |
|---|---|---|---|
| RESET | 26 | `reset_button` | release → `run btn_reset`, then autoboot aborted |
| WPS | 28 | *not wired* | deliberately unused |
| WIFI | 81 | `wifi_button` | press → `run btn_wifi` |

Env defaults (`build/configs/env_SPINOR_2M_6856ref.conf`):

```
btn_reset=env default -a;saveenv      # factory-restore the U-Boot environment
btn_wifi=run netconsole               # enable netconsole
```

Change either at runtime with `setenv btn_wifi "<cmd>"; saveenv` — no rebuild.

Buttons are polled **once**, by `btn_poll_block()` in `common/main.c: main_loop()`,
before `bootdelay_process()`. Nothing polls at the `=>` prompt. `btn_poll_block()`
loops until every button is released, so a button must be held at power-on and then
let go for the boot to continue.

The generic hook that runs `hook`/`hook_cmd` from a button node is registered in
`board/broadcom/bcmbca/bcmbca_button.c: bcmbca_button_init()`.

## Correction history (do not reintroduce)

An earlier revision of `bcm96856.dts` put the buttons on **gpioc 82 (reset)** and
**gpioc 83 (ses/WPS)**. Those are not the buttons. Evidence:

* CFE's map above says PB_RESET=26, PB_WPS=28, PB_WIFI=81.
* `gpio status -a` showed `gpioc81` as a plain unclaimed input, and `gpioc82` /
  `gpioc83` as `[x] ext_irq` — claimed *only by our own DTS*, which is why nothing
  ever printed `Reset Button Pressed` / `WPS Button Pressed`.

## Not on a SoC GPIO

The **Wi-Fi LED** is not in the SoC map. The vendor kernel board DTS
(`kernel/dts/6856/968360BG.dts`) has it on the switch's internal LED controller:

```dts
led2: sw_led-bit_2 {
    active_low;
    label = "WiFi";
    status = "okay";
};
```

so it is driven through the Runner switch LED block, not `gpioc`.

The WPS LED is a three-colour SoC GPIO group instead: R=8, G=9, B=10.
