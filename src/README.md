# FPGA Source Files

This directory contains the FPGA source files for each specific FPGA board.
Each variant has its own subdirectory and the files may differ between the variants.

## ISE specifics

The ISE source files are located in the `ise` subdirectory, these contain the following file from [tmatsuya](https://github.com/tmatsuya)'s [repository](https://github.com/tmatsuya/i2c_edid): `i2c_edid.v`. Their respective license must be followed.

The folder `ise` also requires the user to request the `xapp460.zip` file from Xilinx, as it contains the DVI decoder used in this project. This is not possible to include in this repository as source code due to licensing restrictions.
It can be requested from their [application note](https://docs.amd.com/v/u/en-US/xapp460) near the end of the document.