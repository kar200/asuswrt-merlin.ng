// SPDX-License-Identifier: GPL-2.0+
/*
   Copyright (c) 2016 Broadcom Corporation
   All Rights Reserved

    
*/

/*
 *  Created on: Aug 2017
 *      Author: dima.mamut@broadcom.com
 */

#include "bus_drv.h"
/*
 * This file is the 675x (merlin-ng) revision, which was written against the
 * four-argument API declared in mdio_drv_impl5.h:
 *
 *     mdio_read_c22_register(mdio_type_t type, uint32_t addr, ...)
 *
 * For BRCM_CHIP=6856 the Makefile deliberately links mdio_drv_v1.o instead
 * (only that driver binds compatible="brcm,mdio1", which is the node our
 * bcm96856.dts provides), and mdio_drv_v1.c implements the three-argument API:
 *
 *     mdio_read_c22_register(uint32_t addr, uint32_t reg, uint16_t *val)
 *
 * Calling the four-argument prototype against the three-argument definition
 * compiles and links silently (the linker does not check arity) but shifts
 * every argument: the callee sees addr=MDIO_INT(=1), reg=phy_dev->addr and
 * val=(uint16_t *)reg.  The result was that every PHY access went to PHY 1
 * regardless of the real address, and the 16-bit result was written to a bogus
 * low address instead of the caller's variable -- which is why the EGPHY
 * driver reported "UNIMAC PHY ID 0x0" while a manual MDIO poke proved that all
 * four internal GPHYs answer at addresses 1..4 with ID 0xae02:0x51f1.
 *
 * So call the three-argument API directly.  There is a single mdio_drv_v1
 * controller (one "brcm,mdio1" node) on this board and both the internal and
 * the external descriptor therefore address that one controller.
 */
#include "mdio_drv_v1.h"

/* Internal MDIO bus */
static int bus_mdio_v1_int_c22_read(uint32_t addr, uint16_t reg, uint16_t *val)
{
    return mdio_read_c22_register(addr, reg, val);
}

static int bus_mdio_v1_int_c22_write(uint32_t addr, uint16_t reg, uint16_t val)
{
    return mdio_write_c22_register(addr, reg, val);
}

static int bus_mdio_v1_int_c45_read(uint32_t addr, uint16_t dev, uint16_t reg, uint16_t *val)
{
    return mdio_read_c45_register(addr, dev, reg, val);
}

static int bus_mdio_v1_int_c45_write(uint32_t addr, uint16_t dev, uint16_t reg, uint16_t val)
{
    return mdio_write_c45_register(addr, dev, reg, val);
}

bus_drv_t bus_mdio_v1_int_drv =
{
    .c22_read = bus_mdio_v1_int_c22_read,
    .c22_write = bus_mdio_v1_int_c22_write,
    .c45_read = bus_mdio_v1_int_c45_read,
    .c45_write = bus_mdio_v1_int_c45_write,
};


/* External MDIO bus */
static int bus_mdio_v1_ext_c22_read(uint32_t addr, uint16_t reg, uint16_t *val)
{
    return mdio_read_c22_register(addr, reg, val);
}

static int bus_mdio_v1_ext_c22_write(uint32_t addr, uint16_t reg, uint16_t val)
{
    return mdio_write_c22_register(addr, reg, val);
}

static int bus_mdio_v1_ext_c45_read(uint32_t addr, uint16_t dev, uint16_t reg, uint16_t *val)
{
    return mdio_read_c45_register(addr, dev, reg, val);
}

static int bus_mdio_v1_ext_c45_write(uint32_t addr, uint16_t dev, uint16_t reg, uint16_t val)
{
    return mdio_write_c45_register(addr, dev, reg, val);
}

bus_drv_t bus_mdio_v1_ext_drv =
{
    .c22_read = bus_mdio_v1_ext_c22_read,
    .c22_write = bus_mdio_v1_ext_c22_write,
    .c45_read = bus_mdio_v1_ext_c45_read,
    .c45_write = bus_mdio_v1_ext_c45_write,
};
