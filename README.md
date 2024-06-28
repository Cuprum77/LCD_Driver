# LCD Driver Project

This repository contains my attempt at creating a "universal" driver board that fits most of the new 40 pin LCDs from China. These new LCDs all utilize a 40 pin flat flex cable, and utilize the ST7701 driver IC. 
This means that they are rather simple RGB devices, not too unlike the old VGA standard. 
The main goal however, is to have a board that does not require any system drivers, and utilize the standard connectors that are available on most SBCs, such as the Raspberry Pi, as well as most laptops and desktops.

## Table of contents
- [Supported LCDs](#supported-lcds)
- [Project layout](#project-layout)
- [License](#license)

## Supported LCDs

This table lists the LCDs that I have bought and tested with the driver board.

| Format | Size  | Resolution | Driver IC | Touch | Link      | Additional notes |
| ------ | ----- | ---------- | --------- | ----- | --------- | ---------------- |
| Bar    | 3.99" | 400x960    | ST7701    | Yes   | [AliExpress](https://www.aliexpress.com/item/1005005622337201.html) | |
| Square | 3.95" | 480x480    | ST7701    | Yes   | [AliExpress](https://www.aliexpress.com/item/1005005230886441.html) | NOT FULLY TESTED YET |

Alternatively, any other board that uses the ST7701 driver IC and with the following [pinout](./resources/PINOUT.md) should work with the driver board. However, you must generate a new ROM file for the FPGA.

## Project layout
- [UVVM_Light](https://github.com/UVVM/UVVM_Light) - The UVVM framework
- [bitfiles](bitfiles/) - FPGA bitfiles
- [edid](edid/) - EDID files for the LCDs
- [hardware](hardware/) - The KiCad project files for the driver boards
- [resources](resources/) - Resources for the project, such as datasheets
- [rom](rom/) - The ROM files for the FPGA projects
- [sim](sim/) - The UVVM testbenches for the driver boards
- [software](software/) - The software for the driver boards
- [vivado-library](https://github.com/Digilent/vivado-library/) - The Vivado library files for the driver boards

## License
This project is licensed under CERN Open Hardware License Version 2 - Strong Reciprocity (CERN-OHL-S-2.0). See [LICENSE](LICENSE) for more details.
Note that some files in this repository may be licensed under different licenses. Please check the respective files for more information.