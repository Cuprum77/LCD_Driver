# Top file
This file is the top level file for the project. It collects all the modules and connects them together.
There really isn't much to say about this file, other than that it is the top level file.

One note is that it needs to be modified to include the PLL IP for the FPGA you are using, unless you can supply 100MHz clock to the FPGA.

## Heart
The heart is a simple module that blinks the LEDs on the board. It is used to indicate that the FPGA is running and that the program is not stuck.

## Testbench
The testbench for the top file can be found in the [top.vht](testbench/top.vht) file.