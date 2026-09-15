/* SPDX-License-Identifier: GPL-2.0+ */
/*
 * Copyright (C) 2019 Philippe Reynes <philippe.reynes@softathome.com>
 *
 * Copyright 2019 Broadcom Ltd.
 */

#include <linux/sizes.h>

/*
 * common
 */

/* UART */
#define CONFIG_SYS_BAUDRATE_TABLE	{ 9600, 19200, 38400, 57600, 115200, \
					  230400, 500000, 1500000 }
/* Memory usage */
#define CONFIG_SYS_MAXARGS		64
#define CONFIG_SYS_MALLOC_LEN		(1024 * 1024 * 32)
#define CONFIG_SYS_BOOTM_LEN		(64 * 1024 * 1024)

#define CPU_RELEASE_ADDR		0x1000
#define CONFIG_GICV2			1
#define GICD_BASE				0x81001000
#define GICC_BASE				0x81002000

#define CONFIG_ENV_CALLBACK_LIST_STATIC "boardid:boardid,active_port:active_port,voiceboardid:voiceboardid,"

#define CONFIG_EXTRA_ENV_SETTINGS \
	"IMAGE=SPINOR:2M,6M\0" \
	"MCB=1527\0" \
	"boardid=96856\0" \
	"nummacaddrs=10\0" \
	"ethaddr=02:10:18:00:00:01\0" \
	"mtdids=nor0=spi-nor.0\0" \
	"mtdparts=spi-nor.0:2M(loader),4M(bootfs),10M(rootfs)\0" \
	"ipaddr=192.168.1.1\0" \
	"serverip=192.168.1.100\0" \
	"bootdelay=3\0" \
	"baudrate=115200\0" \
	"bootcmd=echo BCM6856 SPI-NOR U-Boot;sf probe 0:0;mmc rescan;run boot_default\0" \
	"boot_default=echo No boot target configured - load with tftpboot/loadb or run boot_emmc\0" \
	"env_boot_magic=16384@0x40000,0xad000\0" \
	"ncip=255.255.255.255\0" \
	"netconsole=echo Enabling NetConsole on UDP broadcast 255.255.255.255:6666...; setenv stdout serial,nc; setenv stderr serial,nc; setenv stdin serial,nc\0" \
	"boot_emmc=run boot_cfe\0" \
	"boot_cfe=echo Booting stock CFE from eMMC bootfs1 ...; " \
		"mmc dev 0 0; " \
		"mmc read 0x04000000 0x1000 0x900; " \
		"cp.b 0x040012a1 0x01000000 0x1008d8; " \
		"mw.b 0x011008d8 0 0x00200000; " \
		"mw.l 0x0101f2e0 0x14000004 1; " \
		"dcache off; icache off; " \
		"go 0x01000000\0"

/*
 * 6856
 */

#define CONFIG_SYS_INIT_STD_32K_ADDR    0xfff80000 
#define CONFIG_SYS_SEC_CRED_ADDR        (CONFIG_SYS_INIT_STD_32K_ADDR + 0x7000)

/* RAM */
#define PHYS_SDRAM_1			0x00000000UL
#define PHYS_SDRAM_1_SIZE		(2UL * SZ_1G) /* Maximum possible bnk 0 size */
#define CONFIG_SYS_SDRAM_BASE		PHYS_SDRAM_1

/* U-Boot */
/* console configuration */
#define CONFIG_SYS_CBSIZE               1024
#define CONFIG_SYS_BARGSIZE             CONFIG_SYS_CBSIZE

#ifdef CONFIG_TPL_BUILD
#define CONFIG_SYS_INIT_SP_ADDR		(CONFIG_TPL_TEXT_BASE + SZ_8M)
#define CONFIG_SYS_PAGETBL_BASE		CONFIG_SYS_INIT_SP_ADDR
#define CONFIG_SYS_PAGETBL_SIZE		0x10000
#elif CONFIG_SPL_BUILD
#define CONFIG_SYS_INIT_RAM_ADDR	0x82600000
#define CONFIG_SYS_INIT_RAM_SIZE	0x00080000
#define CONFIG_SYS_INIT_SP_OFFSET \
	(CONFIG_SYS_INIT_RAM_SIZE - GENERATED_GBL_DATA_SIZE)
