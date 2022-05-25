ADAT Lightpipe Digital Audio Interface
######################################

:scope: General Use
:Latest release: 1.0.0alpha4

Summary
=======

The modules in this repo implement an ADAT transmitter and receiver in a
core each. Separate cores are required to collect and supply data.

Note, lib_adat was forked from https://github.com/xcore/sc_adat

Features
--------

* 48000 and 44100 ADAT receivers
* 48000 and 44100 ADAT transmitters
* Application for loopback testing on Simulator or HW

Software version and dependencies
---------------------------------

The CHANGELOG contains information about the current and previous versions.
For a list of direct dependencies, look for DEPENDENT_MODULES in lib_adat/module_build_info.

Known Issues
------------

* This software relies on the reference clock being 100 MHz, there is no out of the box version for non 100 Mhz reference clocks.

* ADAT Tx for 256x master clock (i.e. 48kHz from 12.288MHz master clock) not yet implemented  

Required software (dependencies)
================================

  * None

