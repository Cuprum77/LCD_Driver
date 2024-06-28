--------------------------------------------------------------------------
--! @file heart_rider.vhd
--! @brief Heart Rider, creates a LED knight rider effect
--! @details This module creates a LED knight rider effect on the 4 LEDs of the
--! FPGA board. This allows the user to verify that the FPGA is working.
--! @author Cuprum https://github.com/Cuprum77
--! @date 2024-01-27
--! @version 1.0
--------------------------------------------------------------------------

--! Use standard library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity heart_rider is
  port(
    clk_200 : in  std_logic;      --! Clock input
    led     : out std_logic_vector(5 downto 0)  --! LED output
  );
end entity heart_rider;

--! @brief Heart Rider architecture
--! @details This architecture contains two counters, one for generating the heart beat pulse,
--! and one taking said pulse and creating a knight rider effect on the LEDs.
architecture rtl of heart_rider is
  --! Heart beat counter
  signal heart_cnt  : unsigned(24 downto 0);
  --! Knight rider effect counter
  signal heart_led  : std_logic_vector(5 downto 0) := (0 => '1', others => '0');
  --! Heart beat pulse
  signal heart_beat : std_logic;
  --! Reset signal (active high)
  signal rst       : std_logic := '0';
begin

  --! Heart beat pulse generator
  --! @details This process counts up and overflows.
  proc_heart_cnt : process(clk_200, rst)
  begin
    if rst = '1' then
      heart_cnt <= (others => '0');
    elsif rising_edge(clk_200) then
      heart_cnt <= heart_cnt + 1;
    end if;
  end process proc_heart_cnt;

  --! Every 2**clk_200_div clock cycles, generate a heart beat pulse
  heart_beat <= heart_cnt(23);

  --! Knight rider effect counter
  heart_rider_process : process(heart_beat, rst)
    -- Variable to keep track of the direction of the knight rider effect
    variable direction : std_logic := '1';
  begin
    if rst = '1' then
      --! Reset the LEDs, but make sure that at least one LED is on
      heart_led <= (0 => '1', others => '0');
    elsif rising_edge(heart_beat) then
      -- Change the direction of the knight rider effect when the last LED is reached
      if heart_led = "100000" then
        direction := '1';
      elsif heart_led = "000001" then
        direction := '0';
      end if;

      if direction = '1' then
        --! Move the LED to the right
        heart_led <= heart_led(0) & heart_led(5 downto 1);
      else
        --! Move the LED to the left
        heart_led <= heart_led(4 downto 0) & heart_led(5);
      end if;
    end if;
  end process heart_rider_process;

  --! Connect the LEDs to the heart beat pulse
  led <= heart_led;

end architecture rtl;