#define CONFIG_SYS_INIT_SP_ADDR \
	(CONFIG_SYS_INIT_RAM_ADDR + CONFIG_SYS_INIT_SP_OFFSET)

#define CONFIG_SYS_PAGETBL_BASE		0x7fff0000
#define CONFIG_SYS_PAGETBL_SIZE		0x10000

#define CONFIG_SPL_MAX_SIZE		0x00020000
#define CONFIG_SPL_BSS_START_ADDR	0x82640000
#define CONFIG_SPL_BSS_MAX_SIZE		0x8000

#define CONFIG_SYS_MALLOC_SIMPLE
#else
#define CONFIG_SYS_INIT_SP_ADDR		(CONFIG_SYS_TEXT_BASE + SZ_16M)
#endif

#define CONFIG_SYS_LOAD_ADDR		(CONFIG_SYS_TEXT_BASE)

#define CONFIG_SKIP_LOWLEVEL_INIT

#define CONFIG_SPL_LOAD_FIT_ADDRESS	(CONFIG_TPL_TEXT_BASE + 0x2000000)

#ifdef CONFIG_NAND
#define CONFIG_SYS_NAND_BASE            0xff801800
#define CONFIG_SYS_MAX_NAND_DEVICE	1
#define CONFIG_SYS_NAND_SELF_INIT
#define CONFIG_SYS_NAND_ONFI_DETECTION

/* dummy definition to make spl nand image loader happy */
#define CONFIG_SYS_NAND_U_BOOT_OFFS	0x100000
#define CONFIG_SYS_NAND_BLOCK_SIZE	(256*1024) // max possible size

#define CONFIG_TPL_UBI
#define CONFIG_SPL_UBI_MAX_VOL_LEBS	256
#define CONFIG_SPL_UBI_MAX_PEB_SIZE	CONFIG_SYS_NAND_BLOCK_SIZE
#define CONFIG_SPL_UBI_MAX_PEBS 	8192
#define CONFIG_SPL_UBI_VOL_IDS		8
#define CONFIG_SPL_UBI_LOAD_MONITOR_ID	0
#define CONFIG_SPL_UBI_PEB_OFFSET	4
#define CONFIG_SPL_UBI_VID_OFFSET	512
#define CONFIG_SPL_UBI_LEB_START	2048
#define CONFIG_SPL_UBI_INFO_ADDR	(CONFIG_SPL_LOAD_FIT_ADDRESS - 0x1000000)
#endif /* CONFIG_NAND */

#ifdef CONFIG_MMC
#ifdef CONFIG_TPL_BUILD
#elif CONFIG_SPL_BUILD
#endif
#endif /* CONFIG_MMC */

#define CONFIG_SYS_MTDPARTS_RUNTIME
#define CONFIG_JFFS2_NAND 1

#define CONFIG_ARCH_CPU_INIT
#define COUNTER_FREQUENCY       50000000
#define CONFIG_ENV_SIZE		(8 * 1024)

#define CONFIG_SYS_BOOTMAPSZ	(128 << 20)
#define CONFIG_SYS_FDT_PAD	0x80000

#ifdef CONFIG_USB_OHCI_HCD
#define CONFIG_USB_OHCI_NEW
#define CONFIG_SYS_USB_OHCI_MAX_ROOT_PORTS  2
#endif /* CONFIG_USB_OHCI_HCD */

/* if uboot needs to read JFFS2 partitions where files were written incrementally
 * or replaced after they were initially written.
 */
#define CONFIG_SYS_JFFS2_SORT_FRAGMENTS

