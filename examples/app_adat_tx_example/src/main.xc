// Copyright 2011-2024 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <xs1.h>
#include <xclib.h>
#include <print.h>
#include "adat_tx.h"

//::declaration
buffered out port:32 adat_port = XS1_PORT_1P;
in port mck = XS1_PORT_1O;
clock mck_blk = XS1_CLKBLK_2;
//::

//::setup
void setupClocks() {
    set_clock_src(mck_blk, mck);
    set_clock_fall_delay(mck_blk, 7);   // XAI2 board, set to appropriate value for board.
    set_port_clock(adat_port, mck_blk);
    start_clock(mck_blk);
}
//::

//::drive
void drivePort(chanend c_port) {
    setupClocks();
    while (1) {
        adat_port <: byterev(inuint(c_port));
    }
}
//::

//::generate
void generateData(chanend c_data) {
    outuint(c_data, 512);    // master clock multiplier (1024, 256, or 512)
    outuint(c_data, 0);      // SMUX flag (0, 2, or 4)
    for (int i = 0; i < 1000; i++) {
        outuint(c_data, i);  // left aligned data (only 24 bits will be used)
    }
    outct(c_data, XS1_CT_END);
}
//::

//::main
int main(void) {
    chan c_data;
    chan c_port;

    par {
        generateData(c_data);
        adat_tx(c_data, c_port);
        drivePort(c_port);
    }
    return 0;
}
//::
