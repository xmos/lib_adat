
.. include:: ../../../README.rst

ADAT software
=============

ADAT is a protocol to transmit audio
data over either coaxial or optical cables. The data transmission rate is
determined by the transmitter, and the receiver has to recover the sample
rate. ADAT normally carries 8 channels.

Important characteristics of ADAT software are the following:

* The sample rate(s) supported. Typical values are 44.1 or 48. 96 and 192
  may be supported, but typically with only 4 or 2 channels.

* Transmit and Receive support. Some systems require only ADAT output, or
  only ADAT input. Others require both.

Note that ADAT of eight channels at 48 Khz is identical to two channels at
192 KHz - a single bit in the data stream differentiates it (but the bit
rates, transmit, and receive code are identical).

Transmit
--------

This module can transmit S/PDIF signals at the following rates
(assuming eight cores on a 400 MHz part)

+---------------------------+-------------------------------+------------------------+
| Functionality provided    | Resources required            | Status                 |
+----------+----------------+------------+---------+--------+                        |
| Channels | Sample Rate    | 1-bit port | Threads | Memory |                        |
+----------+----------------+------------+---------+--------+------------------------+
| 8        | up to 48 KHz   | 1-2        | 1+      | 3.6K   | Implemented and tested |
+----------+----------------+------------+---------+--------+------------------------+
| 8        | up to 48 KHz   | 1-2        | 1       | 3.5K   | Implemented and tested |
+----------+----------------+------------+---------+--------+------------------------+

It requires a single core to run the transmit code. The number of 1-bit
ports depends on whether the master clock is already available on a one-bit
port. If available, then only a single 1-bit port is required to output
ADAT. If not, then two ports are required, one for the signal output, and
one for the master-clock input.

An external flip-flop is required to resynchronise the data signal to the
master-clock if more than 2 channels are used, or if the sample rate is
higher than 48 KHz. 

The precise transmission frequencies supported depend on the availability
of an external clock (eg, a PLL or a crystal oscillator) that runs at a
frequency of::

    512 * sampleRate

or a power-of-2 multiple. For example, for 48 Khz the
external clock has to run at a frequency of 24.576 MHz.
If both 44,1 and 48 Khz frequencies are to be supported, both a
24.587 MHz and a 22.579 MHz master clock are required. This is normally not
an issue since the same clocks can be used to drive the audio codecs.

Typical applications for this module include iPod docks, digital microphones,
digital mixing desks, USB audio, and AVB.

Receive
-------

This module can receive ADAT signals at the following rates (assuming 8 threads on a 400 MHz part)

+---------------------------+-------------------------+------------------------+
| Functionality provided    | Resources required      | Status                 |
+----------+----------------+------------+------------+                        |
| Channels | Sample Rate    | 1-bit port | Memory     |                        |
+----------+----------------+------------+------------+------------------------+
| 8        | up to 48 KHz   | 1          | 1.5-3.5 KB | Implemented and tested |
+----------+----------------+------------+------------+------------------------+

A single 50-MIPS core is required. The receiver does not require any
external clock, but can only recover 44.1 and 48 KHz sample rates. The
amount of memory depends on whether both 44.1 and 48 KHz are to be
supported, or just a single frequency.

Typical applications for this module include digital speakers,
digital mixing desks, USB audio, and AVB.


ADAT Receive
============

The ADAT receive module comprises a single thread that parses data as it
arrives on a one-bit port and that outputs words of data onto a streaming
channel end. Each word of data carries 24 bits of sample data and 4 bits of
channel information.

This modules depends on the reference clock being exactly 100 Mhz.

THe module has two functions, one that receives adat at 48 KHz, and one
that receives ADAT at 44.1 KHz. If the frequency of the input signal is
known a priori, the call that function in a non terminating ``while(1)``
loop. If the frequency could be either, then call the two functions in
succession from a ``while(1)`` loop.

Note that the two functions use a normal chanend, but assume that data is
read as if it was a streaming channel end. This is historic, and the
interface should be changed to use a streaming chanend. This will require
any application using this function to be changed (no change is required in
the module itself).

API
---

Compile time defines
~~~~~~~~~~~~~~~~~~~~

*ADAT_REF*
  Define this to 100 to state that the reference clock is exactly
  100 MHz (for example when using a 20 or 25 MHz crystal), or 999375
  to state that the reference clock is 99.9375 MHz (the
  result of using a 13 MHz crystal on an L1 or L2). Other values are at
  present not supported.

Functions
~~~~~~~~~

.. doxygenfunction:: adatReceiver48000

.. doxygenfunction:: adatReceiver44100


Example
-------

An example program is shown below. The input port needs to be declared as a
buffered port:

.. literalinclude:: app_adat_rx_example/src/main.xc
  :start-after: //::declaration
  :end-before: //::

The receive function should be called from a ``while(1)`` loop. The second
call in the while loop is optional, and only required if 44,100 Hz data
should be received:

