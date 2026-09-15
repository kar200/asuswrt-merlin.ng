cmd_arch/arm/dts/bcm96856.dtb := mkdir -p arch/arm/dts/ ; (cat /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/dts/bcm96856.dts; ) > arch/arm/dts/.bcm96856.dtb.pre.tmp; /opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/aarch64-linux-gcc -E -Wp,-MD,arch/arm/dts/.bcm96856.dtb.d.pre.tmp -nostdinc -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/dts -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/dts/include -Iinclude -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include -I/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/include -include /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/include/linux/kconfig.h -D__ASSEMBLY__ -undef -D__DTS__ -x assembler-with-cpp -o arch/arm/dts/.bcm96856.dtb.dts.tmp arch/arm/dts/.bcm96856.dtb.pre.tmp ; ./scripts/dtc/dtc -O dtb -o arch/arm/dts/bcm96856.dtb -b 0 -i /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/dts/  -Wno-unit_address_vs_reg -Wno-simple_bus_reg -Wno-unit_address_format -Wno-pci_bridge -Wno-pci_device_bus_num -Wno-pci_device_reg -Wno-avoid_unnecessary_addr_size -Wno-alias_paths  -d arch/arm/dts/.bcm96856.dtb.d.dtc.tmp arch/arm/dts/.bcm96856.dtb.dts.tmp ; cat arch/arm/dts/.bcm96856.dtb.d.pre.tmp arch/arm/dts/.bcm96856.dtb.d.dtc.tmp > arch/arm/dts/.bcm96856.dtb.d ; sed -i "s:arch/arm/dts/.bcm96856.dtb.pre.tmp:/build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/dts/bcm96856.dts:" arch/arm/dts/.bcm96856.dtb.d

source_arch/arm/dts/bcm96856.dtb := /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/dts/bcm96856.dts

deps_arch/arm/dts/bcm96856.dtb := \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/dts/bcm6856.dtsi \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/dts/skeleton64.dtsi \
  /build/asuswrt-merlin/release/src-rt-5.04behnd.4916/bootloaders/u-boot-2019.07/arch/arm/dts/bcm6856-pinctrl.dtsi \

arch/arm/dts/bcm96856.dtb: $(deps_arch/arm/dts/bcm96856.dtb)

$(deps_arch/arm/dts/bcm96856.dtb):
