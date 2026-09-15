cmd_tpl/board/broadcom/bcmbca/bca_common.o := /opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/aarch64-linux-gcc -Wp,-MD,tpl/board/broadcom/bcmbca/.bca_common.o.d  -nostdinc -isystem /home/docker/am-toolchains/brcm-arm-hnd/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/bin/../lib/gcc/aarch64-buildroot-linux-gnu/10.3.0/include -Iinclude  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include -include /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/kconfig.h  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/tpl/board/broadcom/bcmbca -Itpl/board/broadcom/bcmbca -D__KERNEL__ -D__UBOOT__ -Wno-address-of-packed-member -DCONFIG_SPL_BUILD -DCONFIG_TPL_BUILD -Wall -Wstrict-prototypes -Wno-format-security -fno-builtin -ffreestanding -std=gnu11 -fshort-wchar -fno-strict-aliasing  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/../../router/shared -I../../router/shared -fno-PIE -Os -fstack-protector-strong -fno-delete-null-pointer-checks -fmacro-prefix-map=/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/= -g -fstack-usage -Wno-format-nonliteral -Werror=date-time -fcommon -Wno-error=unused-but-set-variable -Wno-error=discarded-qualifiers -Wno-error=int-conversion -ffunction-sections -fdata-sections -fstack-protector-strong -D__ARM__ -mstrict-align -ffunction-sections -fdata-sections -fno-common -ffixed-r9 -fno-common -ffixed-x18 -pipe -march=armv8-a -D__LINUX_ARM_ARCH__=8   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/include   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/pmc   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/pmc    -D"KBUILD_STR(s)=$(pound)s" -D"KBUILD_BASENAME=KBUILD_STR(bca_common)"  -D"KBUILD_MODNAME=KBUILD_STR(bca_common)" -c -o tpl/board/broadcom/bcmbca/bca_common.o /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/board/broadcom/bcmbca/bca_common.c

source_tpl/board/broadcom/bcmbca/bca_common.o := /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/board/broadcom/bcmbca/bca_common.c

