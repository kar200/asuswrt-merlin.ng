cmd_arch/arm/mach-bcmbca/lowlevel_init.o := /opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/aarch64-linux-gcc -Wp,-MD,arch/arm/mach-bcmbca/.lowlevel_init.o.d  -nostdinc -isystem /home/docker/am-toolchains/brcm-arm-hnd/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/bin/../lib/gcc/aarch64-buildroot-linux-gnu/10.3.0/include -Iinclude  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include -include /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/kconfig.h -D__KERNEL__ -D__UBOOT__ -Wno-address-of-packed-member -D__ASSEMBLY__ -fno-PIE -g -D__ARM__ -fno-pic -mstrict-align -ffunction-sections -fdata-sections -fno-common -ffixed-r9 -fno-common -ffixed-x18 -pipe -march=armv8-a -D__LINUX_ARM_ARCH__=8   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/include   -c -o arch/arm/mach-bcmbca/lowlevel_init.o /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/lowlevel_init.S

source_arch/arm/mach-bcmbca/lowlevel_init.o := /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/lowlevel_init.S

deps_arch/arm/mach-bcmbca/lowlevel_init.o := \
    $(wildcard include/config/tpl/build.h) \
    $(wildcard include/config/arm64.h) \
    $(wildcard include/config/tpl/atf.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/linkage.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/linkage.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/macro.h \
    $(wildcard include/config/armv8/multientry.h) \
    $(wildcard include/config/armv8/psci.h) \
    $(wildcard include/config/armv8/ea/el3/first.h) \
    $(wildcard include/config/gicv3.h) \
    $(wildcard include/config/gicv2.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/system.h \
    $(wildcard include/config/bcm6888.h) \
    $(wildcard include/config/bcm68880.h) \
    $(wildcard include/config/bcm6837.h) \
    $(wildcard include/config/bcm963148.h) \
    $(wildcard include/config/bcm63138.h) \
    $(wildcard include/config/armv7/lpae.h) \
    $(wildcard include/config/cpu/v7a.h) \
    $(wildcard include/config/sys/noncached/memory.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/common.h \
    $(wildcard include/config/sys/support/64bit/data.h) \
    $(wildcard include/config/env/is/embedded.h) \
    $(wildcard include/config/sys/malloc/len.h) \
    $(wildcard include/config/env/addr.h) \
    $(wildcard include/config/env/size.h) \
    $(wildcard include/config/sys/monitor/base.h) \
    $(wildcard include/config/sys/monitor/len.h) \
    $(wildcard include/config/env/is/in/nvram.h) \
    $(wildcard include/config/auto/complete.h) \
    $(wildcard include/config/cmd/eeprom.h) \
    $(wildcard include/config/env/eeprom/is/on/i2c.h) \
    $(wildcard include/config/sys/i2c/eeprom/addr.h) \
    $(wildcard include/config/sys/def/eeprom/addr.h) \
    $(wildcard include/config/sys/dram/test.h) \
    $(wildcard include/config/arm.h) \
    $(wildcard include/config/led/status.h) \
    $(wildcard include/config/show/activity.h) \
    $(wildcard include/config/mp.h) \
    $(wildcard include/config/post.h) \
    $(wildcard include/config/has/post.h) \
    $(wildcard include/config/post/alt/list.h) \
    $(wildcard include/config/post/std/list.h) \
    $(wildcard include/config/efi/stub.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/compiler.h \
    $(wildcard include/config/sparse/rcu/pointer.h) \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/kasan.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
    $(wildcard include/config/kprobes.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/barriers.h \

arch/arm/mach-bcmbca/lowlevel_init.o: $(deps_arch/arm/mach-bcmbca/lowlevel_init.o)

$(deps_arch/arm/mach-bcmbca/lowlevel_init.o):
