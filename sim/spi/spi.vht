--------------------------------------------------------------------------
--! @file spi.vht
--! @brief SPI testbench
--! @author Cuprum https://github.com/Cuprum77
--! @date 2024-01-27
--! @version 1.0
--------------------------------------------------------------------------

--! Use standard library
library ieee;
use ieee.std_logic_1164.all;

--! UVVM library
library uvvm_util;
context uvvm_util.uvvm_util_context;
use uvvm_util.spi_bfm_pkg.all;

--! Work library
use work.driver_top_pkg.all;

entity spi_tb is
end spi_tb;

--! Testbench architecture
architecture RTL of spi_tb is
  --! Constants
  constant clk_period : time := 5ns; -- 200 MHz

  --! Signals, these are all initialized to 0
  signal clk        : std_logic := '0';
  signal rst        : std_logic := '0';
  signal spi_sda    : std_logic := '0';
  signal spi_scl    : std_logic := '0';
  signal spi_cs     : std_logic := '0';
  signal spi_dc     : std_logic := '0';
  signal send       : std_logic := '0';
  signal set_dc     : std_logic := '0';
  signal done       : std_logic := '0';
  signal bit_width  : std_logic_vector(2 downto 0) := (others => '0');
  signal data       : std_logic_vector(31 downto 0) := (others => '0');

  --! Add the external SPI component
  component spi is
    port(
      clk       : in  std_logic; --! Clock
      rst       : in  std_logic; --! Reset, synchronous
      settings  : in  t_spi_settings; --! Settings for the display
      spi_sda   : out std_logic; --! SPI SDA (Data)
      spi_scl   : out std_logic; --! SPI SCL (Clock)
      spi_cs    : out std_logic; --! SPI CS (Chip Select)
      spi_dc    : out std_logic; --! SPI DC (Data/Command)
      send      : in  std_logic; --! Send, active high
      set_dc    : in  std_logic; --! If the SPI DC is set or not, active high
      spi_done  : out std_logic; --! Signals completion of a transmission
      data      : in  std_logic_vector(31 downto 0); --! Data to be transmitted
      bit_width : in  std_logic_vector(2 downto 0)   --! Number of bits to send
    );
  end component spi;

  signal clk_en   : boolean := false;
  signal data_rx  : std_logic_vector(32 downto 0) := (others => '0');

