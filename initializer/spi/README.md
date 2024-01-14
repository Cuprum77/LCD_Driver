# SPI
The SPI is a state machine that makes sure the bits are sent out in the correct order and at the correct time. The implemented can be found in the file [spi.vhd](spi.vhd).

Unlike other SPI implementations, this is master only. Meaning that it can only transmit data and not receive it. This is because the LCD display doesn't need to send any data back to the FPGA.

## Port map
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

## Bit Width
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

## Testbench
The testbench for the sequencer can be found in the [spi.vht](testbench/spi.vht) file.