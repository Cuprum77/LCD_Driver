# open the edid.bin file and convert it to readable hex format
with open('edid.bin', 'rb') as f:
    content = f.read()

    hex_content = []
    bin_content = []

    for i in range(len(content)):
        # convert to binary
        binary = bin(content[i])
        # remove 0b
        binary = str(binary).replace('0b', '')
        # if less than 8, pad with 0s
        if len(binary) < 8:
            binary = '0' * (8 - len(binary)) + binary
        # append newline
        binary += '\n'

        # convert to hex
        hexadecimal = hex(content[i])
        # remove 0x
        hexadecimal = str(hexadecimal).replace('0x', '')
        # pad if length is 1
        if len(hexadecimal) == 1:
            hexadecimal = '0' + hexadecimal

        # add x" " to each byte
        hexadecimal = 'x\"' + hexadecimal + '\"'

        # add to list
        if i % 128 != 127:
            hexadecimal += ', '
        if i % 8 == 7 and i != len(content) - 1:
            hexadecimal += '\n'
        hex_content.append(hexadecimal)
        bin_content.append(binary)

    # print to new file edid.hex
    with open('edid.hex', 'w') as f:
        f.writelines(hex_content)

    with open('edid.data', 'w') as f:
        f.writelines(bin_content)
