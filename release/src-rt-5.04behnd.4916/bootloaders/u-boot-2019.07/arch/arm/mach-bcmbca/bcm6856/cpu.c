/* SPDX-License-Identifier: GPL-2.0+ */
/*
 * Copyright 2020 Broadcom Ltd.
 */

#include <common.h>
#include <asm/arch/cpu.h>
#include <asm/arch/ddr.h>
#include <asm/arch/ubus4.h>
#include "bcm_otp.h"
#include <spl.h>
#if defined(CONFIG_BCMBCA_PMC)
#include "pmc_drv.h"
#include "asm/arch/BPCM.h"
#include "clk_rst.h"
#endif
#include "spl_ddrinit.h"
#include "bca_common.h"
#if defined(CONFIG_BCMBCA_UBUS4_DCM)
#include "bcm_ubus4.h"
#endif
#include <sercomm_led.h>

DECLARE_GLOBAL_DATA_PTR;


#if defined(CONFIG_TPL_BUILD)
static void cci400_enable(void)
{
	CCI400->secr_acc |= SECURE_ACCESS_UNSECURE_ENABLE;
}

static void enable_ns_access(void)
{
	BIUCFG->aux.permission |= 0xff;
}
#endif

#if defined(CONFIG_SPL_BUILD) && !defined(CONFIG_TPL_BUILD)
void bcm_setsw(void)
{
    swr_write(0,3,0x5372);
    swr_write(0,6,0xb000);
    swr_write(0,7,0x0029);
    swr_write(1,3,0x5370);
    swr_write(1,7,0x0029);
    swr_write(2,3,0x5370);
    swr_write(2,7,0x0029);
    swr_write(3,3,0x5370);
    swr_write(3,7,0x0029);
}
#endif

#if !defined(CONFIG_SPL_BUILD) || defined(CONFIG_TPL_BUILD)
#define CLOCK_RESET_XTAL_CONTROL_BIT_PD_DRV (17)
static void disable_xtal_clk(void)
{
    uint32_t data;
    int ret;

    ret = ReadBPCMRegister(PMB_ADDR_CHIP_CLKRST,
                   CLKRSTBPCMRegOffset(xtal_control), &data);

    data |= (0x1 << CLOCK_RESET_XTAL_CONTROL_BIT_PD_DRV);

    ret |= WriteBPCMRegister(PMB_ADDR_CHIP_CLKRST,
                CLKRSTBPCMRegOffset(xtal_control), data);

    if (ret)
        printf("Failed to disable xtal clk\n");
}
#else
void disable_xtal_clk(void);
#endif

void boost_cpu_clock(void)
{
    unsigned int clk_index, cpu_clock;
    int stat;
    PLL_CTRL_REG ctrl_reg;

#if defined(CONFIG_BCMBCA_UBUS4_DCM)
    //configure ubus clock
    bcm_ubus4_dcm_clk_bypass(1);
#endif

    if ( !bcm_otp_get_cpu_clk(&clk_index) )
        cpu_clock = 500 + 500*(2-clk_index);
        else
        cpu_clock = 0;

    stat = ReadBPCMRegister(PMB_ADDR_BIU_PLL, PLLCLASSICBPCMRegOffset(resets), &ctrl_reg.Reg32);
        ctrl_reg.Bits.byp_wait = 0;
        stat |= WriteBPCMRegister(PMB_ADDR_BIU_PLL, PLLCLASSICBPCMRegOffset(resets), ctrl_reg.Reg32);

    if (stat)
        printf("Error: failed to set cpu fast mode\n");

    printf("CPU Clock: %dMHz\n", cpu_clock);

    disable_xtal_clk();
}

