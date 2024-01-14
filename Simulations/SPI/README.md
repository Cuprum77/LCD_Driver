# Simulation of the SPI interface

This is the files for the SPI simulation. The simulation is done using ModelSim and the [UVVM](https://github.com/UVVM/UVVM_Light) framework.

## Simulation

The goal of this simulation is to verify the functionality of the SPI interface and that it outputs the correct data when it should.
Timing and the order of data being sent is important here for the display to work correctly. If the order appears to be wrong, we can either rectify it in this module, or later in the sequencer itself.

Note, the module is somewhat limited by design. It will not prevent the user from changing the input during transmission, and it will not ignore them either. This means that if the user changes the `data` input during transmission, the module will send the new data instead of the old. This is something to keep in mind when using the module, which is also why the `DONE` signal is important.

## Simulation Setup

There are a few things that I want to test with this module, and they are as follows:
- [Case 1](#case-1): Reset behaves as expected
- [Case 2](#case-2): `SEND` is ignored during reset and transmission
- [Case 3](#case-3): The `DONE` line is set correctly
- [Case 4](#case-4): Bit order can be changed

If these all pass, including a manual verification that the timings are correct, then the module should be ready for use.

### Case 1

The data lines should be set to their respective values after a reset:

| Line     | Value |
| -------- | ----- |
| SPI_SDA  | 0     |
| SPI_SCL  | 0     |
| SPI_CS   | 1     |
| DONE     | 1     |

Even if the `SEND` line is set to HIGH during reset, the module should not send any data.

### Case 2

The `SEND` line should be ignored during a reset state.
This means that if we want to transmit anything, but we reset it at the same time, it should still reset.

This is done by simply sending a reset and send pulse at the same time.

### Case 3

We need to verify that the `DONE` signal is kept HIGH when its not transmitting, and set LOW when it is.
This is critical for telling any higher level function that we are busy and shouldn't be bothered.

We will do this test with 8 bits, and the signal 0xAA.

### Case 4

Replicate [Case 3](#case-3), but do so with all the bit orders possible. Signal should be 0xAAAAAAAA to make it easy to spot visually.
We also care about the bits being sent in this scenario.

This test will conduct one transmission for each bit width setting.

## Results

The results can be viewed in the [log file](SPI_log.txt).
If there were any problems, they will show in the [alert file](_Alert.txt). This file will be empty if there were no problems.
