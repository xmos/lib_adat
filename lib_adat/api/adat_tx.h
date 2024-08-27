// Copyright 2011-2024 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.

#include <xccompat.h>

/**
 * \addtogroup lib_adat_tx
 *
 * The public API for using the lib_adat tx.
 * @{
 */

/**
 * Function that takes data over a channel end, and that outputs this in
 * ADAT format onto a 1-bit port. The 1-bit port should be clocked by the
 * master-clock, and an external flop should be used to precisely align the
 * edge of the signal to the master-clock.
 *
 * Data should be send onto c_data using outuint only, the first two values
 * should be The multiplier and the smux values, after that output any
 * number of eight samples (24-bit, right aligned), and if the process is
 * to be terminated send it an control token 1.
 *
 * The data is output onto a channel, which a separate process should
 * output to a port. This process should byte-reverse every word read over
 * the channel, and then output the reversed word to a buffered 1-bit port.
 *
 * \param   c_data   Channel over which to send sample values to the transmitter
 *
 * \param   c_port   Channel on which to generate the ADAT stream
 */
void adat_tx(chanend c_data, chanend c_port);

/**
 * Function that takes data over a channel end, and that outputs this in
 * ADAT format onto a 1-bit port. The 1-bit port should be clocked by the
 * master-clock, and an external flop should be used to precisely align the
 * edge of the signal to the master-clock.
 *
 * Data should be send onto c_data using outuint only, the first two values
 * should be The multiplier and the smux values, after that output any
 * number of eight samples (24-bit, right aligned), and if the process is
 * to be terminated send it an control token 1.
 *
 * \param   c_data   Channel over which to send sample values to the transmitter
 *
 * \param   p_data   1-bit, 32-bit buffered, port on which to generate the ADAT stream
 */
void adat_tx_port(chanend c_data, out_buffered_port_32_t p_data);

/**@}*/ // END: addtogroup lib_adat_rx

