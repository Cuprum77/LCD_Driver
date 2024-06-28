#! /usr/bin/env python3

import sys


# Get the argument filepath
filepath = sys.argv[1]

# If there are no arguments, print the usage
if len(sys.argv) == 1:
    print("Usage: python3 edid_to_vivado.py <edid.bin>")
    sys.exit()

# Open the edid file as a binary file
with open(filepath, "rb") as f:
    edid = f.read()
    # Convert to a list of binary strings
    edid = [bin(byte)[2:].zfill(8) for byte in edid]
    # Print the list of binary strings
    print(edid)
    # save it to a file
    with open("edid.data", "w") as f:
        f.write("\n".join(edid))