deps_tpl/board/broadcom/bcmbca/bca_common.o := \
    $(wildcard include/config/bcmbca/xrdp/eth.h) \
    $(wildcard include/config/mtd.h) \
    $(wildcard include/config/nand.h) \
    $(wildcard include/config/sys/max/nand/device.h) \
    $(wildcard include/config/dm/mmc.h) \
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
    $(wildcard include/config/sys/nand/base.h) \
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
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/errno.h \
    $(wildcard include/config/errno/str.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/errno.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/time.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/typecheck.h \
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
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-offsets.h \
  include/generated/generic-asm-offsets.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/bitops.h \
    $(wildcard include/config/sandbox.h) \
    $(wildcard include/config/sandbox/bits/per/long.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/bitsperlong.h \
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
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/bitops.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/bitops/__ffs.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/proc-armv/system.h \
    $(wildcard include/config/cpu/sa1100.h) \
    $(wildcard include/config/cpu/sa110.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/bitops/__fls.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/bitops/fls.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/bitops/fls64.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/bug.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/vsprintf.h \
    $(wildcard include/config/panic/hang.h) \
  /home/docker/am-toolchains/brcm-arm-hnd/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/lib/gcc/aarch64-buildroot-linux-gnu/10.3.0/include/stdarg.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/build_bug.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/printk.h \
    $(wildcard include/config/loglevel.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/stdio.h \
    $(wildcard include/config/tpl/serial/support.h) \
    $(wildcard include/config/spl/serial/support.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/delay.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/kernel.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/string.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/string.h \
    $(wildcard include/config/spl/use/arch/memcpy.h) \
    $(wildcard include/config/spl/use/arch/memset.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/linux_string.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/stringify.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/ptrace.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/proc-armv/ptrace.h \
    $(wildcard include/config/arm/thumb.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/part.h \
    $(wildcard include/config/spl/partition/uuids.h) \
    $(wildcard include/config/partition/type/guid.h) \
    $(wildcard include/config/dos/partition.h) \
    $(wildcard include/config/partitions.h) \
    $(wildcard include/config/spl/fs/ext4.h) \
    $(wildcard include/config/spl/fs/fat.h) \
    $(wildcard include/config/sys/mmcsd/raw/mode/u/boot/partition.h) \
    $(wildcard include/config/spl/efi/partition.h) \
    $(wildcard include/config/spl/dos/partition.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/blk.h \
    $(wildcard include/config/sys/64bit/lba.h) \
    $(wildcard include/config/bcmbca/vfbio.h) \
    $(wildcard include/config/blk.h) \
    $(wildcard include/config/lba48.h) \
    $(wildcard include/config/spl/blk.h) \
    $(wildcard include/config/spl/block/cache.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/efi.h \
    $(wildcard include/config/efi/stub/64bit.h) \
    $(wildcard include/config/x86/64.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/linkage.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/linkage.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/ide.h \
    $(wildcard include/config/sys/ide/maxdevice.h) \
    $(wildcard include/config/sys/ide/maxbus.h) \
    $(wildcard include/config/sys/ata/base/addr.h) \
    $(wildcard include/config/ide/preinit.h) \
    $(wildcard include/config/of/ide/fixup.h) \
    $(wildcard include/config/ide/ahb.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/uuid.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/list.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/poison.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/part_efi.h \
    $(wildcard include/config/efi/partition/entries/numbers.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/flash.h \
    $(wildcard include/config/sys/max/flash/sect.h) \
    $(wildcard include/config/sys/flash/cfi.h) \
    $(wildcard include/config/cfi/flash.h) \
    $(wildcard include/config/flash/cfi/mtd.h) \
    $(wildcard include/config/sys/flash/protection.h) \
    $(wildcard include/config/flash/cfi/legacy.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/image.h \
    $(wildcard include/config/fit/verbose.h) \
    $(wildcard include/config/fit/enable/rsassa/pss/support.h) \
    $(wildcard include/config/fit/enable/sha256/support.h) \
    $(wildcard include/config/sha1.h) \
    $(wildcard include/config/sha256.h) \
    $(wildcard include/config/spl/fit.h) \
    $(wildcard include/config/spl/of/libfdt.h) \
    $(wildcard include/config/spl/crc32/support.h) \
    $(wildcard include/config/spl/md5/support.h) \
    $(wildcard include/config/spl/sha1/support.h) \
    $(wildcard include/config/spl/sha256/support.h) \
    $(wildcard include/config/sys/boot/get/cmdline.h) \
    $(wildcard include/config/of/board/setup.h) \
    $(wildcard include/config/of/system/setup.h) \
    $(wildcard include/config/timestamp.h) \
    $(wildcard include/config/cmd/date.h) \
    $(wildcard include/config/image/format/legacy.h) \
    $(wildcard include/config/sys/boot/get/kbd.h) \
    $(wildcard include/config/fit/signature.h) \
    $(wildcard include/config/spl/fit/signature.h) \
    $(wildcard include/config/fit/best/match.h) \
    $(wildcard include/config/fit.h) \
    $(wildcard include/config/android/boot/image.h) \
    $(wildcard include/config/spl/fit/image/post/process.h) \
    $(wildcard include/config/fit/image/post/process.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/compiler.h \
  /home/docker/am-toolchains/brcm-arm-hnd/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/lib/gcc/aarch64-buildroot-linux-gnu/10.3.0/include/stddef.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/byteorder.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/byteorder/little_endian.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/byteorder/swab.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/byteorder/generic.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/lmb.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/u-boot.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/u-boot.h \
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
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/command.h \
    $(wildcard include/config/sys/help/cmd/width.h) \
    $(wildcard include/config/sys/longhelp.h) \
    $(wildcard include/config/cmd/run.h) \
    $(wildcard include/config/cmd/memory.h) \
    $(wildcard include/config/cmd/i2c.h) \
    $(wildcard include/config/cmd/itest.h) \
    $(wildcard include/config/cmd/pci.h) \
    $(wildcard include/config/cmd/setexpr.h) \
    $(wildcard include/config/cmd/bootd.h) \
    $(wildcard include/config/cmd/bootm.h) \
    $(wildcard include/config/cmd/nvedit/efi.h) \
    $(wildcard include/config/cmdline.h) \
    $(wildcard include/config/needs/manual/reloc.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linker_lists.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/hash.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/libfdt.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/libfdt_env.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/../../scripts/dtc/libfdt/libfdt.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/../../scripts/dtc/libfdt/libfdt_env.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/../../scripts/dtc/libfdt/fdt.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/fdt_support.h \
    $(wildcard include/config/of/libfdt.h) \
    $(wildcard include/config/arch/fixup/fdt/memory.h) \
    $(wildcard include/config/usb/ehci/fsl.h) \
    $(wildcard include/config/usb/xhci/fsl.h) \
    $(wildcard include/config/sys/fsl/sec/compat.h) \
    $(wildcard include/config/pci.h) \
    $(wildcard include/config/fdt/fixup/partitions.h) \
    $(wildcard include/config/fman/enet.h) \
    $(wildcard include/config/fsl/mc/enet.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/u-boot/rsa-checksum.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/u-boot/sha1.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/u-boot/sha256.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/log.h \
    $(wildcard include/config/log.h) \
    $(wildcard include/config/log/max/level.h) \
    $(wildcard include/config/spl/log.h) \
    $(wildcard include/config/spl/log/max/level.h) \
    $(wildcard include/config/log/error/return.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/uclass-id.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/global_data.h \
    $(wildcard include/config/fsl/esdhc.h) \
    $(wildcard include/config/u/qe.h) \
    $(wildcard include/config/at91family.h) \
    $(wildcard include/config/spl/sys/icache/off.h) \
    $(wildcard include/config/spl/sys/dcache/off.h) \
    $(wildcard include/config/sys/mem/reserve/secure.h) \
    $(wildcard include/config/resv/ram.h) \
    $(wildcard include/config/arch/omap2plus.h) \
    $(wildcard include/config/fsl/lsch3.h) \
    $(wildcard include/config/sys/fsl/has/dp/ddr.h) \
    $(wildcard include/config/arch/imx8.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/asm-generic/global_data.h \
    $(wildcard include/config/lcd.h) \
    $(wildcard include/config/video.h) \
    $(wildcard include/config/board/types.h) \
    $(wildcard include/config/spl/pre/console/buffer.h) \
    $(wildcard include/config/dm.h) \
    $(wildcard include/config/timer.h) \
    $(wildcard include/config/of/live.h) \
    $(wildcard include/config/spl/multi/dtb/fit.h) \
    $(wildcard include/config/trace.h) \
    $(wildcard include/config/sys/i2c/mxc.h) \
    $(wildcard include/config/spl/sys/malloc/f/len.h) \
    $(wildcard include/config/pci/bootdelay.h) \
    $(wildcard include/config/console/record.h) \
    $(wildcard include/config/dm/video.h) \
    $(wildcard include/config/bootstage.h) \
    $(wildcard include/config/spl/bloblist.h) \
    $(wildcard include/config/translation/offset.h) \
    $(wildcard include/config/wdt.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/fdtdec.h \
    $(wildcard include/config/spl/of/prior/stage.h) \
    $(wildcard include/config/of/board.h) \
    $(wildcard include/config/of/separate.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/pci.h \
    $(wildcard include/config/sys/pci/64bit.h) \
    $(wildcard include/config/dm/pci.h) \
    $(wildcard include/config/pci/indirect/bridge.h) \
    $(wildcard include/config/dm/pci/compat.h) \
    $(wildcard include/config/pci/fixup/dev.h) \
    $(wildcard include/config/mpc85xx.h) \
    $(wildcard include/config/pcie/imx.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/pci_ids.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/membuff.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/init.h \
    $(wildcard include/config/spl/cpu.h) \
    $(wildcard include/config/dtb/reselect.h) \
    $(wildcard include/config/vid.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/display_options.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/u-boot/crc.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/net.h \
    $(wildcard include/config/sys/rx/eth/buffer.h) \
    $(wildcard include/config/dm/eth.h) \
    $(wildcard include/config/api.h) \
    $(wildcard include/config/efi/loader.h) \
    $(wildcard include/config/bootp/dns2.h) \
    $(wildcard include/config/cmd/dns.h) \
    $(wildcard include/config/cmd/ping.h) \
    $(wildcard include/config/cmd/cdp.h) \
    $(wildcard include/config/cmd/sntp.h) \
    $(wildcard include/config/netconsole.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/cache.h \
    $(wildcard include/config/spl/sys/thumb/build.h) \
    $(wildcard include/config/armv7/lpae.h) \
    $(wildcard include/config/sys/cacheline/size.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/system.h \
    $(wildcard include/config/bcm6888.h) \
    $(wildcard include/config/bcm68880.h) \
    $(wildcard include/config/bcm6837.h) \
    $(wildcard include/config/armv8/psci.h) \
    $(wildcard include/config/bcm963148.h) \
    $(wildcard include/config/bcm63138.h) \
    $(wildcard include/config/cpu/v7a.h) \
    $(wildcard include/config/sys/noncached/memory.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/barriers.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/if_ether.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/bootstage.h \
    $(wildcard include/config/spl/bootstage.h) \
    $(wildcard include/config/show/boot/progress.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/ctype.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/stdlib.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/malloc.h \
    $(wildcard include/config/spl/sys/malloc/simple.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/string.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/mmc.h \
    $(wildcard include/config/spl/mmc/hs200/support.h) \
    $(wildcard include/config/spl/mmc/uhs/support.h) \
    $(wildcard include/config/spl/dm/mmc.h) \
    $(wildcard include/config/spl/mmc/hs400/support.h) \
    $(wildcard include/config/spl/mmc/write.h) \
    $(wildcard include/config/spl/mmc/hw/partitioning.h) \
    $(wildcard include/config/spl/dm/regulator.h) \
    $(wildcard include/config/cmd/bkops/enable.h) \
    $(wildcard include/config/mmc/spi.h) \
    $(wildcard include/config/sys/mmc/env/part.h) \
    $(wildcard include/config/sys/mmc/max/blk/count.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/mtd.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/mtd/mtd.h \
    $(wildcard include/config/sys/nand/max/oobfree.h) \
    $(wildcard include/config/sys/nand/max/eccpos.h) \
    $(wildcard include/config/mtd/partitions.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/compat.h \
    $(wildcard include/config/lbdaf.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/err.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/mtd/mtd-abi.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/div64.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/device.h \
    $(wildcard include/config/devres.h) \
    $(wildcard include/config/spl/of/control.h) \
    $(wildcard include/config/debug/devres.h) \
    $(wildcard include/config/spl/loglevel.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/ofnode.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/of.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/spl.h \
    $(wildcard include/config/tpl.h) \
    $(wildcard include/config/spl/load/fit.h) \
    $(wildcard include/config/spl/load/fit/full.h) \
    $(wildcard include/config/spl/legacy/image/crc/check.h) \
    $(wildcard include/config/sys/uboot/start.h) \
    $(wildcard include/config/spl/panic/on/raw/image.h) \
    $(wildcard include/config/spl/raw/image/support.h) \
    $(wildcard include/config/spl/display/print.h) \
    $(wildcard include/config/spl/libcommon/support.h) \
    $(wildcard include/config/spl/stack/r/malloc/simple/len.h) \
    $(wildcard include/config/spl/board/init.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/binman_sym.h \
    $(wildcard include/config/binman.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include/asm/spl.h \
    $(wildcard include/config/exynos4.h) \
    $(wildcard include/config/exynos5.h) \
    $(wildcard include/config/exynos4210.h) \
    $(wildcard include/config/arch/k3.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/handoff.h \
    $(wildcard include/config/spl/handoff.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/include/bca_common.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/include/boot_flash.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/include/bcm_strap_drv.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/fdtaddr.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/read.h \
    $(wildcard include/config/spl/of/live.h) \
    $(wildcard include/config/dm/dev/read/inline.h) \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/uclass.h \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/dm/platdata.h \
    $(wildcard include/config/spl/of/platdata.h) \

tpl/board/broadcom/bcmbca/bca_common.o: $(deps_tpl/board/broadcom/bcmbca/bca_common.o)

$(deps_tpl/board/broadcom/bcmbca/bca_common.o):
