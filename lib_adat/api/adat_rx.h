// Copyright 2011-2024 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.

#include <xccompat.h>

/**
 * \addtogroup lib_adat_rx
 *
 * The public API for using the lib_adat rx.
 * @{
 */

/** ADAT Receive Thread (48kHz sample rate).
 *
 *  When a data rame is received, samples will be output onto the streaming channel
 *  At first a word 0x000000Z1 will be output, where ``Z`` are the user data; after
 *  that eight words 0x0ZZZZZZ0 will be output where ``ZZZZZZ`` is a 24-bit sample value.
 *  The eight words may refer to sample values on eight channels, or on fewer channels if
 *  muxing is used.
 *
 *  The function will return if it cannot lock onto a 48,000 Hz
 *  signal. Normally the 48000 function is called in a while(1) loop. If
 *  both 44,100 and 48,000 need to be supported, they should be called in
 *  sequence in a while(1) loop. Note that the functions are large, and
 *  that 44,100 should not be called if 44.1 KHz does not need to be supported.
 *
 *  \param p     ADAT port - should be 1-bit, 32-bit buffered, and clocked at 100MHz
 *  \param oChan channel on which decoded samples are output
 **/
void adatReceiver48000(in_buffered_port_32_t p, streaming_chanend_t oChan);

/** ADAT Receive Thread (44.1kHz sample rate).
 *
 *  When a data rame is received, samples will be output onto the streaming channel
 *  At first a word 0x000000Z1 will be output, where ``Z`` are the user data; after
 *  that eight words 0x0ZZZZZZ0 will be output where ``ZZZZZZ`` is a 24-bit sample value.
 *  The eight words may refer to sample values on eight channels, or on fewer channels if
 *  muxing is used.
 *
 *  The function will return if it cannot lock onto a 44,100 Hz
 *  signal. Normally the 44,100 function is called in a while(1) loop. If
 *  both 44,100 and 48,000 need to be supported, they should be called in
 *  sequence in a while(1) loop. Note that the functions are large, and
 *  that 48,000 should not be called if 48 Khz does not need to be supported.
 *
 *  \param p     ADAT port - should be 1-bit 32-bit buffered, and clocked at 100MHz
 *  \param oChan channel on which decoded samples are output
 **/
void adatReceiver44100(in_buffered_port_32_t p, streaming_chanend_t oChan);

/**@}*/ // END: addtogroup lib_adat_rx