void bcmbca_enable_memc_sram(u64 addr, u64 size)
{
	/* only support support 4K to 64KB size */
	if (size > SZ_64K || size < SZ_4K)
		return;

	/* upper 8 bit of the address */
	MEMC->SRAM_REMAP_CTRL_UPPER = (u32)((addr >> 32) & 0xff);
	/* 
	 * lower 32 bit address with 4KB aligned 
	 * size bit [6:4] encoding: 4K = 0, 8K = 1, 16K = 2, 32K =3, 64K = 4
	 */
	MEMC->SRAM_REMAP_CTRL = (((u32)addr) & (~0xfff)) | fls((u32)(size >> 13)) << 4;
	/* enable the sram mapping */
	MEMC->SRAM_REMAP_CTRL |= 0x2;
	/* read back to ensure the setting takes effect */
	MEMC->SRAM_REMAP_CTRL;
}

void bcmbca_disable_memc_sram(void)
{
	MEMC->SRAM_REMAP_CTRL = 0;
	MEMC->SRAM_REMAP_CTRL;
}

int arch_cpu_init(void)
{
#if defined(CONFIG_BCMBCA_IKOS)
	icache_enable();
#endif  
#if defined(CONFIG_SPL_BUILD) && !defined(CONFIG_TPL_BUILD)
    /* always disable memc sram first in case btrm keeps it enabled */
    bcmbca_disable_memc_sram();

	spl_ddrinit_prepare();
	/* enable unalgined access */	
	set_sctlr(get_sctlr() & ~CR_A);	
#endif

#if defined(CONFIG_TPL_BUILD)
	enable_ns_access();
	cci400_enable();
#endif

#ifdef CONFIG_DISABLE_CONSOLE
        gd->flags |= GD_FLG_DISABLE_CONSOLE;
#endif
#ifdef CONFIG_SILENT_CONSOLE
	gd->flags |= GD_FLG_SILENT;
#endif

    return 0;
}

u32 bcmbca_get_chipid(void)
{
	unsigned int chipId = (PERF->RevID & CHIP_ID_MASK) >> CHIP_ID_SHIFT;
	unsigned int chipvar;

	if ( !bcm_otp_get_chipid(&chipvar) )
	{
		if ((chipId==0x68560) && (chipvar==3))
			chipId=0x68560B;
	}
	return chipId;
}

#if !defined(CONFIG_SPL_BUILD)
void print_chipinfo(void)
{
	char *nr_cores = NULL;
	unsigned int cpu_speed, rdp_speed, otp_cores;
	unsigned int chipId = bcmbca_get_chipid();
	unsigned int revId = bcmbca_get_chiprev();

	sercomm_status_led_set(STATUS_LED_AMBER);

	printf("Chip ID: BCM%X_%X\n",chipId,revId);

	if ( !bcm_otp_get_nr_cpus(&otp_cores) )
	{
		if (otp_cores == 0)
			nr_cores = "Dual";
		else if (otp_cores == 1)
			nr_cores = "Single";
	}

	pll_ch_freq_get(PMB_ADDR_BIU_PLL, 0, &cpu_speed);
	get_rdp_freq(&rdp_speed);

	printf("Broadcom B53 %s Core: %dMHz\n", nr_cores, cpu_speed);
	printf("RDP: %dMHz\n",rdp_speed);
}
#endif

#if !defined(CONFIG_TPL_ATF)
void boot_secondary_cpu(unsigned long vector)
{
	uint32_t cpu = 1; 
	uint32_t nr_cpus = 2;
	ARM_CONTROL_REG ctrl_reg;

	printf("boot secondary cpu from 0x%lx\n", vector);

	while (cpu < nr_cpus) {
		int stat;

		BIUCFG->cluster[0].rvbar_addr[cpu] = vector;
		stat = PowerOnDevice(PMB_ADDR_ORION_CPU0 + cpu);
		if (stat != kPMC_NO_ERROR)
			printf("failed to power on secondary cpu %d - sts %d\n", cpu, stat);

		stat = ReadBPCMRegister(PMB_ADDR_BIU_BPCM, ARMBPCMRegOffset(arm_control), &ctrl_reg.Reg32);
		ctrl_reg.Bits.cpu_reset_n &= ~(0x1 << cpu);
		stat |= WriteBPCMRegister(PMB_ADDR_BIU_BPCM, ARMBPCMRegOffset(arm_control), ctrl_reg.Reg32);
		if (stat != kPMC_NO_ERROR)
			printf("failed to boot secondary cpu %d - sts %d\n", cpu, stat);
		cpu++;
	}

	return;
}
#endif

