:orphan:

########################
lib_adat: ADAT Lightpipe
########################

:vendor: XMOS
:version: 1.2.0
:scope: General Use
:description: ADAT Lightpipe digital audio interface
:category: Audio
:keywords: ADAT
:devices: xcore.ai, xcore-200

*******
Summary
*******

The modules in this repo implement an ADAT transmitter and receiver in a
core each. Separate cores are required to collect and supply data.

********
Features
********

  * 48000 and 44100 ADAT receivers
  * 48000 and 44100 ADAT transmitters
  * Application for loopback testing on Simulator or hardware

************
Known Issues
************

  * This software relies on the reference clock being 100 MHz, there is no out of the box version i
    for non 100 Mhz reference clocks.
  * ADAT Tx for 256x master clock (i.e. 48kHz from 12.288MHz master clock) not yet implemented

**************
Required Tools
**************

  * XMOS XTC Tools: 15.3.0

*********************************
Required Libraries (dependencies)
*********************************

  * None

*************************
Related Application Notes
*************************

The following application notes use this library:

  * `AN02003: SPDIF/ADAT/I2S Receive to I2S Slave Bridge with ASRC <https://www.xmos.com/file/an02003>`_

*******
Support
*******

This package is supported by XMOS Ltd. Issues can be raised against the software at: http://www.xmos.com/support

