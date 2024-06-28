#! /usr/bin/env python3

import sys


class ModelineObject:
    modeline_str    = ""
    resolution      = ""
    refresh_rate    = 0.0
    h_active        = 0
    h_porch         = 0
    h_sync          = 0
    h_total         = 0
    v_active        = 0
    v_porch         = 0
    v_sync          = 0
    v_total         = 0    

    def ArgToModeline(self, args : list):
        self.modeline_str = args[0]
        self.resolution = args[1]
        self.refresh_rate = float(args[2])
        self.h_active = int(args[3])
        self.h_porch = int(args[4])
        self.h_sync = int(args[5])
        self.h_total = int(args[6])
        self.v_active = int(args[7])
        self.v_porch = int(args[8])
        self.v_sync = int(args[9])
        self.v_total = int(args[10])


class EDIDObject:
    pxclk           = 0.0
    h_active        = 0
    h_blank         = 0
    h_front_porch   = 0
    h_back_porch    = 0
    h_sync_width    = 0
    h_image_size    = 0
    h_border        = 0
    v_active        = 0
    v_blank         = 0
    v_front_porch   = 0
    v_back_porch    = 0
    v_sync_width    = 0
    v_image_size    = 0
    v_border        = 0

    def ModelineToEDID(self, modeline : ModelineObject):
        self.pxclk = modeline.refresh_rate
        self.h_active = modeline.h_active
        self.h_front_porch = modeline.h_porch - modeline.h_active
        self.h_back_porch = modeline.h_total - modeline.h_sync
        self.h_sync_width = modeline.h_sync - modeline.h_porch
        self.h_blank = self.h_front_porch + self.h_back_porch + self.h_sync_width
        self.h_image_size = modeline.h_total
        self.h_border = 0
        self.v_active = modeline.v_active
        self.v_front_porch = modeline.v_porch - modeline.v_active
        self.back_porch = modeline.v_total - modeline.v_sync
        self.v_sync_width = modeline.v_sync - modeline.v_porch
        self.v_blank = self.h_front_porch + self.v_back_porch + self.v_sync_width
        self.v_image_size = modeline.v_total
        self.v_border = 0


def main():
    # Get every argument after the script name
    args = sys.argv[1:]
    # If there are no arguments, print the usage
    if not args:
        print("Usage: modeline_to_edid.py [modeline]")
        sys.exit(1)
    # Check if there are 11 arguments
    if len(args) != 11:
        print("Error: 11 arguments required")
        sys.exit(1)

    # Create a modeline object
    modeline = ModelineObject()
    # Convert the arguments to a modeline object
    modeline.ArgToModeline(args)

    # Convert to the correct format
    edid = EDIDObject()    
    edid.ModelineToEDID(modeline)

    # Print the EDID object
    print(f"""
Pixel Clock:    {edid.pxclk}

H. Active:      {edid.h_active}
H. Blank:       {edid.h_blank}
H. Front Porch: {edid.h_front_porch}
H. Sync Width:  {edid.h_sync_width}
H. Image Size:  {edid.h_image_size}
          
V. Active:      {edid.v_active}
V. Blank:       {edid.v_blank}
V. Front Porch: {edid.v_front_porch}
V. Sync Width:  {edid.v_sync_width}
V. Image Size:  {edid.v_image_size}
""")   


if __name__ == "__main__":
    main()