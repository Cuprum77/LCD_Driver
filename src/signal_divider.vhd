--------------------------------------------------------------------------
--! @file signal_divider.vhd
--! @brief Integer divider for dividing a signal by a power of 2
--! @author Cuprum https://github.com/Cuprum77
--! @date 2024-01-27
--! @version 1.0
--------------------------------------------------------------------------

--! Use standard library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Use unsigned library for arithmetic on std_logic_vector
use ieee.std_logic_unsigned.all;

entity signal_divider is
  generic(
    div : integer := 2 --! Division factor, must be a power of 2
  );
  port(
    signal_input    : in  std_logic;  --! Input signal
    signal_divided  : out std_logic   --! Output signal, divided by the division factor
  );
end entity signal_divider;

--! @brief Divider architecture
--! @details The architecture contains an internal counter that counts the number of rising edges of the input signal.
--! The output signal is high when the counter reaches the division factor.
architecture rtl of divider is
  --! Internal counter
  signal input_cnt : std_logic_vector((div - 1) downto 0) := (others => '0');
begin
  --! Counting process for the internal counter
  div_process : process(signal_input)
  begin
    if rising_edge(signal_input) then
      input_cnt <= input_cnt + 1;
    end if;
  end process div_process;

  --! Output signal is high when the counter reaches the division factor
  signal_divided <= input_cnt((div - 1));
end architecture rtl;