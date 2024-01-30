# Firmware

The firmware, written in C/C++, is designed to operate on the RP2040 microcontroller. Its primary function is to read data from the capacitive touch sensor and transmit it to the host computer over USB.

The challenge lies in dealing with the capacitive touch sensor, an unidentified device. Fortunately, the touch controller on the display's flat flex cable retains its markings, making identification possible. The touch controller in use is the GT911 from Goodix, utilizing the I2C protocol.

## Chip Identification
![Chip](resources/chip.jpg)
Above is a close-up image of the GT911 chip on the flat flex cable of this specific display.

## Resources
- [Datasheet](../resources/GT911_v.09.pdf): Provides a brief overview of the chip's features and specifications.
- [Programming Guide](../resources/GT911%20Programming%20Guide_v0.1.pdf): Contains the register map and programming instructions.