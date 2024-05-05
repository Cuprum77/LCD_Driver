# Breakout Board
Note, this is not a complete project. It lacks the necessary files to properly modify the design. This is purely out of the fact that this is a prototype and I am too lazy to properly document it.

![Breakout design](img/driver_breakout.png)

This repo contains the KiCAD files for the first itteration of this project, the breakout board.

## Images

![top](https://Cuprum77.github.io/LCD_Driver/top.png)
![bottom](https://Cuprum77.github.io/LCD_Driver/bottom.png)

## Known Issues

These are the known issues with the current design:
- No pull-up resistors on the I2C lines
- No reset button
- No ability to power the board from the USB port (for the microcontroller)
- Difficult to add external power to the board
- More ground connections!
- Boost Converter is not capable of providing enough current for the display. Does not match the chips rated output.

## 3D Files

In the [3D](./3d/) folder you can find the 3D models for the board and a stand for the display to rest on.
The [stand](./3d/stand.stl) is a very crude design. It may not be very printable, but it works well enough for a prototype. 

This will not be developed further as there will not be a need for it in the final design.