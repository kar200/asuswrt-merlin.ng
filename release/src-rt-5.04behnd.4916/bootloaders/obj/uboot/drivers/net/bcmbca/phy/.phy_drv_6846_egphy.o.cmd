cmd_drivers/net/bcmbca/phy/phy_drv_6846_egphy.o := /opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/aarch64-linux-gcc -Wp,-MD,drivers/net/bcmbca/phy/.phy_drv_6846_egphy.o.d  -nostdinc -isystem /home/docker/am-toolchains/brcm-arm-hnd/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/bin/../lib/gcc/aarch64-buildroot-linux-gnu/10.3.0/include -Iinclude  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include -include /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/kconfig.h  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy -Idrivers/net/bcmbca/phy -D__KERNEL__ -D__UBOOT__ -Wno-address-of-packed-member -Wall -Wstrict-prototypes -Wno-format-security -fno-builtin -ffreestanding -std=gnu11 -fshort-wchar -fno-strict-aliasing  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/../../router/shared -I../../router/shared -fno-PIE -Os -fstack-protector-strong -fno-delete-null-pointer-checks -fmacro-prefix-map=/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/= -g -fstack-usage -Wno-format-nonliteral -Werror=date-time -fcommon -Wno-error=unused-but-set-variable -Wno-error=discarded-qualifiers -Wno-error=int-conversion -D__ARM__ -fno-pic -mstrict-align -ffunction-sections -fdata-sections -fno-common -ffixed-r9 -fno-common -ffixed-x18 -pipe -march=armv8-a -D__LINUX_ARM_ARCH__=8   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/include   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/lport   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/lport/ag   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/xrdp   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dt-bindings/leds   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/pmc -DCONFIG_BCM96856 -D_BYTE_ORDER_LITTLE_ENDIAN_ -DBUS_MDIO_V1 -DBRCM_RGMII -DMAC_UNIMAC -DPHY_6846_EGPHY -DPHY_6856_SGMII -DPHY_EXT1    -D"KBUILD_STR(s)=$(pound)s" -D"KBUILD_BASENAME=KBUILD_STR(phy_drv_6846_egphy)"  -D"KBUILD_MODNAME=KBUILD_STR(DRV_OBJS)" -c -o drivers/net/bcmbca/phy/phy_drv_6846_egphy.o /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy/phy_drv_6846_egphy.c

source_drivers/net/bcmbca/phy/phy_drv_6846_egphy.o := /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy/phy_drv_6846_egphy.c