/*
 * ---------------------------------------------------------------------------
 * Sercomm HG6244B v2 (BCM68360_B1 / BCM6856): bring CPU1 up for Linux
 * ---------------------------------------------------------------------------
 * Linux 4.1.52 for this board is built *without* CONFIG_HOTPLUG_CPU, so the
 * BCM96856 branch of arch/arm64/kernel/smp_spin_table.c - the one that calls
 * PowerOnZone() on the secondary - is compiled out.  All the kernel does is
 * write __pa(secondary_holding_pen) into /cpus/cpu@1/cpu-release-addr (0xfff8
 * in the vendor device tree, and in the vendor DTS source:
 * kernel/dts/ip/bcm_b53_dual.dtsi) and execute SEV.  It therefore depends on
 * the bootloader having already powered CPU1 on and parked it in a loop that
 * polls that address - the arm64 "spin-table" contract.
 *
 * The vendor CFE does that.  U-Boot does not: its own boot_secondary_cpu()
 * below has no caller anywhere in this SDK - and this build even compiles it
 * out (CONFIG_TPL_ATF is set in the U-Boot proper .config, and the function
 * sits inside `#if !defined(CONFIG_TPL_ATF)`).  Result: "CPU1: failed to come
 * online" / "Brought up 1 CPUs".
 *
 * So, just before jumping into Linux: park a stub in the PMC boot area
 * (0xFFF87000 - the region the vendor CFE memsets before starting its own
 * secondary code), point CPU1's RVBAR at it, power the core on and release its
 * reset.  The stub mirrors CFE: the core comes out of reset at EL3, so drop to
 * non-secure EL2 - the EL U-Boot hands Linux over at - then poll the release
 * slot and branch to whatever the kernel wrote there.
 *
 * The `cpu1probe` command below is the bring-up debugger: it parks the same
 * stub at an arbitrary address, powers CPU1 on, then hands it a tiny "beacon"
 * loop through the release slot.  If the beacon counter in DRAM moves, CPU1
 * really is executing the stub; if not, the failure is earlier (power-on,
 * reset state, or the stub address not being executable).
 *
 * Runtime escape hatches (no reflash needed):
 *   setenv smp_off 1          skip the whole thing (back to one CPU)
 *   setenv smp_stub <hex>     where to park the stub   (default 0xfff87000)
 *   setenv smp_pen  <hex>     release slot to poll     (default 0x0000fff8)
 *   setenv smp_reset 1        power-cycle the CPU1 zone instead of just on
 *
 * The stub/beacon machine code is generated from bootloader/patches/
 * cpu1_spin_stub.S and cpu1_beacon.S.
 */
#define HG6244B_SMP_STUB	0xfff87000UL
#define HG6244B_SMP_PEN		0x0000fff8UL
#define HG6244B_SMP_BEACON	0xfff87800UL	/* scratch, probe only */
#define HG6244B_SMP_COUNTER	0xfff87880UL	/* scratch, probe only */

#if defined(CONFIG_BCMBCA_PMC) && !defined(CONFIG_SPL_BUILD) && !defined(CONFIG_TPL_BUILD)

/*
 * v3:
 * 1. Set CPUECTLR_EL1.SMPEN (bit 6) for hardware cache coherency
 * 2. Enable FP/SIMD at EL3 (cptr_el3)
 * 3. Configure GICv2 for CPU1 (Distributor SGIs/PPIs Group 1 NS + CPU Interface)
 * 4. Poll the release slot AT EL3
 * 5. Drop to Non-Secure EL2 and jump to Linux entry point
 */
