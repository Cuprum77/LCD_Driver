# LCD Driver Project

This repo is a work in progress, and the files are subject to change without notice.

## Project description
This project aims to create a driver board for the new 40 pin LCDs from China that are based on the ST7701S driver IC. This board will be designed to be used with common SBCs like the Raspberry Pi, and should be driverless on all major operating systems as well as plug'n'play.

The writeup will be available on my website once the project is finished.

## Project layout
- [UVVM_Light](https://github.com/UVVM/UVVM_Light) - The UVVM framework
- [edid](edid/) - EDID files for the LCDs
- [fpga](fpga/) - The FPGA project files for specific boards
- [hardware](hardware/) - The KiCad project files for the driver boards
- [resources](resources/) - Resources for the project, such as datasheets
- [rom](rom/) - The ROM files for the FPGA projects
- [sim](sim/) - The UVVM testbenches for the driver boards
- [software](software/) - The software for the driver boards
- [vivado-library](https://github.com/Digilent/vivado-library/) - The Vivado library files for the driver boards

## License
This project is licensed under CERN Open Hardware License Version 2 - Strong Reciprocity (CERN-OHL-S-2.0). See [LICENSE](LICENSE) for more details.