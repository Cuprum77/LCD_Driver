# LCD Driver Project

This repo is a work in progress, and the files are subject to change without notice.

## Project description
This project aims to create a driver board for the new 40 pin LCDs from China that are based on the ST7701S driver IC. This board will be designed to be used with common SBCs like the Raspberry Pi, and should be driverless on all major operating systems as well as plug'n'play.

The writeup will be available on my website once the project is finished.

## Project layout
- [Breakout_1](Breakout_1) - KiCAD files for the breakout board
- [Initializer](Initializer) - The VHDL code for the SPI initialization
- [RGB_Driver](RGB_Driver) - The VHDL code for the RGB driver
- [RP2040 Firmware](RP2040%20Firmware) - The firmware for the RP2040 microcontroller handling the touch input
- [Simulations](Simulations) - The files for the simulations of the project
- [UVVM_Light](https://github.com/UVVM/UVVM_Light) - The UVVM framework

## License
This project is licensed under CERN Open Hardware License Version 2 - Strong Reciprocity (CERN-OHL-S-2.0). See [LICENSE](LICENSE) for more details.