static const u32 hg_smp_stub[] = {
	/* 1. CPUECTLR_EL1.SMPEN (bit 6) */
	0xd539f222,	/* mrs	x2, s3_1_c15_c2_1		*/
	0xb27a0042,	/* orr	x2, x2, #0x40 (SMPEN)		*/
	0xd519f222,	/* msr	s3_1_c15_c2_1, x2		*/
	0xd5033fdf,	/* isb					*/

	/* 2. Enable FP/SIMD and initialize cntfrq (50 MHz) at EL3 */
	0xd51e115f,	/* msr	cptr_el3, xzr			*/
	0xd29e1002,	/* mov	x2, #0xf080			*/
	0xf2a05f42,	/* movk	x2, #0x2fa, lsl #16 (0x2faf080 = 50MHz) */
	0xd51be002,	/* msr	cntfrq_el0, x2			*/

	/* 3. Configure GICv2 for CPU1 (Distributor + CPU Interface) */
	0xd2820002,	/* mov	x2, #0x1000			*/
	0xf2b02002,	/* movk	x2, #0x8100, lsl #16 (0x81001000 GICD) */
	0x12800003,	/* mov	w3, #0xffffffff			*/
	0xb9008043,	/* str	w3, [x2, #128] (GICD_IGROUPR0 Grp1 NS) */
	0x52800023,	/* mov	w3, #0x1			*/
	0xb9010043,	/* str	w3, [x2, #256] (GICD_ISENABLER0 SGI0) */

	0xd2840002,	/* mov	x2, #0x2000			*/
	0xf2b02002,	/* movk	x2, #0x8100, lsl #16 (0x81002000 GICC) */
	0x52803ce3,	/* mov	w3, #0x1e7 (GICC_CTLR)		*/
	0xb9000043,	/* str	w3, [x2]			*/
	0x52801003,	/* mov	w3, #0x80 (GICC_PMR priority unmask) */
	0xb9000443,	/* str	w3, [x2, #4]			*/

	/* 4. Poll release slot at EL3 */
	0xd29fff01,	/* mov	x1, #0xfff8			*/
	0xd503205f,	/* wait: wfe				*/
	0xf9400020,	/* ldr	x0, [x1]			*/
	0xb4ffffc0,	/* cbz	x0, wait			*/

	/* 5. Transition to Non-Secure EL2 and jump into Linux */
	0xd280a022,	/* mov	x2, #0x501 (NS|HCE|RW)		*/
	0xd51e1102,	/* msr	scr_el3, x2			*/
	0xd51e4020,	/* msr	elr_el3, x0			*/
	0xd2807923,	/* mov	x3, #0x3c9 (EL2h, DAIF)		*/
	0xd51e4003,	/* msr	spsr_el3, x3			*/
	0xd5033fdf,	/* isb					*/
	0xd69f03e0,	/* eret					*/
};

/* increments HG6244B_SMP_COUNTER (inside the PMC boot area, outside DRAM)
 * forever - proof of life for CPU1 */
static const u32 hg_smp_beacon[] = {
	0xd28f1001,
	0xf2bfff01,
	0xf9400020,
	0x91000400,
	0xf9000020,
	0x17fffffd,
};

static void hg_smp_blob(unsigned long addr, const u32 *code, int words)
{
	u32 *dst = (u32 *)addr;
	int i;

	for (i = 0; i < words; i++)
		dst[i] = code[i];

	/* CPU1 starts with MMU and caches off */
	flush_dcache_range(addr, addr + words * 4);
}

/* returns 0 on a successful power-on/reset-release sequence.
 * arm_mode: 0 = leave ARMBPCM arm_control alone (what the vendor *kernel* does),
 *           1 = clear cpu_reset_n bit 1 (what the vendor U-Boot does),
 *           2 = set   cpu_reset_n bit 1 (the opposite polarity). */
