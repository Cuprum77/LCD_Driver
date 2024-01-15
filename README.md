# LCD Driver Project

This repo is a work in progress, and the files are subject to change without notice.

## Project description
This project aims to create a driver board for the new 40 pin LCDs from China that are based on the ST7701S driver IC. This board will be designed to be used with common SBCs like the Raspberry Pi, and should be driverless on all major operating systems as well as plug'n'play.

The writeup will be available on my website once the project is finished.

## Project layout
- [display_interface](display_interface/) - The VHDL code for the RGB interface
- [fpga](fpga/) - The bitstream for the FPGA
- [hardware](hardware/) - KiCAD files for the breakout board
- [initializer](initializer/) - The VHDL code for the SPI initialization
- [simulations](simulations/) - The files for the simulations of the project
- [top_level](top_level/) - The top level VHDL file
- [touch_controller_firmware](touch_controller_firmware/) - The firmware for the RP2040 microcontroller handling the touch input
- [UVVM_Light](https://github.com/UVVM/UVVM_Light) - The UVVM framework

## License
This project is licensed under CERN Open Hardware License Version 2 - Strong Reciprocity (CERN-OHL-S-2.0). See [LICENSE](LICENSE) for more details.