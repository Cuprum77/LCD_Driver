# DEPRECIATED

No longer used in the project. Remains for future reference.

# RGB Interface
The RGB interface contains the logic to convert a 24-bit RGB signal into what the display expects, with the correct timings.

## Table of contents

- [RGB](#rgb)
    - [Port map](#port-map)
- [RGB Clock](#rgb-clock)
    - [Generic parameters](#generic-parameters)
    - [Port map](#port-map-1)
- [Testbench](#testbench)

## RGB
This module is the main header file that handles top level functionalities as well as moving the R G B values to the correct locations in the output vector.

### Port map

| Port name | Direction | Size (bits) | Behavior | Description |
|-----------|-----------|------|----------|-------------|
| clk       | in        | 1 | Active HIGH | Global clock |
| reset     | in        | 1 | Active HIGH | Global reset |
| enable    | in        | 1 | Active HIGH | Enable signal |
| r | in | 8 | | Red value |
| g | in | 8 | | Green value |
| b | in | 8 | | Blue value |
| x | out | 12 | | X value |
| y | out | 12 | | Y value |
|rgb_pclk | out | 1 | | RGB pixel clock |
| rgb_de | out | 1 | | RGB data enable |
| rgb_vs | out | 1 | | RGB vertical sync |
| rgb_hs | out | 1 | | RGB horizontal sync |
| rgb_data | out | 24 | | RGB data |

## RGB Clock
This is a submodule of the RGB module that handles the clocking of the RGB interface. This module is responsible for making sure the HS and VS signals are generated at the correct times.

### Generic parameters

| Name | Type | Default | Description |
|------|------|---------|-------------|
| h_area | integer | 400 | Horizontal area |
| h_front_porch | integer | 2 | Horizontal front porch |
| h_sync | integer | 2 | Horizontal sync |
| h_back_porch | integer | 2 | Horizontal back porch |
| v_area | integer | 960 | Vertical area |
| v_front_porch | integer | 2 | Vertical front porch |
| v_sync | integer | 2 | Vertical sync |
| v_back_porch | integer | 2 | Vertical back porch |

### Port map

| Port name | Direction | Size (bits) | Behavior | Description |
|-----------|-----------|------|----------|-------------|
| clk       | in        | 1 | Active HIGH | Global clock |
| reset     | in        | 1 | Active HIGH | Global reset |
| rgb_pclk  | out       | 1 | | RGB pixel clock |
| rgb_de    | out       | 1 | | RGB data enable |
| rgb_vs    | out       | 1 | | RGB vertical sync |
| rgb_hs    | out       | 1 | | RGB horizontal sync |
| rgb_hcnt  | out       | 12 | | Horizontal counter |
| rgb_vcnt  | out       | 12 | | Vertical counter |

## Testbench
The testbench for the sequencer can be found in the [rgb.vht](testbench/rgb.vht) file.