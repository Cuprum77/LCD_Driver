library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Assuming a 100 MHz clock
-- Generate a reset pulse as such:
-- 1. Set rst_n to '1' for 10 ms
-- 2. Set rst_n to '0' for 100 ms
-- 3. Set rst_n to '1' for 10 ms
-- 4. Set done to '1'

entity resetter is
  generic(
    delay_10ms  : integer := 1_000_000; -- clock cycles for 10 ms
    delay_100ms : integer := 10_000_000 -- clock cycles for 100 ms
  );
  port (
    clk   : in std_logic;
    rst   : in std_logic;
    rst_n : out std_logic;
    done  : out std_logic
  );
end entity;

architecture rtl of resetter is

  signal cnt : integer range 0 to delay_100ms := 0;
  type state_machine is (
    idle_state,
    first_reset_state,
    second_reset_state,
    third_reset_state,
    done_state
  );
  signal state : state_machine := idle_state;

begin

  rst_seq : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cnt <= 0;
        rst_n <= '0';
        done <= '0';
        state <= idle_state;
      else
        case state is
          -- basically do nothing, this is our reset state
          -- we will however setup the signals as its not
          -- guaranteed that its reset prior to operation
          when idle_state =>
            cnt <= 0;
            rst_n <= '0';
            done <= '0';
            cnt <= delay_10ms;
            state <= first_reset_state;

          -- set rst_n to '1' for 10 ms
          when first_reset_state =>
            if cnt = 0 then
              cnt <= delay_100ms;
              state <= second_reset_state;
            else
              rst_n <= '1';
              cnt <= cnt - 1;
            end if;

          -- set rst_n to '0' for 100 ms
          when second_reset_state =>
            if cnt = 0 then
              cnt <= delay_10ms;
              state <= third_reset_state;
            else
              rst_n <= '0';
              cnt <= cnt - 1;
            end if;

          -- set rst_n to '1' for 10 ms
          when third_reset_state =>
            if cnt = 0 then
              state <= done_state;
            else
              rst_n <= '1';
              cnt <= cnt - 1;
            end if;

          -- set done to '1'
          -- keep rst_n at '1'
          when done_state =>
            rst_n <= '1';
            done <= '1';
            state <= done_state;

          -- it should never get here, but if it *somehow* does, go back to start
          when others =>
            state <= idle_state;
        end case;
      end if;
    end if;
  end process;

end architecture;