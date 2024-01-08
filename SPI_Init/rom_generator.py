instruction_psuedo = [
    "cmd",
    "size",
    "data",
    "wait"
]

instruction_hex = [
    0x00000010,
    0x00000020,
    0x00000021,
    0x00000030
]

word_sizes = [
    8,
    16,
    18,
    24,
    32
]

# Function that loads the psuedo-assembly code from the instructions.txt file
def load_rom():
    # Check if the file exists
    try:
        # Load the ROM psuedo-assembly code into a list
        with open('instructions.txt') as f:
            rom = f.readlines()
    except IOError:
        # Print the error in the console
        print("ERROR: FILE \"instructions.txt\" DOES NOT EXIST!")
        print("Generating a new file...")
        # Create a new file
        with open('instructions.txt', 'w') as f:
            f.write("; Check out the README.md for the instruction set")
        # Exit the program
        exit()

    return rom


# Throw an error if the instruction is not valid
def error(line):
    print("ERROR: UNKNOWN INSTRUCTION \"" + str(line) + "\"!")
    exit()


# Function that checks the length of the instruction
def check_instruction_length(instruction_list, assembly, line):
    # Get length of the instruction
    payload_size = len(instruction_list)
    # If the instruction is start or stop, do not add any more data
    if instruction_list[0] == "start" or instruction_list[0] == "stop":
        payload_size = 0
    else:
        # If theres only 1 item in the instruction_list, then theres too little data
        if payload_size <= 1:
            # Someone forgot to add data to the instruction
            error(line)
        # If theres more than 2 items in the instruction_list, then there might be a comment
        else:
            # Subtract 1 from the payload size
            payload_size -= 1
            # Check if any of the items in the instruction_list are a comment
            for idx in range(len(instruction_list)):
                # Get the item
                item = instruction_list[idx]
                # Check if its a comment
                if item.startswith(";"):
                    # Remove the comment
                    instruction_list.remove(item)
                    # Decrement the payload size
                    payload_size -= 1
                    # Break out of the loop
                    break

    return payload_size


# Get the payload from the line
def fetch_payload(line):
    # Check if it starts with a hex value
    if line.startswith("0x"):
        # Remove the 0x
        line = line[2:]
        # Convert it to an integer
        payload = int(line, 16)
    # If it starts with a binary value
    elif line.startswith("0b"):
        # Remove the 0b
        line = line[2:]
        # Convert it to an integer
        payload = int(line, 2)
    else:
        # Convert it to an integer
        payload = int(line)

    return payload


# Function that optimizes the psuedo-assembly code
def optimize_content(assembly):
    cleaned_content = []
    comment_counter = 0
    actual_first_line = 0

    # Remove all comments from the psuedo-assembly code
    for idx in range(len(assembly)):
        # Get the line
        line = assembly[idx]

        # Check if the line starts with a comment
        if line.startswith(";"):
            # If the first line is a comment, set the actual first line
            if actual_first_line == 0:
                actual_first_line += 1

            # Remove any newline characters
            line = line.replace("\n", "")
            # Keep this comment
            cleaned_content.append(line)
            comment_counter += 1
            continue
        # If the line is empty, continue
        elif line == "\n":
            continue
        else:
            # Check if the line has a comment
            if ";" in line:
                # Remove the comment
                line = line.split(";")[0]
        
            # Add the line to the cleaned content
            cleaned_content.append(line)

    rom_content = []
    current_word_size = 8

    # Go through each line of the psuedo-assembly code
    for idx in range(len(cleaned_content)):
        # Get the line
        line = cleaned_content[idx]
        # Check if the line starts with a word in the instructions list
        temp = line.split()

        # Check if its a comment
        if line.startswith(";"):
            rom_content.append(line)
        # Make sure it exists
        elif temp[0] in instruction_psuedo:
            # Make sure its a valid length
            instruction_length = check_instruction_length(temp, cleaned_content, line)

            # If its a size instruction, change the word size
            if temp[0] == "size":
                # Fetch the payload
                payload = fetch_payload(temp[1])
                # Check if the size is valid
                if payload in word_sizes:
                    # Set the word size
                    current_word_size = payload
                else:
                    # The size is not valid
                    error(line)
            # but if its a command instruction, set the word size to 8
            elif temp[0] == "cmd":
                current_word_size = 8

            # Get the instruction hex
            instruction = temp[0]
            # Remove the instruction from the list
            temp.pop(0)

            # If the length is 0, have a payload of 0
            if instruction_length == 0:
                # Add the instruction hex and payload to the rom content
                rom_content.append(instruction)
                rom_content.append(format(0, '08x'))

            # If the length is greater than 1, and the instruction is a data instruction
            elif instruction_length > 1 and instruction == "data":
                # The instruction length decides the number of words to send
                # Get the max value of the word size
                max_value = 2 ** current_word_size

                # Start at the last index of the instruction list and work backwards
                overflow = 0
                for i in range(instruction_length):
                    # Get the payload
                    payload = fetch_payload(temp[i]) + overflow
                    print(payload)
                    overflow = 0
                    
                    # Check if its less than the max value
                    if payload <= max_value:
                        # Add the instruction hex and payload to the rom content
                        rom_content.append(instruction)
                        rom_content.append(format(payload, '08x'))
                    else:
                        # The payload is too large, we must split it up and append it infront of the current instruction
                        overflow = max_value
                        # Add the instruction hex and payload to the rom content
                        rom_content.append(instruction)
                        rom_content.append(format(payload - max_value, '08x'))

            # If the length is at or greater than 1, just add the payload at index 1
            else:
                payload = fetch_payload(temp[0])

                # Add the instruction hex and payload to the rom content
                rom_content.append(instruction)
                rom_content.append(format(payload, '08x'))

        else:
            # The instruction is not valid
            error(line)

    # Do a sanity check to make sure the rom content is less or equal to 255
    if len(rom_content) > (255 + comment_counter):
        print("ERROR: ROM content is greater than 255 bytes!")
        exit()

    # Write the optimized psuedo-assembly code to the file
    with open('instructions_optimized.txt', 'w') as f:
        idx = 0
        rom_file = ""

        # Loop through each line of the rom content
        while True:
            # Copy the content into a variable
            content = rom_content[idx]
            # Check if the line is a comment
            if content.startswith(";"):
                # Add the comment to the ROM file
                rom_file += content + "\n"
                # Increment the index
                idx += 1
            else:
                formatted_line = rom_content[idx] + " "
                formatted_line += "0x" + rom_content[idx + 1] + "\n"
                rom_file += formatted_line
                # Increment the index
                idx += 2

            # Check if we are at the end of the rom content
            if idx >= len(rom_content):
                break

        f.write(rom_file)

    return rom_content


