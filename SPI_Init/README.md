# FPGA SPI Hardware

This repo contains the hardware implementation of the SPI protocol for the FPGA. The SPI protocol is used to communicate with the LCD display.

## Table of contents
  - [SPI](#spi)
    - [Port map](#port-map)
    - [Bit Width](#bit-width)
  - [Sequencer](#sequencer)
    - [Port map](#port-map-1)
    - [Instruction Set](#instruction-set)
        - [cmd](#cmd)
        - [cmd_data](#cmd_data)
        - [size](#size)
        - [data](#data)
        - [data_cont](#data_cont)
        - [delay](#delay)
        - [Example](#example)
    - [ROM](#rom)
    - [ROM Generator](#rom-generator)
    - [Error](#error)

## SPI
The SPI is a state machine that makes sure the bits are sent out in the correct order and at the correct time. The implemented can be found in the file [spi.vhd](/spi.vhd).

Unlike other SPI implementations, this is master only. Meaning that it can only transmit data and not receive it. This is because the LCD display doesn't need to send any data back to the FPGA.

### Port map
| Port name | Direction | Size (bits) | Behavior | Description |
|-----------|-----------|------|----------|-------------|
| clk       | in        | 1 | Active HIGH | Global clock |
| reset     | in        | 1 | Active HIGH | Global reset |
| spi_sda   | out       | 1 | | SPI data |
| spi_scl   | out       | 1 | | SPI clock |
| spi_cs    | out       | 1 | | SPI chip select |
| spi_dc    | out       | 1 | | SPI data command |
| send      | in        | 1 | Active HIGH | Start the transmission |
| set_dc    | in        | 1 | Active HIGH | Enables/Disables the SPI data command |
| done      | out       | 1 | LOW during transmission | Idle signal |
| data | in | 32 | MSB | Data to be sent over the bus |
| bit_width | in | 3 | | Number of bits to send over the bus |

### Bit Width
The `bit_width` variable is special, as it allows us to vary the number of bits being sent out over the SPI bus. This is very useful for some displays where the entire pixel should be sent at once, like the ST7789V displays. Thus it needs to be set to the correct setting for the number of bytes being sent:

| `bit_width` | Number of bits |
|-----------|---------|
| 0 | 8 bits |
| 1 | 16 bits |
| 2 | 18 bits |
| 3 | 24 bits |
| 4 | 32 bits |

The state machine will start at the `bit_width` setting, so if you select 8 bits, it will start at index 7 of your data and work its way down to 0.

Warning; you still need to provide the entire 32 bits to the component even if you don't need every bit. Simply pad out the remaining bits with whatever you want if you use less than 32 bits.

## Sequencer
The sequencer is a state machine that takes in instructions from a generated ROM file and sends them to the SPI component. The implemented can be found in the file [sequencer.vhd](/sequencer.vhd).

This will execute every instruction in the ROM file, and will stop if it encounters an error. This is to prevent the sequencer from sending out garbage data to the LCD display.

When the sequencer is done, it will enter an idle state and stay there until it is reset.

### Port map

| Port name | Direction | Size (bits) | Behavior | Description |
|-----------|-----------|------|----------|-------------|
| clk       | in        | 1 | Active HIGH | Global clock |
| reset     | in        | 1 | Active HIGH | Global reset |
| spi_sda   | out       | 1 | | SPI data |
| spi_scl   | out       | 1 | | SPI clock |
| spi_cs    | out       | 1 | | SPI chip select |
| spi_dc    | out       | 1 | | SPI data command |
| sequence_error | out  | 1 | HIGH on error | Error signal |

### Instruction Set
The sequencer is used to send commands to the LCD display. To make it as versitile as possible, it uses a very simple instruction set.

An important thing to note is that the ROM is 32 bits wide, and loads two such words per cycle. This means that the first word is the instruction, and the second word is the payload.

| Instruction | Hex Code    | Description |
|-------------|-------------|-------------|
| start       | 0x01        | Start a sequence |
| stop        | 0x02        | Stop a sequence |
| cmd         | 0x10        | Send a command to the LCD display |
| size        | 0x20        | Set the size of the data |
| data        | 0x21        | Send data to the LCD display |
| delay       | 0x30        | Delay in milliseconds |

#### start
The `start` instruction is used to start a sequence. This will set up the sequencer properly so the commands are sent correctly.

#### stop
The `stop` instruction is used to stop a sequence. This will reset the sequencer to its initial state.

#### cmd
The `cmd` instruction is used to send a command to the LCD display.
This behaves similarly to the `data` instruction, but it will also set the size to 8 bits automatically. Saves you a few instructions.

#### size
The `size` instruction is used to set the number of bits to send over the SPI bus. This is useful for commands that require a different number of bits to be sent.

The number written here should match one the possible values for the `bit_width` variable as described in [Bit Width](#bit-width).
Failure to match the `bit_width` variable will result in the module throwing an error.

#### data
The `data` instruction is used to send data to the LCD display.

Should always be preceded by a `size` instruction. If not, it will default to whatever was set before. Usually 8 bits if previous instruction was a `cmd` instruction.

#### delay
The `delay` instruction is used to delay the sequencer for a given number of milliseconds.

The sequencer will convert the number of milliseconds to the number of clock cycles required to wait.

The maximum wait time is 1 000 ms.

#### Example
The following example shows how to configure the cursor's x position on a ST7789V display;
```
start
cmd 0x2a
size 32
data 0xef000000
stop
```
This psuedo code can be fed into the ROM generator to create a ROM.vhd file, found at [ROM Generator](#rom-generator).

### ROM
The ROM is a generated file that contains the instructions for the sequencer. It is a VHDL file that contains a constant array thats 32 bits wide and as long as the number of instructions in the ROM minus the number of comments.

This should be generated using the [ROM Generator](#rom-generator).

### ROM Generator
The ROM generator is a python script that takes in a text file containing the instructions for the Sequencer and outputs a VHDL file containing the ROM needed for the Sequencer to synthesize.

The script can be found at [rom_generator.py](/rom_generator.py).

The script expects a text file containing the instructions for the sequencer. Each instruction should be on its own line, and the instruction and its payload should be separated by a space.

The script will attempt to put in a start and stop instruction at the beginning and end of the file respectively.

### Error
If the sequence encounters an unexpected instruction, it will throw an error and stop the sequence. This is to prevent the sequencer from sending out garbage data to the LCD display.

To exit the error state, the system needs to be reset.