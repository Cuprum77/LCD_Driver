--------------------------------------------------------------------------
--! @file resetter.vht
--! @brief Testbench for the resetter module
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

--! Work library
use work.driver_top_pkg.all;

--! Use UVVM library
library uvvm_util;
context uvvm_util.uvvm_util_context;
use uvvm_util.spi_bfm_pkg.all;

entity resetter_tb is
end resetter_tb;

architecture RTL of resetter_tb is
  --! Constants
  constant clk_period : time := 20 ns; -- 50 MHz

  --! Signals
  signal clk      : std_logic := '0';
  signal rst      : std_logic := '0';
  signal rst_n    : std_logic;
  signal done     : std_logic;
  signal clk_en   : boolean := false;
  
  component resetter is
    port (
      clk         : in  std_logic;  --! Clock
      rst         : in  std_logic;  --! Reset, synchronous
      settings    : in  t_spi_settings; --! Settings
      disp_rst_n  : out std_logic;  --! Display reset, active low
      done        : out std_logic   --! Done signal
    );
  end component resetter;

begin

  -- map the DUT
  DUT : resetter
    port map (
      clk         => clk,
      rst         => rst,
      settings    => c_spi_settings,
      disp_rst_n  => rst_n,
      done        => done
    );

  -- clock generator
  clock_generator(clk, clk_en, clk_period, "clock");

  main : process
  begin
    set_log_file_name("Resetter_log.txt");
    set_alert_stop_limit(ERROR, 0); -- Do not stop
    report_global_ctrl(VOID); -- Show global control
    enable_log_msg(ALL_MESSAGES); -- Show all log messages

    log(ID_LOG_HDR, "Starting the simulation for the Resetter module");

    clk_en <= true; -- Start the clock generator

    -- Generate a reset signal
    wait for 1 * clk_period;
    gen_pulse(rst, clk_period, "Generating Reset");
    wait for 5 * clk_period;

    check_value(rst_n, '1', "Checking the reset signal");

    -- Resetter has started, wait for the required time
    wait for 10 ms;

    -- Verify that the rst_n is 0
    check_value(rst_n, '0', "Checking the reset signal");

    -- Wait for the resetter to finish
    wait for 100 ms;
    check_value(rst_n, '1', "Checking the reset signal");

    -- Wait for the resetter to finish
    wait for 10 ms;
    check_value(done, '1', "Checking the done signal");

    -- Give it some extra time to make the waveform look nice
    wait for 1 ms;

    log(ID_LOG_HDR, "Finished the simulation for the Resetter module");
    -- Finish the simulation
    std.env.stop;
    wait;
  end process;

end architecture;




