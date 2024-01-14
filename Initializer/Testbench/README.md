# Testbenches

This folder contains the testbenches for the SPI interface and the sequencer.
It contains two different testbenches for each module, one that uses the UVVM framework and one that does not.
The one that doesnt use the UVVM framework is extremely simple and requires the user to visually inspect the output waveform to verify the functionality of the module, while the UVVM testbenches are more complex and automatically verifies the functionality of the module.