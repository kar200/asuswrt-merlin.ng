cmd_u-boot.lds := /opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/aarch64-linux-gcc -E -Wp,-MD,./.u-boot.lds.d -D__KERNEL__ -D__UBOOT__ -Wno-address-of-packed-member   -D__ARM__           -fno-pic  -mstrict-align  -ffunction-sections -fdata-sections -fno-common -ffixed-r9     -fno-common -ffixed-x18 -pipe -march=armv8-a -D__LINUX_ARM_ARCH__=8  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/include -Iinclude  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include -include /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/kconfig.h  -nostdinc -isystem /home/docker/am-toolchains/brcm-arm-hnd/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/bin/../lib/gcc/aarch64-buildroot-linux-gnu/10.3.0/include -ansi -include /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/u-boot/u-boot.lds.h -DCPUDIR=arch/arm/cpu/armv8  -D__ASSEMBLY__ -x assembler-with-cpp -std=c99 -P -o u-boot.lds /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/cpu/armv8/u-boot.lds

source_u-boot.lds := /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/cpu/armv8/u-boot.lds

deps_u-boot.lds := \
    $(wildcard include/config/armv8/secure/base.h) \
    $(wildcard include/config/armv8/psci.h) \
    $(wildcard include/config/armv8/psci/nr/cpus.h) \
    $(wildcard include/config/linux/kernel/image/header.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/u-boot/u-boot.lds.h \
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
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/psci.h \
    $(wildcard include/config/armv7/psci/nr/cpus.h) \

u-boot.lds: $(deps_u-boot.lds)

$(deps_u-boot.lds):
