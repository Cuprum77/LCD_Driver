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
  generic(
    clk_div :   integer := 23;  --! Clock divider, 2**23 for ~6 Hz on 50 MHz
    led_cnt :   integer := 4    --! Number of LEDs
  );
  port(
    clk : in    std_logic;      --! Clock input
    rst : in    std_logic;      --! Reset input, asynchronous
    led : inout std_logic_vector((led_cnt-1) downto 0)  --! LED output
  );
end entity heart_rider;

--! @brief Heart Rider architecture
--! @details This architecture contains two counters, one for generating the heart beat pulse,
--! and one taking said pulse and creating a knight rider effect on the LEDs.
architecture rtl of heart_rider is
  --! Heart beat counter
  signal heart_cnt  : unsigned(clk_div downto 0);
  --! Heart beat pulse
  signal heart_beat : std_logic;
begin

  --! Heart beat pulse generator
  --! @details This process counts up and overflows.
  proc_heart_cnt : process(clk, rst)
  begin
    if rst = '1' then
      heart_cnt <= (others => '0');
    elsif rising_edge(clk) then
      heart_cnt <= heart_cnt + 1;
    end if;
  end process proc_heart_cnt;

  --! Every 2**clk_div clock cycles, generate a heart beat pulse
  heart_beat <= heart_cnt(heart_cnt'LENGTH - 1);

  --! Knight rider effect counter
  heart_rider_process : process(heart, rst)
  begin
    if rst = '1' then
      --! Reset the LEDs, but make sure that at least one LED is on
      heart_led <= '1' & (others => '0');
    elsif rising_edge(heart) then
      --! Shift the LEDs one step to the right
      heart_led <= heart_led((heart_led'length - 2) downto 0) & 
        heart_led(heart_led'length - 1);
    end if;
  end process heart_rider_process;

  --! Connect the LEDs to the heart beat pulse
  led <= heart_led;

end architecture rtl;
