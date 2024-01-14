# Simulation of the SPI interface

This is the files for the SPI simulation. The simulation is done using ModelSim and the [UVVM](https://github.com/UVVM/UVVM_Light) framework.

## Simulation

The goal of this simulation is to verify the functionality of the SPI interface and that it outputs the correct data when it should.
Timing and the order of data being sent is important here for the display to work correctly. If the order appears to be wrong, we can either rectify it in this module, or later in the sequencer itself.

Note, the module is somewhat limited by design. It will not prevent the user from changing the input during transmission, and it will not ignore them either. This means that if the user changes the `data` input during transmission, the module will send the new data instead of the old. This is something to keep in mind when using the module, which is also why the `DONE` signal is important.

## Simulation Setup

To verify the functionality of the SPI interface, we will attempt to simulate a simple write to a SPI based LCD such as the ST7789V. The testbench will send pixel data. The following steps need to be taken:

- Set the display cursor to 0,0
- Tell the display to expect pixel data
- Send 10 pixels worth of data

This should require us to first send 5 bytes of data to set the cursor, then a single byte to enable pixel data, ending with 10 words of pixel data. With a word in this case being 16 bits. Some displays do allow more bits per pixel, but thats not important for now.

This is simply the higher level functionality we want to test. The SPI interface itself has a few more things to test. The following is a list of things we want to test:
- [Case 1](#case-1): Reset behaves as expected
- [Case 2](#case-2): `SEND` is ignored during reset and transmission
- [Case 3](#case-3): The `DONE` line is set correctly
- [Case 4](#case-4): Bit order can be changed
- [Case 5](#case-5): The higher level goal is achieved

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

### Case 5

This test will essentially implement the high level functional test as described in [Simulation Setup](#simulation-setup).

## Results

The results can be viewed in the [log file](SPI_log.txt).
If there were any problems, they will show in the [alert file](_Alert.txt). This file will be empty if there were no problems.