.. literalinclude:: app_adat_rx_example/src/main.xc
  :start-after: //::parser
  :end-before: //::

The data handler should inspect received data samples and synchronise with
the beginning of each frame. In this case, we expect every 9th value to be
marked with a '1' nibble to indicate end-of-frame.

.. literalinclude:: app_adat_rx_example/src/main.xc
  :start-after: //::data handler
  :end-before: //::

The main program simply forks the data handling thread and the receiver in
parallel in two threads:

.. literalinclude:: app_adat_rx_example/src/main.xc
  :start-after: //::main program
  :end-before: //::

ADAT Transmit
=============

There are two modules that can produce an ADAT signal. The simplest module
is a single thread that inputs samples over a channel and that outputs data
on a 1-bit port. A more complex module has a thread that inputs samples
over a channel and that produces an ADAT signal onto a second channel.
Another thread has to copy this data from the channel onto a port. The
latter is useful if the ADAT output port is, for example, on a different
core. See the examples section on how to use this.

An identical protocol is used by both modules for inputting sample values
to be transmitted over ADAT. The first word transmitted over the
chanend should be the multiplier of the master clock (either 1024 or 512),
the second word should be the SMUX setting (either 0 or 2), then there should be N
x 8 words of sample values, terminated by an ``XS1_CT_END`` control token. If no
control token is sent, the transmission process will not terminate, and an
infinite stream of ADAT data can be sent.

The multiplier is the ratio between the master clock and the bit-rate; 1024
refers to a 49.152 Mhz masterclock, 512 assumes a 24.576 MHz master clock.

The output of the ADAT transmit thread has to be synchronised with an
external flip-flop. In order to make sure that the flip-flop captures the
signal on the right edge, the output port should be set up as follows::

  set_clock_src(mck_blk, mck);        // Connect Master Clock Block to mclk pin
  set_port_clock(adat_port, mck_blk); // Set ADAT_tx to be clocked from mck_blk
  set_clock_fall_delay(mck_blk, 7);   // Delay falling edge of mck_blk
  start_clock(mck_blk);               // Start mck_blk


API
---

.. doxygenfunction:: adat_tx

.. doxygenfunction:: adat_tx_port


Example
-------

Below we show two example programs: a program that uses the direct
interface, and a program that uses an intermediate thread to output to the
port.


Example of direct port code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The output port needs to be declared as a
buffered port, and the master clock input must be declared as an unbuffered
input port. A clock block is also required:

.. literalinclude:: app_adat_tx_direct_example/src/main.xc
  :start-after: //::declaration
  :end-before: //::

The ports need to be setup so that the output port is clocked of the master
clock with a suitable delay (to enable the external flop to latch the
signal). Do not forget to start the clock block, otherwise nothing shall happen:

.. literalinclude:: app_adat_tx_direct_example/src/main.xc
  :start-after: //::setup
  :end-before: //::

The data generator should first transmit the clock multiplier and the SMUX
flags, prior to transmitting data. To terminate, send an END token:

.. literalinclude:: app_adat_tx_direct_example/src/main.xc
  :start-after: //::generate
  :end-before: //::

The main program simply forks the data generating thread and the transmitter in
parallel in two threads. Prior to starting the transmitter, the clocks
should be set up:

.. literalinclude:: app_adat_tx_direct_example/src/main.xc
  :start-after: //::main
  :end-before: //::



Example of ADAT with an extra thread
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The output port needs to be declared as a
buffered port, and the master clock input must be declared as an unbuffered
input port. A clock block is also required:

.. literalinclude:: app_adat_tx_example/src/main.xc
  :start-after: //::declaration
  :end-before: //::

The ports need to be setup so that the output port is clocked of the master
clock with a suitable delay (to enable the external flop to latch the
signal). Do not forget to start the clock block, otherwise nothing shall happen:

.. literalinclude:: app_adat_tx_example/src/main.xc
  :start-after: //::setup
  :end-before: //::

The thread that drives the port should input words from the channel, and
output them with *reversed byte order*. Note that this activity of INPUT,
BYTEREV and OUTPUT takes only three instructions and can often be merged
with other threads; for example if there is an I2S thread that delivers
data syncrhonised to the same master clock, then that thread can
simultaneously drive the ADAT and I2S ports:

.. literalinclude:: app_adat_tx_example/src/main.xc
  :start-after: //::drive
  :end-before: //::

The data generator should first transmit the clock multiplier and the SMUX
flags, prior to transmitting data. To terminate, send an END token:

.. literalinclude:: app_adat_tx_example/src/main.xc
  :start-after: //::generate
  :end-before: //::

The main program simply forks the data generating thread and the transmitter in
parallel in two threads. Prior to starting the transmitter, the clocks
should be set up:

.. literalinclude:: app_adat_tx_example/src/main.xc
  :start-after: //::main
  :end-before: //::

|newpage|

|appendix|

.. include:: ../../../CHANGELOG.rst