static int hg_smp_cpu1_start(unsigned long stub, unsigned long pen, int do_reset,
			     int arm_mode)
{
	ARM_CONTROL_REG ctrl_reg;
	BPCM_PWR_ZONE_N_CONTROL zone;
	int stat;

	/* RVBAR must be programmed before the core leaves reset */
	BIUCFG->cluster[0].rvbar_addr[1] = stub;

	stat = ReadBPCMRegister(PMB_ADDR_ORION_CPU0 + 1,
				BPCMZoneCtrlRegOffset(0), &zone.Reg32);
	printf("SMP: cpu1 zone sts=%d ctrl=0x%08x (on=%u off=%u reset=%u)\n",
	       stat, zone.Reg32, zone.Bits.pwr_on_state,
	       zone.Bits.pwr_off_state, zone.Bits.reset_state);

	if (do_reset)
		stat = ResetZone(PMB_ADDR_ORION_CPU0 + 1, 0);
	else
		stat = PowerOnDevice(PMB_ADDR_ORION_CPU0 + 1);

	printf("SMP: %s sts=%d rvbar[1]=0x%llx (stub 0x%lx, pen 0x%lx)\n",
	       do_reset ? "ResetZone(cpu1)" : "PowerOnDevice(cpu1)", stat,
	       (unsigned long long)BIUCFG->cluster[0].rvbar_addr[1], stub, pen);
	if (stat != kPMC_NO_ERROR)
		return stat;

	if (arm_mode) {
		stat = ReadBPCMRegister(PMB_ADDR_BIU_BPCM,
					ARMBPCMRegOffset(arm_control),
					&ctrl_reg.Reg32);
		if (arm_mode == 1)
			ctrl_reg.Bits.cpu_reset_n &= ~(0x1 << 1);
		else
			ctrl_reg.Bits.cpu_reset_n |= (0x1 << 1);
		stat |= WriteBPCMRegister(PMB_ADDR_BIU_BPCM,
					  ARMBPCMRegOffset(arm_control),
					  ctrl_reg.Reg32);
		printf("SMP: arm_control %s bit1 -> cpu_reset_n=0x%02x sts=%d\n",
		       (arm_mode == 1) ? "clear" : "set",
		       ctrl_reg.Bits.cpu_reset_n, stat);
	} else {
		printf("SMP: arm_control left alone (cpu_reset_n untouched)\n");
	}
	return stat;
}

static void hg_smp_park(unsigned long stub, unsigned long pen)
{
	hg_smp_blob(stub, hg_smp_stub, ARRAY_SIZE(hg_smp_stub));

	/* the slot must read as zero until the kernel writes the entry point */
	*(volatile u64 *)pen = 0;
	flush_dcache_range(pen, pen + sizeof(u64));
}

/*
 * Called by arch/arm/lib/bootm.c:boot_jump_linux() (its weak default is a
 * no-op) - i.e. on every bootm/booti, but not for `go` or a CFE chainload.
 */
void update_os_arch_secondary_cores(uint8_t os_arch)
{
	unsigned long stub = HG6244B_SMP_STUB;
	unsigned long pen = HG6244B_SMP_PEN;
	int do_reset = 1;
	int arm_mode = 0;	/* what the vendor kernel does: leave it alone */
	const char *val;

	(void)os_arch;

	if (env_get("smp_off"))
		return;

	val = env_get("smp_stub");
	if (val)
		stub = simple_strtoul(val, NULL, 16);
	val = env_get("smp_pen");
	if (val)
		pen = simple_strtoul(val, NULL, 16);
	val = env_get("smp_reset");
	if (val && !strcmp(val, "0"))
		do_reset = 0;
	if (env_get("smp_noreset"))
		do_reset = 0;
	val = env_get("smp_arm");
	if (val)
		arm_mode = simple_strtoul(val, NULL, 10);

	printf("SMP: parking CPU1 on slot 0x%lx, stub @ 0x%lx\n", pen, stub);
	hg_smp_park(stub, pen);
	hg_smp_cpu1_start(stub, pen, do_reset, arm_mode);
}

/*
 * cpu1probe [stub-addr] [reset]
 *
 * Bring-up debugger: park the stub, start CPU1, then hand it the beacon
 * through the release slot and see whether the counter in DRAM moves.
 */
