/* SPDX-License-Identifier: GPL-2.0+
 *
 *  Copyright 2019 Broadcom Ltd.
 */
#include <common.h>
#include <asm/armv8/mmu.h>

static struct mm_region broadcom_bcm96856_mem_map[] = {
#if defined(CONFIG_SPL_BUILD) && !defined(CONFIG_TPL_BUILD)
	/* DDR memory. Enable the maximum 4GB DDR for alias test. Use Device Attr
	  to avoid CPU speculative fetch */
	{
		.virt = 0x00000000UL,
		.phys = 0x00000000UL,
		.size = 2UL * SZ_1G,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
	{
		.virt = 0x100000000UL,
		.phys = 0x100000000UL,
		.size = 2UL * SZ_1G,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
	/* MEMC and DDRY PHY control registers */
	{
		.virt = 0x80180000UL,
		.phys = 0x80180000UL,
		.size = 0x40000,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
	/* LMEM for bootrom runtime  */
	{
		.virt = CONFIG_SYS_INIT_RAM_ADDR,
		.phys = CONFIG_SYS_INIT_RAM_ADDR,
		.size = CONFIG_SYS_INIT_RAM_SIZE,
		.attrs = PTE_BLOCK_MEMTYPE(MT_NORMAL) |
			PTE_BLOCK_INNER_SHARE
	},
	/* STD Mem  */
	{
		.virt = CONFIG_SYS_INIT_STD_32K_ADDR,
		.phys = CONFIG_SYS_INIT_STD_32K_ADDR,
		.size = SZ_32K,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			PTE_BLOCK_NON_SHARE |
			PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
#else
	/* DDR entries for cached memory, total size is a placehold
	   and will be filled in at run time. MUST be first entry */
	{
		.virt = 0x00000000UL,
		.phys = 0x00000000UL,
		.size = 1UL * SZ_1G,
		.attrs = PTE_BLOCK_MEMTYPE(MT_NORMAL) |
			PTE_BLOCK_INNER_SHARE
	},
		/* PMC */
	{
		.virt = 0xffb00000UL,
		.phys = 0xffb00000UL,
		.size = 0x6000,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
		/* PROC_MON */
	{
		.virt = 0xffb20000UL,
		.phys = 0xffb20000UL,
		.size = 0x1000,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},

        /* BIUCFG */
	{
		.virt = 0x81060000UL,
		.phys = 0x81060000UL,
		.size = 0x3000,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
		/* CCI400 */
	{
		.virt = 0x81090000,
		.phys = 0x81090000,
		.size = 0x10000,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
	/* STD Mem  */
	{
		.virt = CONFIG_SYS_INIT_STD_32K_ADDR,
		.phys = CONFIG_SYS_INIT_STD_32K_ADDR,
		.size = SZ_32K,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			PTE_BLOCK_NON_SHARE |
			PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
        /* UBUS */
    {
        .virt = 0x83000000UL,
        .phys = 0x83000000UL,
        .size = 0x100000,
        .attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
             PTE_BLOCK_NON_SHARE |
             PTE_BLOCK_PXN | PTE_BLOCK_UXN
    },
		/* UBUS4 Coherency Port */
	{
		.virt = 0x810A0000,
		.phys = 0x810A0000,
		.size = 0x1000,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},	
#if !defined(CONFIG_TPL_BUILD)
		/* USB */
	{
		.virt = 0x8000C000UL,
		.phys = 0x8000C000UL,
		.size = 0x3000,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
		/* XRDP */
	{
		.virt = 0x82000000UL,
		.phys = 0x82000000UL,
		.size = 0x1000000,
		/*
		 * PTE_BLOCK_PXN deliberately CLEARED (UXN kept).
		 *
		 * CONFIG_SPL_TEXT_BASE is 0x82612000, which this 16 MiB block
		 * covers.  With PXN set, `go 0x82612000` can only ever raise an
		 * Instruction Abort (ESR EC=0x21) because the CPU may not fetch
		 * instructions there -- so chain-loading the eMMC SPL from U-Boot
		 * is impossible.  The ROM can run the SPL there only because it
		 * does not use these page tables.
		 *
		 * Clearing PXN alone is the minimum needed: U-Boot runs
		 * privileged (EL1/EL2) and can then execute from this window,
		 * while UXN still denies user mode.  This makes a slice of device
		 * memory executable, which is acceptable for bring-up work but
		 * should be revisited before anything permanent.
		 */
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_UXN
	},
#endif
#endif
	{
		/* SoC peripheral */
		.virt = 0xff800000UL,
		.phys = 0xff800000UL,
		.size = SZ_1M,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	}, 
	{
		/* List terminator */
		0,
	}
};

struct mm_region *mem_map = broadcom_bcm96856_mem_map;
