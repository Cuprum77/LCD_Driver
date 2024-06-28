# EDID Data

This folder contains the EDID data for the display used in this project. Already generated binaries are included for tested displays in the [bin](bin/) folder.

## Table of contents
- [Replacing the EDID Data](#replacing-the-edid-data)
- [Timing Data](#timing-data)
- [Generating or Modifying EDID Data](#generating-or-modifying-edid-data)
- [Modeline to EDID](#modeline-to-edid)

## Replacing the EDID Data (Vivado Only)

To replace the EDID data, you need to identify all the files named "dgl_720p_cea.data" in the project. I am unsure if you only need to replace the one that Vivado copied into the project folder, or the one in the IP core as well. I simply replaced both.
These files are typically found in both the [fpga folder](../fpga/xilinx/xilinx.srcs/sources_1/ip/dvi2rgb_0/src/dgl_720p_cea.data) and the [IP core folder](../vivado-library/ip/dvi2rgb/src/dgl_720p_cea.data).

This however should be done manually, as the IP core is a submodule.

## Timing Data

The datasheets has a great minimum and maximum timing specification for the displays that I have tested, but sadly they are not suitable for real world use.
This is a limitation of most GPUs, as they are no longer made to work with small displays like these. This is where the [Free86 modeline generator](https://xtiming.sourceforge.net/cgi-bin/xtiming.pl) comes in. It can generate appropriate timings for the display given our resolution and refresh rate, making sure we are within the capabilities of a modern GPU! By padding the data with a larger blanking interval, it can be made to work with most GPUs that I have tested. (Which isn't that many to be honest)

## Generating or Modifying EDID Data

The binary file is generated using the [Deltacast EDID Editor](https://www.deltacast.tv/products/free-software/e-edid-editor). It is a "free" tool, but requires registration. This outputs a pure binary file, which in itself is not very useful. So I wrote a simple python script to convert it to the data file used by the Digilent IP powering the HDMI interface. 

There are two scripts in this folder for converting to a more readable format:
- [edid_to_data.py](edid_to_data.py) - Converts the binary EDID file to a data file.
- [modeline_to_edid.py](modeline_to_edid.py) - Converts a modeline to EDID data.

## Modeline to EDID

Using the 400x960 pixel display as an example, we can input its resolution into the Free86 modeline generator to get the following modeline:
```
Modeline "400x960@60" 36.48 400 432 568 600 960 979 989 1009
```

With some arithmetic we can convert this to the EDID data we need to fill into the EDID editor.

These values are not immediately obvious how they fit into the EDID format, luckily its rather easy to calculate these values!

### Automatically
If you're like me, you dont want to do this by hand.
This is why I included the following python script [modeline_to_edid.py](modeline_to_edid.py) which takes the entire modeline string from the Free86 website output as an argument.

Example usage:
```bash
python modeline_to_edid.py Modeline "400x960@60" 36.48 400 432 568 600 960 979 989 1009
```

### Manually
However, if you prefer to do this manually, here is how you can calculate the values:
```
Front Porch = Sync Start - Display
```

```
Back Porch = Total - Display
```

```
Sync Width = Sync End - Sync Start
```

```
Blanking = Front Porch + Sync Width + Back Porch
```

### Results
Both the manual and automatic approach should generate the following values, given the example input above:
```
Pixel Clock:      36.48 MHz

H. Active:       400
H. Blank:        200
H. Front Porch:   32
H. Sync Width:   136
H. Image Size:   600

V. Active:       960
V. Blank:         49
V. Front Porch:   19
V. Sync Width:    10
V. Image Size:  1009
```

You simply type these values into the corresponding input of the Detailed Timings / Display Descriptor section of the EDID editor and you're almost done!

Lastly, you need to make sure that the "Sync Signal Definition" is set to "Digital Seperate" and both the sync signals should be unchecked. This is to avoid any issues with the display not being able to sync up with the signal.

Your "Detailed Timings / Display Descriptor" section should now look like this:
![EDID Screen](edid.png)
