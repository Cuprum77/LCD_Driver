# Resetter simulation

This is the files for the Sequencer simulation. The simulation is done using ModelSim and the [UVVM](https://github.com/UVVM/UVVM_Light) framework.

## Simulation

This is a very simple testbench, and like the others, UVVM really wasn't necessary.
Despite that, I want to use it more, so I'm using it here.

The goal of this simulation is like every other simulation, to verify the functionality of the module.
This is done by setting a few goals our module should achieve, and then verifying that it does so.

## Simulation Goals

The goals of this simulation are as follows:
1. Reset should be high for 10 ms
2. Reset should be low for 100 ms
3. Reset should be high for 10 ms
4. A done signal should be sent when the reset is done

## Simulation Results

The results can be viewed in the [log file](Resetter_log.txt).