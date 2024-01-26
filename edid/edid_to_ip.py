# Open the edid file as a binary file
with open("edid.bin", "rb") as f:
    edid = f.read()
    # Convert to a list of binary strings
    edid = [bin(byte)[2:].zfill(8) for byte in edid]
    # Print the list of binary strings
    print(edid)
    # save it to a file
    with open("edid.data", "w") as f:
        f.write("\n".join(edid))