deps_drivers/net/bcmbca/phy/phy_drv_6846_egphy.o := \
    $(wildcard include/config/0.h) \
    $(wildcard include/config/1.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy/bus_drv.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy/os_dep.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/types.h \
    $(wildcard include/config/uid16.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/posix_types.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/stddef.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/posix_types.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/types.h \
    $(wildcard include/config/arm64.h) \
    $(wildcard include/config/phys/64bit.h) \
    $(wildcard include/config/dma/addr/t/64bit.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/int-ll64.h \
  /home/docker/am-toolchains/brcm-arm-hnd/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/lib/gcc/aarch64-buildroot-linux-gnu/10.3.0/include/stdbool.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/string.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/string.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/string.h \
    $(wildcard include/config/use/arch/memcpy.h) \
    $(wildcard include/config/use/arch/memset.h) \
  include/config.h \
    $(wildcard include/config/boarddir.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/config_defaults.h \
    $(wildcard include/config/defaults/h/.h) \
    $(wildcard include/config/bootm/linux.h) \
    $(wildcard include/config/bootm/netbsd.h) \
    $(wildcard include/config/bootm/plan9.h) \
    $(wildcard include/config/bootm/rtems.h) \
    $(wildcard include/config/bootm/vxworks.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/config_uncmd_spl.h \
    $(wildcard include/config/uncmd/spl/h//.h) \
    $(wildcard include/config/spl/build.h) \
    $(wildcard include/config/spl/dm.h) \
    $(wildcard include/config/dm/serial.h) \
    $(wildcard include/config/dm/gpio.h) \
    $(wildcard include/config/dm/i2c.h) \
    $(wildcard include/config/dm/spi.h) \
    $(wildcard include/config/dm/warn.h) \
    $(wildcard include/config/dm/stdio.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/configs/bcm96856.h \
    $(wildcard include/config/sys/baudrate/table.h) \
    $(wildcard include/config/sys/maxargs.h) \
    $(wildcard include/config/sys/malloc/len.h) \
    $(wildcard include/config/sys/bootm/len.h) \
    $(wildcard include/config/gicv2.h) \
    $(wildcard include/config/env/callback/list/static.h) \
    $(wildcard include/config/extra/env/settings.h) \
    $(wildcard include/config/sys/init/std/32k/addr.h) \
    $(wildcard include/config/sys/sec/cred/addr.h) \
    $(wildcard include/config/sys/sdram/base.h) \
    $(wildcard include/config/sys/cbsize.h) \
    $(wildcard include/config/sys/bargsize.h) \
    $(wildcard include/config/tpl/build.h) \
    $(wildcard include/config/sys/init/sp/addr.h) \
    $(wildcard include/config/tpl/text/base.h) \
    $(wildcard include/config/sys/pagetbl/base.h) \
    $(wildcard include/config/sys/pagetbl/size.h) \
    $(wildcard include/config/sys/init/ram/addr.h) \
    $(wildcard include/config/sys/init/ram/size.h) \
    $(wildcard include/config/sys/init/sp/offset.h) \
    $(wildcard include/config/spl/max/size.h) \
    $(wildcard include/config/spl/bss/start/addr.h) \
    $(wildcard include/config/spl/bss/max/size.h) \
    $(wildcard include/config/sys/malloc/simple.h) \
    $(wildcard include/config/sys/text/base.h) \
    $(wildcard include/config/sys/load/addr.h) \
    $(wildcard include/config/skip/lowlevel/init.h) \
    $(wildcard include/config/spl/load/fit/address.h) \
    $(wildcard include/config/nand.h) \
    $(wildcard include/config/sys/nand/base.h) \
    $(wildcard include/config/sys/max/nand/device.h) \
    $(wildcard include/config/sys/nand/self/init.h) \
    $(wildcard include/config/sys/nand/onfi/detection.h) \
    $(wildcard include/config/sys/nand/u/boot/offs.h) \
    $(wildcard include/config/sys/nand/block/size.h) \
    $(wildcard include/config/tpl/ubi.h) \
    $(wildcard include/config/spl/ubi/max/vol/lebs.h) \
    $(wildcard include/config/spl/ubi/max/peb/size.h) \
    $(wildcard include/config/spl/ubi/max/pebs.h) \
    $(wildcard include/config/spl/ubi/vol/ids.h) \
    $(wildcard include/config/spl/ubi/load/monitor/id.h) \
    $(wildcard include/config/spl/ubi/peb/offset.h) \
    $(wildcard include/config/spl/ubi/vid/offset.h) \
    $(wildcard include/config/spl/ubi/leb/start.h) \
    $(wildcard include/config/spl/ubi/info/addr.h) \
    $(wildcard include/config/mmc.h) \
    $(wildcard include/config/sys/mtdparts/runtime.h) \
    $(wildcard include/config/jffs2/nand.h) \
    $(wildcard include/config/arch/cpu/init.h) \
    $(wildcard include/config/env/size.h) \
    $(wildcard include/config/sys/bootmapsz.h) \
    $(wildcard include/config/sys/fdt/pad.h) \
    $(wildcard include/config/usb/ohci/hcd.h) \
    $(wildcard include/config/usb/ohci/new.h) \
    $(wildcard include/config/sys/usb/ohci/max/root/ports.h) \
    $(wildcard include/config/sys/jffs2/sort/fragments.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/sizes.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/const.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/config.h \
    $(wildcard include/config/h/.h) \
    $(wildcard include/config/lmb.h) \
    $(wildcard include/config/sys/boot/ramdisk/high.h) \
    $(wildcard include/config/arch/ls1021a.h) \
    $(wildcard include/config/cpu/pxa27x.h) \
    $(wildcard include/config/cpu/monahans.h) \
    $(wildcard include/config/cpu/pxa25x.h) \
    $(wildcard include/config/fsl/layerscape.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/config_fallbacks.h \
    $(wildcard include/config/fallbacks/h.h) \
    $(wildcard include/config/spl.h) \
    $(wildcard include/config/spl/pad/to.h) \
    $(wildcard include/config/cmd/kgdb.h) \
    $(wildcard include/config/sys/pbsize.h) \
    $(wildcard include/config/sys/prompt.h) \
    $(wildcard include/config/sys/i2c.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/linux_string.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/stdio.h \
    $(wildcard include/config/tpl/serial/support.h) \
    $(wildcard include/config/spl/serial/support.h) \
  /home/docker/am-toolchains/brcm-arm-hnd/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/lib/gcc/aarch64-buildroot-linux-gnu/10.3.0/include/stdarg.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/compiler.h \
    $(wildcard include/config/sparse/rcu/pointer.h) \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/kasan.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
    $(wildcard include/config/kprobes.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/compiler-gcc.h \
    $(wildcard include/config/arch/supports/optimized/inlining.h) \
    $(wildcard include/config/optimize/inlining.h) \
    $(wildcard include/config/gcov/kernel.h) \
    $(wildcard include/config/arch/use/builtin/bswap.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/printk.h \
    $(wildcard include/config/loglevel.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/compat.h \
    $(wildcard include/config/lbdaf.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/malloc.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/err.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/errno.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/kernel.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy/phy_drv.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy/dt_access.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/ofnode.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/fdtdec.h \
    $(wildcard include/config/of/prior/stage.h) \
    $(wildcard include/config/multi/dtb/fit.h) \
    $(wildcard include/config/of/board.h) \
    $(wildcard include/config/of/separate.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/libfdt.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/libfdt_env.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/byteorder.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/byteorder/little_endian.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/byteorder/swab.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/byteorder/generic.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/vsprintf.h \
    $(wildcard include/config/panic/hang.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/../../scripts/dtc/libfdt/libfdt.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/../../scripts/dtc/libfdt/libfdt_env.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/../../scripts/dtc/libfdt/fdt.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/pci.h \
    $(wildcard include/config/sys/pci/64bit.h) \
    $(wildcard include/config/dm/pci.h) \
    $(wildcard include/config/pci/indirect/bridge.h) \
    $(wildcard include/config/dm/pci/compat.h) \
    $(wildcard include/config/pci/fixup/dev.h) \
    $(wildcard include/config/mpc85xx.h) \
    $(wildcard include/config/pcie/imx.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/pci_ids.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/of.h \
    $(wildcard include/config/of/live.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/u-boot.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/u-boot.h \
    $(wildcard include/config/arm.h) \
    $(wildcard include/config/mpc8xx.h) \
    $(wildcard include/config/e500.h) \
    $(wildcard include/config/mpc86xx.h) \
    $(wildcard include/config/m68k.h) \
    $(wildcard include/config/mpc83xx.h) \
    $(wildcard include/config/cpm2.h) \
    $(wildcard include/config/extra/clock.h) \
    $(wildcard include/config/has/eth1.h) \
    $(wildcard include/config/has/eth2.h) \
    $(wildcard include/config/has/eth3.h) \
    $(wildcard include/config/has/eth4.h) \
    $(wildcard include/config/has/eth5.h) \
    $(wildcard include/config/nr/dram/banks.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/u-boot-arm.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/global_data.h \
    $(wildcard include/config/fsl/esdhc.h) \
    $(wildcard include/config/u/qe.h) \
    $(wildcard include/config/at91family.h) \
    $(wildcard include/config/sys/icache/off.h) \
    $(wildcard include/config/sys/dcache/off.h) \
    $(wildcard include/config/sys/mem/reserve/secure.h) \
    $(wildcard include/config/resv/ram.h) \
    $(wildcard include/config/arch/omap2plus.h) \
    $(wildcard include/config/fsl/lsch3.h) \
    $(wildcard include/config/sys/fsl/has/dp/ddr.h) \
    $(wildcard include/config/arch/imx8.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/global_data.h \
    $(wildcard include/config/pci.h) \
    $(wildcard include/config/lcd.h) \
    $(wildcard include/config/video.h) \
    $(wildcard include/config/post.h) \
    $(wildcard include/config/board/types.h) \
    $(wildcard include/config/pre/console/buffer.h) \
    $(wildcard include/config/dm.h) \
    $(wildcard include/config/timer.h) \
    $(wildcard include/config/trace.h) \
    $(wildcard include/config/sys/i2c/mxc.h) \
    $(wildcard include/config/sys/malloc/f/len.h) \
    $(wildcard include/config/pci/bootdelay.h) \
    $(wildcard include/config/console/record.h) \
    $(wildcard include/config/dm/video.h) \
    $(wildcard include/config/bootstage.h) \
    $(wildcard include/config/log.h) \
    $(wildcard include/config/bloblist.h) \
    $(wildcard include/config/translation/offset.h) \
    $(wildcard include/config/wdt.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/membuff.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/list.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/poison.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/of_access.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/device.h \
    $(wildcard include/config/devres.h) \
    $(wildcard include/config/of/control.h) \
    $(wildcard include/config/debug/devres.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/uclass-id.h \
    $(wildcard include/config/bcmbca/vfbio.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linker_lists.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/read.h \
    $(wildcard include/config/dm/dev/read/inline.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/fdtaddr.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/uclass.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/gpio.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy/phy_drv_mii.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy/phy_drv_brcm.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/xrdp/access_macros.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/io.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/memory.h \
    $(wildcard include/config/discontigmem.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/barriers.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/io.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/iotrace.h \
    $(wildcard include/config/io/trace.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/phy/xrdp_led_init.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dt-bindings/leds/bcm_bca_leds_dt_bindings.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/bcm_bca_leds.h \
    $(wildcard include/config/bcm/bca/led.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/platdata.h \
    $(wildcard include/config/of/platdata.h) \

drivers/net/bcmbca/phy/phy_drv_6846_egphy.o: $(deps_drivers/net/bcmbca/phy/phy_drv_6846_egphy.o)

$(deps_drivers/net/bcmbca/phy/phy_drv_6846_egphy.o):