# Function that parses the psuedo-assembly code and generates the ROM file
def parse_content(assembly):
    rom_content = []

    # Go through each line of the psuedo-assembly code
    idx = 0
    while True:
        # Check if its a comment
        if assembly[idx].startswith(";"):
            # Add the comment to the rom content
            rom_content.append(assembly[idx])
            idx += 1
            continue

        # Get the instruction and payload
        instruction = assembly[idx]
        payload = assembly[idx + 1]
        idx += 2
        
        # Get the instruction hex index
        instruction_index = instruction_psuedo.index(instruction)
        # Get the actual hex code
        instruction_hex_code = instruction_hex[instruction_index]
        # Convert it to a hex string thats 32 bits long
        instruction_hex_code = format(instruction_hex_code, '08x')

        # Add the instruction hex and payload to the rom content
        rom_content.append(instruction_hex_code)
        rom_content.append(payload)

        # Check if we are at the end of the psuedo-assembly code
        if idx >= len(assembly):
            break

    # Do a sanity check to make sure the rom content is less or equal to 255
    if len(rom_content) > 255:
        print("ERROR: ROM content is greater than 255 bytes!")
        exit()

    return rom_content


# Function that generates the ROM file in a proper format
def generate_rom(rom_content):
    # Start of the ROM file
    rom_file = """
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- ROM
--
-- It is a simple entity that takes an address
-- and returns the data at that address.
--
-- It also has a constant signal that outputs how big the ROM is.

entity ROM is
  port(
    -- Clock and reset
    clk         : in std_logic;
    rst         : in std_logic;
    -- Address and data
    address     : in std_logic_vector(7 downto 0);
    instruction : out std_logic_vector(7 downto 0);
    data        : out std_logic_vector(31 downto 0);
    -- Size of the ROM
    size        : out std_logic_vector(7 downto 0)
  );
end entity;

architecture RTL of ROM is
  -- Set the ROM size
  constant rom_size : integer := """
    # Add the size of the ROM to the ROM file
    rom_file += str(len(rom_content))
    rom_file += """; -- Should be between 0 and 255

  -- Initialize the ROM with the data.
  type rom_t is array(0 to rom_size) of std_logic_vector(31 downto 0);

  -- The ROM data
  constant spi_rom : rom_t := (
"""
    # Add two rom contents to each line of the ROM file
    idx = 0
    while True:
        # Copy the content into a variable
        content = rom_content[idx]
        # Check if the line is a comment
        if content.startswith(";"):
            # Remove the semicolon
            content = content[1:]
            # Add the comment to the ROM file
            rom_file += "    --" + content + "\n"
            # Increment the index
            idx += 1
        else:
            formatted_line = "x\"" + rom_content[idx] + "\", " + "x\""
            formatted_line += rom_content[idx + 1] + "\","
            rom_file += "    " + formatted_line + "\n"
            # Increment the index
            idx += 2

        # Check if we are at the end of the rom content
        if idx >= len(rom_content):
            break

    # End of the ROM file
    rom_file += """  );

begin

  -- Output the size of the ROM.
  -- This signal is a constant, so it doesn't need to be synchronized.
  size <= std_logic_vector(to_unsigned(rom_size, 8));

  -- The ROM process that makes sure the data is outputted at the right time.
  rom_process : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        -- Output nothing
        instruction <= (others => '0');
        data        <= (others => '0');
      else
        -- Output the data at the address.
        instruction <= spi_rom(to_integer(unsigned(address)))(7 downto 0);
        data        <= spi_rom(to_integer(unsigned(address + 1)));
      end if;
    end if;
  end process;

end architecture;"""

    # Write the ROM file
    with open('ROM.vhd', 'w') as f:
        f.write(rom_file)

    print("ROM file generated successfully!")


# Main function
rom = load_rom()
rom_optimized = optimize_content(rom)
rom_content = parse_content(rom_optimized)
generate_rom(rom_content)