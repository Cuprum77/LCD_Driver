# Sequencer
The sequencer is a state machine that takes in instructions from a generated ROM file and sends them to the SPI component. The implemented can be found in the file [sequencer.vhd](sequencer.vhd).

This will execute every instruction in the ROM file, and will stop if it encounters an error. This is to prevent the sequencer from sending out garbage data to the LCD display.

When the sequencer is done, it will enter an idle state and stay there until it is reset.

## Table of contents

- [Port map](#port-map-1)
- [Instruction Set](#instruction-set)
    - [cmd](#cmd)
    - [cmd_data](#cmd_data)
    - [size](#size)
    - [data](#data)
    - [data_cont](#data_cont)
    - [wait](#wait)
    - [Example](#example)
- [Error](#error)
- [Testbench](#testbench)

## Port map

| Port name | Direction | Size (bits) | Behavior | Description |
|-----------|-----------|------|----------|-------------|
| clk       | in        | 1 | Active HIGH | Global clock |
| reset     | in        | 1 | Active HIGH | Global reset |
| spi_sda   | out       | 1 | | SPI data |
| spi_scl   | out       | 1 | | SPI clock |
| spi_cs    | out       | 1 | | SPI chip select |
| spi_dc    | out       | 1 | | SPI data command |
| done      | out       | 1 | HIGH when done | Turns on when the module is done |
| sequence_error | out  | 1 | HIGH on error | Error signal |

## Instruction Set
The sequencer is used to send commands to the LCD display. To make it as versitile as possible, it uses a very simple instruction set.

An important thing to note is that the ROM is 32 bits wide, and loads two such words per cycle. This means that the first word is the instruction, and the second word is the payload.

| Instruction | Hex Code    | Description |
|-------------|-------------|-------------|
| cmd         | 0x10        | Send a command to the LCD display |
| size        | 0x20        | Set the size of the data |
| data        | 0x21        | Send data to the LCD display |
| wait        | 0x30        | Delay in milliseconds |

### cmd
The `cmd` instruction is used to send a command to the LCD display.
This behaves similarly to the `data` instruction, but it will also set the size to 8 bits automatically. Saves you a few instructions.

### size
The `size` instruction is used to set the number of bits to send over the SPI bus. This is useful for commands that require a different number of bits to be sent.

The number written here should match one the possible values for the `bit_width` variable as described in the [spi module](../spi/).
Failure to match the `bit_width` variable will result in the module throwing an error.

### data
The `data` instruction is used to send data to the LCD display.

Should always be preceded by a `size` instruction. If not, it will default to whatever was set before. Usually 8 bits if previous instruction was a `cmd` instruction.

### wait
The `wait` instruction is used to delay the sequencer for a given number of milliseconds.

The sequencer will convert the number of milliseconds to the number of clock cycles required to wait.

The maximum wait time is 1 000 ms.

### Example
The following example shows how to configure the cursor's x position on a ST7789V display;
```
cmd 0x2a
size 32
data 0x00 0x00 0xef 0x00
```
This psuedo code can be fed into the ROM generator to create a ROM.vhd file, found in [rom](../rom/).

## Error
If the sequence encounters an unexpected instruction, it will throw an error and stop the sequence. This is to prevent the sequencer from sending out garbage data to the LCD display.

To exit the error state, the system needs to be reset.

## Testbench
The testbench for the sequencer can be found in the [sequencer.vht](testbench/sequencer.vht) file.