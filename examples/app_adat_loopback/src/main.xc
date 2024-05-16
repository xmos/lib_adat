// Copyright 2011-2024 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xs1.h>
#include "adat_tx.h"
#include "adat_rx.h"
#include "stdio.h"
#include "assert.h"

#define MAX_GEN_VAL (1<<24)
#define COUNT_SHIFT 5
#define DONE_CONDITION_MASK ~((1<<COUNT_SHIFT)-1)

buffered out port:32 p_adat_tx = PORT_ADAT_OUT;
buffered in port:32 p_adat_rx = PORT_ADAT_IN;
in port p_mclk_in = PORT_MCLK_IN;
out port p_ctrl = PORT_CTRL;
on tile[1]: clock clk_audio = XS1_CLKBLK_2;

// Found solution: IN 24.000MHz, OUT 24.576000MHz, VCO 2457.60MHz, RD 1, FD 102.400 (m = 2, n = 5), OD 5, FOD 5, ERR 0.0ppm
// Measure: 100Hz-40kHz: ~8ps
// 100Hz-1MHz: 63ps.
// 100Hz high pass: 127ps.
#define APP_PLL_CTL_24M  0x0A006500
#define APP_PLL_DIV_24M  0x80000004
#define APP_PLL_FRAC_24M 0x80000104

// Set secondary (App) PLL control register
void set_app_pll_init (tileref tile, int app_pll_ctl)
{
    // Disable the PLL
    write_node_config_reg(tile, XS1_SSWITCH_SS_APP_PLL_CTL_NUM, (app_pll_ctl & 0xF7FFFFFF));
    // Enable the PLL to invoke a reset on the appPLL.
    write_node_config_reg(tile, XS1_SSWITCH_SS_APP_PLL_CTL_NUM, app_pll_ctl);
    // Must write the CTL register twice so that the F and R divider values are captured using a running clock.
    write_node_config_reg(tile, XS1_SSWITCH_SS_APP_PLL_CTL_NUM, app_pll_ctl);
    // Now disable and re-enable the PLL so we get the full 5us reset time with the correct F and R values.
    write_node_config_reg(tile, XS1_SSWITCH_SS_APP_PLL_CTL_NUM, (app_pll_ctl & 0xF7FFFFFF));
    write_node_config_reg(tile, XS1_SSWITCH_SS_APP_PLL_CTL_NUM, app_pll_ctl);
    // Wait for PLL to lock.
    delay_microseconds(500);
}

void board_setup()
{
    set_port_drive_high(p_ctrl);

    // Drive control port to turn on 3V3.
    // Bits set to low will be high-z, pulled down.
    p_ctrl <: 0xA0;

    // Wait for power supplies to be up and stable.
    delay_milliseconds(10);

    set_app_pll_init(tile[0], APP_PLL_CTL_24M);
    write_node_config_reg(tile[0], XS1_SSWITCH_SS_APP_PLL_FRAC_N_DIVIDER_NUM, APP_PLL_FRAC_24M);
    write_node_config_reg(tile[0], XS1_SSWITCH_SS_APP_CLK_DIVIDER_NUM, APP_PLL_DIV_24M);
}

void collect_samples(chanend c) {
    unsigned expected_data = 0;
    unsigned count = 0;

    while(expected_data < MAX_GEN_VAL) {
        unsigned channels[8];

        inuint(c);

        for(int i = 0; i < 8; i++) {
            channels[i] = inuint(c);

            expected_data += 1 << (count >> COUNT_SHIFT);

            if(channels[i] != expected_data << 8) {
                printf("Error: Received data 0x%x differs from expected data 0x%x. Correctly received so far %d\n", channels[i], expected_data << 8, count);
                assert(0);
            }

            count++;
        }
    }
    printf("Received %d samples as expected\n", count);
}

#define MCLK_FREQUENCY_48  24576000
unsigned samples[8];

void generate_samples(chanend c_data) {
    unsigned data = 0;
    int count = 0;

    outuint(c_data, MCLK_FREQUENCY_48 / 48000);  // master clock multiplier
    outuint(c_data, 1);                          // S/MUX value

    while(1) {
        for (int i = 0; i < 8; ++i) {
            data += 1 << (count >> COUNT_SHIFT);
            ++count;
            samples[i] = data << 8;
        }

        unsafe {
            volatile unsigned * unsafe sample_ptr = (unsigned * unsafe) &samples[0];
            outuint(c_data, (unsigned) sample_ptr);
        }

        if (data >= MAX_GEN_VAL) {
            break;
        }

        inuint(c_data);
    };

    printf("Finished sending %d words\n", count);

    inuint(c_data);
    outct(c_data, XS1_CT_END);
}

void receive_adat(chanend c) {
    while(1) {
        adatReceiver48000(p_adat_rx, c);
    }
}

void transmit_adat(chanend c) {
    set_clock_src(clk_audio, p_mclk_in);
    configure_out_port_no_ready(p_adat_tx, clk_audio, 0);
    set_clock_fall_delay(clk_audio, 7);
    start_clock(clk_audio);

    adat_tx_port(c, p_adat_tx);
}

int main(void) {
    chan c_data_tx, c_data_rx;

    par {
        on tile[0]: {
            board_setup();
            receive_adat(c_data_rx);
        }
        on tile[0]: collect_samples(c_data_rx);
        on tile[1]: generate_samples(c_data_tx);
        on tile[1]: transmit_adat(c_data_tx);
    }
    return 0;
}
