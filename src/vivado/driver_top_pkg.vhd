--------------------------------------------------------------------------
--! @file driver_top_pkg.vhd
--! @brief Package containing all the settings for the driver
--! @author Cuprum https://github.com/Cuprum77
--! @date 2024-01-27
--! @version 1.0
--------------------------------------------------------------------------

--! Use standard library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Package declaration
package driver_top_pkg is

  --! Settings for the driver
  type t_spi_settings is record
    alt_spi_dc   : std_logic; --! Alternative Data/command signal for the display
    resetter_en  : std_logic; --! Enable signal for the resetter
    invert_dc    : std_logic; --! Invert the data/command signal
    delay_10ms   : unsigned(7 downto 0); --! Delay for 10ms
  end record t_spi_settings;

  --! Default settings for the driver
  constant c_spi_settings : t_spi_settings := (
    alt_spi_dc  => '1',  --! Alternative Data/command signal for the display
    resetter_en => '1',  --! Enable signal for the resetter
    invert_dc   => '1',  --! Invert the data/command signal
    delay_10ms  => x"16" --! How many bits to shift the delay for 10ms (approximate)
  );

end package driver_top_pkg;