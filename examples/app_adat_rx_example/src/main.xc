// Copyright 2011-2024 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xs1.h>
#include <print.h>
#include "adat_rx.h"

/* Port declarations */
buffered in port:32 p_adat_rx = PORT_ADAT_IN;
out port p_ctrl = PORT_CTRL;

/* Receive loop */
void receive_adat(streaming chanend c)
{
    while(1)
    {
        adatReceiver48000(p_adat_rx, c);
        adatReceiver44100(p_adat_rx, c);
    }
}
//::

/* Data handler */
void collect_samples(streaming chanend c)
{
    unsigned head, channels[9];
    int count = 0;

    while(1)
    {
        for(int i = 0; i < 9; i++)
        {
            c :> head;
            if ((head & 0xF) == 1)
            {
                break;
            }
            channels[i] = head;
        }
        ++count;

        if ((count % 100000) == 0)
        {
            printstr("Frames received: ");
            printintln(count);
        }
        // One whole frame in channels [0..7]
    }
}
//::

void board_setup(void)
{
    set_port_drive_high(p_ctrl);

    // Drive control port to turn on 3V3.
    // Bits set to low will be high-z, pulled down.
    p_ctrl <: 0xA0;

    // Wait for power supplies to be up and stable.
    delay_milliseconds(10);
}

/* Top-level main */
int main(void)
{
    streaming chan c;
    par
    {
        on tile[0]:
        {
            board_setup();
            receive_adat(c);
        }
        on tile[0]: collect_samples(c);
    }
    return 0;
}
//::
