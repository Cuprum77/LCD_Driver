--------------------------------------------------------------------------
--! @file resetter.vhd
--! @brief Handles the reset sequencer for the display
--! @author Cuprum https://github.com/Cuprum77
--! @date 2024-01-27
--! @version 1.0
--------------------------------------------------------------------------

--! Use standard library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Work library
use work.driver_top_pkg.all;

entity resetter is
  port (
    clk         : in  std_logic;  --! Clock
    rst         : in  std_logic;  --! Reset, synchronous
    settings    : in  t_spi_settings; --! Settings
    disp_rst_n  : out std_logic;  --! Display reset, active low
    done        : out std_logic   --! Done signal
  );
end entity resetter;

--! @brief Reset sequencer architecture
--! @details The goal is to create a simple counter that generates accurate-ish reset signals
architecture rtl of resetter is
  --! State machine to control the reset sequence
  type state_machine is (
    idle_state,
    first_reset_state,
    second_reset_state,
    third_reset_state,
    done_state
  );
  signal state : state_machine := idle_state;

  --! Internal signal to receive the delay values
  signal delay_10ms   : unsigned(7 downto 0);
  --! Internal counter to count the delay necessary
  signal delay_cnt    : unsigned(31 downto 0);

begin

  --! Copy the 10ms delay value from the settings
  delay_10ms <= settings.delay_10ms;

  --! Reset sequence:
  --!  _______               ________
  --!         \_____________/        
  --!   10 ms      100 ms     10 ms
  rst_seq : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        delay_cnt <= (others => '0');
        disp_rst_n <= '0';
        done <= '0';
        state <= idle_state;
      else
        case state is
          --! Idle state, setup the counter and reset signals to default values
          when idle_state =>
            disp_rst_n <= '0';
            done <= '0';
            --! Reset the counter
            delay_cnt <= (others => '0');
            state <= first_reset_state;

          --! First reset state, count for ~10ms
          when first_reset_state =>
            if delay_cnt(to_integer(delay_10ms)) = '1' then
              --! Reset the counter
              delay_cnt <= (others => '0');
              state <= second_reset_state;
            else
              disp_rst_n <= '1';
              delay_cnt <= delay_cnt + 1;
            end if;

          --! Second reset state, count for ~100ms
          when second_reset_state =>
            if delay_cnt(to_integer(delay_10ms + 2)) = '1' then
              --! Reset the counter
              delay_cnt <= (others => '0');
              state <= third_reset_state;
            else
              disp_rst_n <= '0';
              delay_cnt <= delay_cnt + 1;
            end if;

          --! Third reset state, count for ~10ms
          when third_reset_state =>
            if delay_cnt(to_integer(delay_10ms)) = '1' then
              --! Reset the counter
              state <= done_state;
            else
              disp_rst_n <= '1';
              delay_cnt <= delay_cnt + 1;
            end if;

          --! Complete, set the final signals
          when done_state =>
            disp_rst_n <= '1';
            done <= '1';

          --! Handle the worst case scenario
          when others =>
            state <= idle_state;
        end case;
      end if;
    end if;
  end process rst_seq;

end architecture rtl;