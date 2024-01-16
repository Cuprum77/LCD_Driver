# Resetter

This module ensures that the display gets plenty of time to reset before we start sending data to it.

## Port map

| Port name | Direction | Size (bits) | Behavior | Description |
|-----------|-----------|------|----------|-------------|
| clk       | in        | 1 | Active HIGH | Global clock |
| rst     | in        | 1 | Active HIGH | Global reset |
| rst_n     | out       | 1 | Active LOW | Reset signal for the display |
| done      | out       | 1 | HIGH when done | Turns on when the module is done |

## Behavior

The resetter will set the reset signal to be HIGH for 10 ms, then LOW for 100 ms, then HIGH for 10 ms, and finally send a done signal.

## Testbench

The testbench is located in the [resetter.vht](testbench/resetter.vht) file.