begin

  -- set up the component
  DUT : spi
    port map(
      clk       => clk,
      rst       => rst,
      settings  => c_spi_settings,
      spi_sda   => spi_sda,
      spi_scl   => spi_scl,
      spi_cs    => spi_cs,
      spi_dc    => spi_dc,
      send      => send,
      set_dc    => set_dc,
      spi_done  => done,
      data      => data,
      bit_width => bit_width
    );

  -- clock generator
  clock_generator(clk, clk_en, clk_period, "clock");
  
  -- main process
  main : process
  begin
    set_log_file_name("SPI_log.txt");
    set_alert_stop_limit(ERROR, 0); -- Do not stop
    report_global_ctrl(VOID); -- Show global control
    enable_log_msg(ALL_MESSAGES); -- Show all log messages

    log(ID_LOG_HDR, "Starting the simulation for the SPI module");

    clk_en <= true; -- Start the clock generator

    -- Generate a reset signal
    wait for 1 * clk_period;
    gen_pulse(rst, clk_period, "Generating Reset");
    wait for 1 * clk_period;

    -- Check if the outputs match the expected values as specified in the readme
    log(ID_LOG_HDR, "Verifying that the signals meet requirements");
    check_value(spi_sda, '0', "Checking SPI_SDA");
    check_value(spi_scl, '0', "Checking SPI_SCL");
    check_value(spi_cs, '1', "Checking SPI_CS");
    check_value(done, '1', "Checking DONE");
    wait for 1 * clk_period;

    -- Check if the module does not change during a reset, while we supply a transmit signal
    log(ID_LOG_HDR, "Verifying the reset, with a send signal");
    gen_pulse(rst, clk_period, "Generating Reset");
    gen_pulse(send, clk_period, "Generating Send");
    wait for 2 * clk_period;

    -- After waiting for two clock cycles, verify the result
    check_value(done, '1', "Checking Done");
    wait for 1 * clk_period;
    
    -- Reset the module again
    wait for 1 * clk_period;
    gen_pulse(rst, clk_period, "Generating Reset");
    wait for 2 * clk_period;

    -- Set up a transmission
    log(ID_LOG_HDR, "Verifying the DONE signal");
    data <= x"000000aa";
    bit_width <= (others => '0');
    -- Pulse the send signal
    gen_pulse(send, clk_period, "Transmit the data");
    check_value(done, '1', "Checking Done before transmission");
    wait for 1 * clk_period;
    check_value(done, '0', "Checking Done during transmission");

    -- Verify that the data is transmitted correctly
    for i in 8 downto 0 loop
      wait until spi_scl = '1';
      data_rx(i) <= spi_sda;
      wait until spi_scl = '0';
    end loop;

    -- Wait until the CS line is no longer held low
    wait until spi_cs = '1';
    -- Now it should be high (or else it wouldnt have gotten here lol)
    check_value(done, '1', "Checking Done after transmission");

    -- Check if the data_rx matches the transmitted data
    log(ID_LOG_HDR, "Verifying the DATA signal (8 bits)");
    check_value(data_rx, x"0000000aa", "Checking data, 8 bits");

    -- Wait a while
    wait for 10 * clk_period;
    -- Setup the test to verify the clk period is correct
    data <= x"aaaaaaaa";
    -- Verify 16 bits of data
    log(ID_LOG_HDR, "Verifying the DATA signal (16 bits)");
    bit_width <= "001"; -- 16 bits
    data_rx <= (others => '0'); -- Reset the data rx
    gen_pulse(send, clk_period, "Transmit the data");

    -- Verify that the data is transmitted correctly
    for i in 16 downto 0 loop
      wait until spi_scl = '1';
      data_rx(i) <= spi_sda;
      wait until spi_scl = '0';
    end loop;
    check_value(data_rx, x"00000aaaa", "Checking data");

    -- Give it some time before stopping it completely
    wait for 10 * clk_period;

    -- Verify 18 bits of data
    bit_width <= "010"; -- 18 bits
    data_rx <= (others => '0'); -- Reset the data rx
    log(ID_LOG_HDR, "Verifying the DATA signal (18 bits)");
    gen_pulse(send, clk_period, "Transmit the data");

    -- Verify that the data is transmitted correctly
    for i in 18 downto 0 loop
      wait until spi_scl = '1';
      data_rx(i) <= spi_sda;
      wait until spi_scl = '0';
    end loop;
    check_value(data_rx, x"00002aaaa", "Checking data");

    -- Give it some time before stopping it completely
    wait for 10 * clk_period;

    -- Verify 24 bits of data
    bit_width <= "011"; -- 24 bits
    data_rx <= (others => '0'); -- Reset the data rx
    log(ID_LOG_HDR, "Verifying the DATA signal (24 bits)");
    gen_pulse(send, clk_period, "Transmit the data");

    -- Verify that the data is transmitted correctly
    for i in 24 downto 0 loop
      wait until spi_scl = '1';
      data_rx(i) <= spi_sda;
      wait until spi_scl = '0';
    end loop;
    check_value(data_rx, x"000aaaaaa", "Checking data");

    -- Give it some time before stopping it completely
    wait for 10 * clk_period;

    -- Verify 32 bits of data
    bit_width <= "100"; -- 32 bits
    data_rx <= (others => '0'); -- Reset the data rx
    log(ID_LOG_HDR, "Verifying the DATA signal (32 bits)");
    gen_pulse(send, clk_period, "Transmit the data");

    -- Verify that the data is transmitted correctly
    for i in 32 downto 0 loop
      wait until spi_scl = '1';
      data_rx(i) <= spi_sda;
      wait until spi_scl = '0';
    end loop;
    check_value(data_rx, x"0aaaaaaaa", "Checking data");

    -- Give it some time before stopping it completely
    wait for 10 * clk_period;

    -- Finish the simulation
    std.env.stop;
    wait; -- Stop completely
  end process;

end architecture;