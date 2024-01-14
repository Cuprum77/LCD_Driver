import os
import argparse


class ROM_Generator:
	__instruction_psuedo = [
		"cmd",
		"size",
		"data",
		"wait"
	]

	__instruction_hex = [
		0x10,
		0x20,
		0x21,
		0x30
	]

	__word_sizes = [
		8,
		16,
		18,
		24,
		32
	]

	# Constructor
	def __init__(self, filename, debug):
		# Load the psuedo-assembly code from the file
		assembly = self.__load_rom(filename)
		# Optimize the psuedo-assembly code
		assembly, comment_counter = self.optimize_content(assembly, debug)
		# Parse the psuedo-assembly code
		command, command_comment, payload = self.parse_content(assembly)
		# Generate the ROM file
		self.generate_rom(command, command_comment, payload, comment_counter)


	# Function that loads the psuedo-assembly code from the instructions.txt file
	def __load_rom(self, filename):
		# Check if the file exists
		try:
			# Load the ROM psuedo-assembly code into a list
			with open(filename) as f:
				rom = f.readlines()
		except IOError:
			# Print the error in the console
			print(f"ERROR: FILE \"{filename}\" DOES NOT EXIST!")
			# Exit the program
			exit()

		return rom


	# Throw an error if the instruction is not valid
	def __error(self, line):
		print("ERROR: UNKNOWN INSTRUCTION \"" + str(line) + "\"!")
		exit()


	# Function that checks the length of the instruction
	def check_instruction_length(self, instruction_list, assembly, line):
		# Get length of the instruction
		payload_size = len(instruction_list)
		# If theres only 1 item in the instruction_list, then theres too little data
		if payload_size <= 1:
			# Someone forgot to add data to the instruction
			self.error(line)
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
	def fetch_payload(self, line):
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
	def optimize_content(self, assembly, debug):
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
			elif temp[0] in self.__instruction_psuedo:
				# Make sure its a valid length
				instruction_length = self.check_instruction_length(temp, cleaned_content, line)

				# If its a size instruction, change the word size
				if temp[0] == "size":
					# Fetch the payload
					payload = self.fetch_payload(temp[1])
					# Check if the size is valid
					if payload in self.__word_sizes:
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
						payload = self.fetch_payload(temp[i]) + overflow
						overflow = 0
						
						# Check if its less than the max value
						if payload <= max_value:
							# Add the instruction hex and payload to the rom content
							rom_content.append(instruction)
							rom_content.append(format(payload, '08x'))
						else:
							# The payload is too large, we must split it up and append it infront of the current instruction
							overflow = max_value >> current_word_size
							# Add the instruction hex and payload to the rom content
							rom_content.append(instruction)
							rom_content.append(format(payload - max_value, '08x'))

				# If the length is at or greater than 1, just add the payload at index 1
				else:
					payload = self.fetch_payload(temp[0])

					# Add the instruction hex and payload to the rom content
					rom_content.append(instruction)
					rom_content.append(format(payload, '08x'))

			else:
				# The instruction is not valid
				self.error(line)

		# Do a sanity check to make sure the rom content is less or equal to 255
		if len(rom_content) > (512 + comment_counter):
			print("ERROR: ROM content is greater than 255 bytes!")
			exit()

		# Check
		if debug:
			# Check if the new folder exists
			try:
				os.mkdir("output")
			except FileExistsError:
				pass

			# Write the optimized psuedo-assembly code to the file
			with open('output/instructions_optimized.txt', 'w') as f:
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

		return rom_content, comment_counter


	# Function that parses the psuedo-assembly code and generates the ROM file
	def parse_content(self, assembly):
		command = []
		command_comment = []
		payload = []

		# Go through each line of the psuedo-assembly code
		idx = 0
		while True:
			# Check if its a comment
			if assembly[idx].startswith(";"):
				# Add the comment to the rom content
				command.append(assembly[idx])
				payload.append(assembly[idx])
				idx += 1
				continue

			# Get the instruction and payload
			instruction = assembly[idx]
			payload_data = assembly[idx + 1]
			idx += 2
			
			# Get the instruction hex index
			instruction_index = self.__instruction_psuedo.index(instruction)
			# Get the actual hex code
			instruction_hex_code = self.__instruction_hex[instruction_index]
			# Convert it to a hex string thats 8 bits long
			instruction_hex_code = format(instruction_hex_code, '02x')

			# Add the instruction hex and payload to the rom content
			command_comment.append(instruction)
			command.append(instruction_hex_code)
			payload.append(payload_data)

			# Check if we are at the end of the psuedo-assembly code
			if idx >= len(assembly):
				break

		return command, command_comment, payload


	# Function that generates the ROM file in a proper format
	def generate_rom(self, command, command_comment, payload, comment_counter):
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
		rom_file += str(len(command) - comment_counter - 1)
		rom_file += """; -- Should be between 0 and 255

-- Initialize the ROM with the data.
type rom_8b_t is array(0 to rom_size) of std_logic_vector(7 downto 0);
type rom_32b_t is array(0 to rom_size) of std_logic_vector(31 downto 0);

-- The Instruction data
constant instruction_rom : rom_8b_t := (
	"""
		# Add the instructions to the ROM file
		idx = 0
		comment_idx = 0
		while True:
			# Copy the content into a variable
			content = command[idx]
			# Check if the line is a comment
			if content.startswith(";"):
				# Remove the semicolon
				content = content[1:]
				# Add the comment to the ROM file
				rom_file += "    --" + content + "\n"
				# Increment the index
				idx += 1
			else:
				formatted_line = "x\"" + command[idx]
				# If its not the last line, add a comma
				if idx + 2 < len(command):
					formatted_line += "\","
				else:
					formatted_line += "\""
				# Add a comment denoting the instruction
				formatted_line += " -- " + command_comment[comment_idx]
				rom_file += "    " + formatted_line + "\n"
				# Increment the index
				idx += 1
				comment_idx += 1

			# Check if we are at the end of the rom content
			if idx >= len(command):
				break

		rom_file += """  );

		-- The payload data
	constant payload_rom : rom_32b_t := (
	"""
		
		# Add the data to the ROM file
		idx = 0
		while True:
			# Copy the content into a variable
			content = payload[idx]
			# Check if the line is a comment
			if content.startswith(";"):
				# Remove the semicolon
				content = content[1:]
				# Add the comment to the ROM file
				rom_file += "    --" + content + "\n"
				# Increment the index
				idx += 1
			else:
				formatted_line = "x\"" + payload[idx]
				# If its not the last line, add a comma
				if idx + 2 < len(payload):
					formatted_line += "\","
				else:
					formatted_line += "\""
				rom_file += "    " + formatted_line + "\n"
				# Increment the index
				idx += 1

			# Check if we are at the end of the rom content
			if idx >= len(payload):
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
		instruction <= instruction_rom(to_integer(unsigned(address)));
		data        <= payload_rom(to_integer(unsigned(address)));
	end if;
	end if;
end process;

end architecture;"""

		# Write the ROM file
		with open('rom.vhd', 'w') as f:
			f.write(rom_file)

		print("ROM file generated successfully!")


def main():
	parser = argparse.ArgumentParser(
		prog="rom_generator",
		description="Generate a ROM file from psuedo-assembly code."
	)

	parser.add_argument(
		"-i",
		"--input",
		type=str,
		help="The input file containing the psuedo-assembly code.",
		required=True
	)

	parser.add_argument(
		"-d",
		"--debug",
		action="store_true",
		help="Output the optimized code generated from the psuedo-assembly code to a file.",
		required=False,
		default=False
	)

	args = parser.parse_args()

	# Create the ROM generator
	ROM_Generator(args.input, args.debug)


if __name__ == "__main__":
    main()
