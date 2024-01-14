# Simulation

This folder contains the files that were used for simulation of this project. Each folder contains a readme file that describes the simulation and its goals in more detail.

## Structure

The subfolders each contains a simulation for a specific part of the project, with the exception of the `UVVM` folder which contains the compiled UVVM library, which you need to compile in order to run the simulations.

The subfolders are structured as follows:
- [SPI](SPI/README.md) - Simulation of the SPI interface
- [Sequencer](Sequencer/README.md) - Simulation of the sequencer (with the SPI interface)
- [UVVM](UVVM/README.md) - UVVM library compiled for ModelSim

## Compiling UVVM

To compile UVVM for ModelSim, you need to open ModelSim and run the following snippet in the transcript window:

```tcl
do ../../UVVM_Light/script/compile.do ../../UVVM_Light ../UVVM
```

This should compile the UVVM library and place it in the `UVVM` folder.

## Running the simulations

Simply open up any of the project files in ModelSim and run the simulation.
The UVVM framework should be automatically loaded from the `UVVM` folder assuming you have compiled it correctly.
