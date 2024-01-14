# ROM

The ROM is a generated file that contains the instructions for the sequencer. It is a VHDL file that contains a constant array thats 32 bits wide and as long as the number of instructions in the ROM minus the number of comments.

This should be generated using the [ROM Generator](#rom-generator).

## ROM Generator

The ROM generator is a terminal script that takes in the text file as an argument and outputs a VHDL file containing the ROM.
The script can be found at [rom_generator.py](rom/rom_generator.py).

The script expects a text file containing the instructions for the sequencer. Each instruction should be on its own line, and the instruction and its payload should be separated by a space.

An example of a valid instruction file for an ST7789V display can be found [here](rom/example/st7789v_instructions.txt).

## Usage

The script can be run using the following command:
```
python3 rom_generator.py -i <input_file>
```
Where `<input_file>` is the text file containing the instructions.

The script will output a VHDL file containing the ROM. This file can then be found in the same folder as the script.