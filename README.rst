:orphan:

########################
lib_adat: ADAT Lightpipe
########################

:vendor: XMOS
:version: 2.0.0
:scope: General Use
:description: ADAT Lightpipe digital audio interface
:category: Audio
:keywords: ADAT
:devices: xcore.ai, xcore-200

*******
Summary
*******

Provides ADAT transmitter and receiver implementations, each in a separate thread. Additional
threads are required to collect and supply data via a channel end interface. These threads are
required to deal with any sample ordering required for S/MUX.

********
=======
>>>>>>> 652c5b60f1b18267c3b74d945f574b70520cf55e
Features
********

  * 48000 and 44100 ADAT receivers
  * 48000 and 44100 ADAT transmitters
  * Application for loopback testing on Simulator or hardware

************
Known Issues
************

  * ADAT Rx: Requirement for 100 MHz reference clock (#18)
  * ADAT Tx: No support for 256x master clock (i.e. 48 kHz from 12.288 MHz master clock) (#17)

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

  * `AN02003: SPDIF/ADAT/I²S Receive to I²S Slave Bridge with ASRC <https://www.xmos.com/file/an02003>`_

*******
Support
*******

This package is supported by XMOS Ltd. Issues can be raised against the software at: http://www.xmos.com/support

