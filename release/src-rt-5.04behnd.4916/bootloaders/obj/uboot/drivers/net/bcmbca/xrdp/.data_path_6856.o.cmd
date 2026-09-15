cmd_drivers/net/bcmbca/xrdp/data_path_6856.o := /opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/aarch64-linux-gcc -Wp,-MD,drivers/net/bcmbca/xrdp/.data_path_6856.o.d  -nostdinc -isystem /home/docker/am-toolchains/brcm-arm-hnd/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/bin/../lib/gcc/aarch64-buildroot-linux-gnu/10.3.0/include -Iinclude  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include -include /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/kconfig.h  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/xrdp -Idrivers/net/bcmbca/xrdp -D__KERNEL__ -D__UBOOT__ -Wno-address-of-packed-member -DCONFIG_BCM96856 -Werror -DXRDP_SBPM -DGEN45 -Wall -Wstrict-prototypes -Wno-format-security -fno-builtin -ffreestanding -std=gnu11 -fshort-wchar -fno-strict-aliasing  -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/../../router/shared -I../../router/shared -fno-PIE -Os -fstack-protector-strong -fno-delete-null-pointer-checks -fmacro-prefix-map=/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/= -g -fstack-usage -Wno-format-nonliteral -Werror=date-time -fcommon -Wno-error=unused-but-set-variable -Wno-error=discarded-qualifiers -Wno-error=int-conversion -D__ARM__ -fno-pic -mstrict-align -ffunction-sections -fdata-sections -fno-common -ffixed-r9 -fno-common -ffixed-x18 -pipe -march=armv8-a -D__LINUX_ARM_ARCH__=8   -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/mach-bcmbca/include    -D"KBUILD_STR(s)=$(pound)s" -D"KBUILD_BASENAME=KBUILD_STR(data_path_6856)"  -D"KBUILD_MODNAME=KBUILD_STR(data_path_6856)" -c -o drivers/net/bcmbca/xrdp/data_path_6856.o /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/xrdp/data_path_6856.c

source_drivers/net/bcmbca/xrdp/data_path_6856.o := /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/xrdp/data_path_6856.c

deps_drivers/net/bcmbca/xrdp/data_path_6856.o := \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/drivers/net/bcmbca/xrdp/access_logging.h \
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

drivers/net/bcmbca/xrdp/data_path_6856.o: $(deps_drivers/net/bcmbca/xrdp/data_path_6856.o)

$(deps_drivers/net/bcmbca/xrdp/data_path_6856.o):
