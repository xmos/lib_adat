// Copyright 2011-2024 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xs1.h>
#include <xclib.h>
#include "adat_tx.h"

extern "C" {
    #include "sw_pll.h"
}

buffered out port:32 p_adat_tx = PORT_ADAT_OUT;
in port p_mclk_in = PORT_MCLK_IN;
out port p_ctrl = PORT_CTRL;
on tile[1]: clock clk_audio = XS1_CLKBLK_2;

#define MCLK_FREQUENCY_48  24576000

void board_setup(void)
{
    set_port_drive_high(p_ctrl);

    // Drive control port to turn on 3V3.
    // Bits set to low will be high-z, pulled down.
    p_ctrl <: 0xA0;

    // Wait for power supplies to be up and stable.
    delay_milliseconds(10);

    sw_pll_fixed_clock(MCLK_FREQUENCY_48);

    while (1) {}
}

void drive_port(chanend c_port) {
    while (1) {
        p_adat_tx <: byterev(inuint(c_port));
    }
}

void transmit_adat(chanend c) {
    chan c_port;

    set_clock_src(clk_audio, p_mclk_in);
    configure_out_port_no_ready(p_adat_tx, clk_audio, 0);
    set_clock_fall_delay(clk_audio, 7);
    start_clock(clk_audio);

    par {
        adat_tx(c, c_port);
        drive_port(c_port);
    }
}

#define SINE_TABLE_SIZE 100
const int sine_table[SINE_TABLE_SIZE] =
{
    0x0100da00,0x0200b000,0x02fe8100,0x03f94b00,0x04f01100,
    0x05e1da00,0x06cdb200,0x07b2aa00,0x088fdb00,0x09646600,
    0x0a2f7400,0x0af03700,0x0ba5ed00,0x0c4fde00,0x0ced5f00,
    0x0d7dd100,0x0e00a100,0x0e754b00,0x0edb5a00,0x0f326700,
    0x0f7a1800,0x0fb22700,0x0fda5b00,0x0ff28a00,0x0ffa9c00,
    0x0ff28a00,0x0fda5b00,0x0fb22700,0x0f7a1800,0x0f326700,
    0x0edb5a00,0x0e754b00,0x0e00a100,0x0d7dd100,0x0ced5f00,
    0x0c4fde00,0x0ba5ed00,0x0af03700,0x0a2f7400,0x09646600,
    0x088fdb00,0x07b2aa00,0x06cdb200,0x05e1da00,0x04f01100,
    0x03f94b00,0x02fe8100,0x0200b000,0x0100da00,0x00000000,
    0xfeff2600,0xfdff5000,0xfd017f00,0xfc06b500,0xfb0fef00,
    0xfa1e2600,0xf9324e00,0xf84d5600,0xf7702500,0xf69b9a00,
    0xf5d08c00,0xf50fc900,0xf45a1300,0xf3b02200,0xf312a100,
    0xf2822f00,0xf1ff5f00,0xf18ab500,0xf124a600,0xf0cd9900,
    0xf085e800,0xf04dd900,0xf025a500,0xf00d7600,0xf0056400,
    0xf00d7600,0xf025a500,0xf04dd900,0xf085e800,0xf0cd9900,
    0xf124a600,0xf18ab500,0xf1ff5f00,0xf2822f00,0xf312a100,
    0xf3b02200,0xf45a1300,0xf50fc900,0xf5d08c00,0xf69b9a00,
    0xf7702500,0xf84d5600,0xf9324e00,0xfa1e2600,0xfb0fef00,
    0xfc06b500,0xfd017f00,0xfdff5000,0xfeff2600,0x00000000,
};

void generate_samples(chanend c) {
    int count1 = 0;
    int count2 = 0;
    int count4 = 0;
    outuint(c, MCLK_FREQUENCY_48 / 48000);  // clock multiplier value
    outuint(c, 0);                          // S/MUX value

    for (int idx = 0; idx < 8; ++idx) {
        outuint(c, 0);
    }

    while(1) {
        // Send the next samples
        outuint(c, sine_table[count1]);                         // 500Hz sine
        outuint(c, sine_table[SINE_TABLE_SIZE - 1 - count1]);   // 500Hz sine, phase-shifted from channel 0
        outuint(c, sine_table[count2]);                         // 1000Hz sine
        outuint(c, sine_table[SINE_TABLE_SIZE - 1 - count2]);   // 1000Hz sine, phase-shifted from channel 2
        outuint(c, sine_table[count4]);                         // 2000Hz sine
        outuint(c, sine_table[SINE_TABLE_SIZE - 1 - count4]);   // 2000Hz sine, phase-shifted from channel 4
        outuint(c, sine_table[count1]);                         // same as channel 0
        outuint(c, sine_table[SINE_TABLE_SIZE - 1 - count1]);   // same as channel 1

        // Handle rollover of the sine_table array indices
        count1 += 1;
        count2 += 2;
        count4 += 4;
        if (count1 == SINE_TABLE_SIZE) {
            count1 = 0;
            count2 = 0;
            count4 = 0;
        } else if (count2 == SINE_TABLE_SIZE) {
            count2 = 0;
            count4 = 0;
        } else if (count4 == SINE_TABLE_SIZE) {
            count4 = 0;
        }
    }
}

int main(void) {

    chan c;
    par
    {
        on tile[0]: board_setup();
        on tile[1]: transmit_adat(c);
        on tile[1]: generate_samples(c);
    }
    return 0;
}
