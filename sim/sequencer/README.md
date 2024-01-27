# Simulation of the Sequencer

This is the files for the Sequencer simulation. The simulation is done using ModelSim and the [UVVM](https://github.com/UVVM/UVVM_Light) framework.

## Simulation

The goal of this simulation is to verify the functionality of the sequencer and that it outputs the correct data when it should.
However, unlike the SPI simulation, this simulation will not provide any actual data to test. That is the job of the ROM.

This means you need to generate your own ROM file to test the sequencer with. This is done by ruinning the [ROM generator](../../SPI_Init/rom_generator.py) script.
The assembly file used for this simulation can be found [here](data.txt).

We will also not test any of the SPI functionality, as that module is assumed to be working correctly following a successful simulation.

## Simulation Setup

The sequencer is a lot simpler than the SPI module in terms of if it works or not. Either it outputs the SPI data correctly, or it doesn't.
This makes it significantly easier to test, as we can simply verify that the data is correct with a given input, such as the one provided in this folder.

Please note that the simulation will fail without the correct ROM file, as it is expecting the same data as the ROM file provides.

Note, there are only 8 bit instructions being used in this simulation.

## Results

The results can be viewed in the [log file](Sequencer_log.txt).
If there were any problems, they will show in the [alert file](_Alert.txt). This file will be empty if there were no problems.