static int do_cpu1probe(cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[])
{
	unsigned long stub = (argc > 1) ? simple_strtoul(argv[1], NULL, 16)
					: HG6244B_SMP_STUB;
	const char *fl = (argc > 2) ? argv[2] : "";
	int do_reset = 0, raw = 0, arm_mode = 0;
	const char *p;
	u64 pen_was;
	u32 c0, c1;

	for (p = fl; *p; p++) {
		if (*p == 'r')
			do_reset = 1;
		else if (*p == 'R')
			raw = 1;
		else if (*p == 'a')
			arm_mode = 0;
		else if (*p == 'A')
			arm_mode = 2;
		else if (*p == 'c')
			arm_mode = 1;
	}

	*(volatile u32 *)HG6244B_SMP_COUNTER = 0;
	flush_dcache_range(HG6244B_SMP_COUNTER, HG6244B_SMP_COUNTER + 4);

	pen_was = *(volatile u64 *)HG6244B_SMP_PEN;
	hg_smp_park(stub, HG6244B_SMP_PEN);
	printf("probe: pen 0x%lx held 0x%llx, now reads 0x%llx\n",
	       HG6244B_SMP_PEN, (unsigned long long)pen_was,
	       (unsigned long long)*(volatile u64 *)HG6244B_SMP_PEN);

	hg_smp_blob(HG6244B_SMP_BEACON, hg_smp_beacon,
		    ARRAY_SIZE(hg_smp_beacon));
	printf("probe: mode%s%s%s arm=%d\n", raw ? " raw-beacon" : "",
	       do_reset ? " reset-zone" : "", "", arm_mode);

	if (raw) {
		/* no EL dance, no pen: does the core execute code at `stub`? */
		hg_smp_blob(stub, hg_smp_beacon, ARRAY_SIZE(hg_smp_beacon));
		printf("probe: raw beacon @0x%lx = %08x %08x (counter 0x%lx)\n",
		       stub, ((u32 *)stub)[0], ((u32 *)stub)[1],
		       HG6244B_SMP_COUNTER);
	} else {
		printf("probe: stub @0x%lx = %08x %08x | beacon @0x%lx = %08x %08x\n",
		       stub, ((u32 *)stub)[0], ((u32 *)stub)[1],
		       HG6244B_SMP_BEACON, ((u32 *)HG6244B_SMP_BEACON)[0],
		       ((u32 *)HG6244B_SMP_BEACON)[1]);
	}

	if (hg_smp_cpu1_start(stub, HG6244B_SMP_PEN, do_reset, arm_mode)
	    != kPMC_NO_ERROR)
		goto out;

	mdelay(100);
	if (!raw) {
		*(volatile u64 *)HG6244B_SMP_PEN = HG6244B_SMP_BEACON;
		flush_dcache_range(HG6244B_SMP_PEN, HG6244B_SMP_PEN + 8);
		mdelay(100);
	}
	c0 = *(volatile u32 *)HG6244B_SMP_COUNTER;
	mdelay(200);
	c1 = *(volatile u32 *)HG6244B_SMP_COUNTER;
	printf("probe: beacon %u -> %u : %s\n", c0, c1,
	       (c1 != c0) ? "CPU1 IS RUNNING" : "NO BEACON - CPU1 did not execute");

out:
	*(volatile u64 *)HG6244B_SMP_PEN = 0;
	flush_dcache_range(HG6244B_SMP_PEN, HG6244B_SMP_PEN + 8);
	return 0;
}

U_BOOT_CMD(cpu1probe, 3, 0, do_cpu1probe,
	   "probe BCM6856 CPU1 spin-table bring-up",
	   "[stub-addr] [flags]\n"
	   "    flags: r=ResetZone first, R=raw beacon (skip EL/pen),\n"
	   "           a=leave arm_control, c=clear cpu_reset_n bit,\n"
	   "           A=set cpu_reset_n bit\n"
	   "    parks the stub, starts CPU1, then checks whether a beacon\n"
	   "    loop handed over through the release slot really runs");

#endif
