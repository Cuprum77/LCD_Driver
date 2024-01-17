library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;
use uvvm_util.spi_bfm_pkg.all;

entity spi_tb is
end spi_tb;

architecture RTL of spi_tb is
  -- constants
  constant clk_period : time := 10ns; -- 100 MHz

  -- signals, these are all initialized to 0
  signal clk        : std_logic := '0';
  signal rst        : std_logic := '0';
  signal spi_sda    : std_logic := '0';
  signal spi_scl    : std_logic := '0';
  signal spi_cs     : std_logic := '0';
  signal send       : std_logic := '0';
  signal done       : std_logic := '0';
  signal bit_width  : std_logic_vector(2 downto 0) := (others => '0');
  signal data       : std_logic_vector(31 downto 0) := (others => '0');

  component SPIDriver is
    generic(
      alternative_dc : boolean := false -- If the SPI DC is the first bit instead of a dedicated pin
    );
    port(
      -- ports
      clk       : in std_logic; -- 100 MHz
      rst       : in std_logic; -- Reset, active HIGH
      -- modified spi interface
      spi_sda   : out std_logic; -- SPI SDA (Data)
      spi_scl   : out std_logic; -- SPI SCL (Clock)
      spi_cs    : out std_logic; -- SPI CS (Chip Select)
      spi_dc    : out std_logic; -- SPI DC (Data/Command)
      send      : in std_logic;  -- Send, active HIGH
      set_dc    : in std_logic;  -- If the SPI DC is set or not, active HIGH
      done      : out std_logic; -- Done, when all the bits have been sent, active LOW
      data      : in std_logic_vector(31 downto 0); -- Bits to be sent
      bit_width : in std_logic_vector(2 downto 0)   -- Number of bits to send
    );
  end component SPIDriver;

  signal clk_en   : boolean := false;
  signal data_rx  : std_logic_vector(32 downto 0) := (others => '0');

begin

  -- set up the component
  DUT : SPIDriver
    generic map(
      alternative_dc => true
    )
    port map(
      clk       => clk,
      rst       => rst,
      spi_sda   => spi_sda,
      spi_scl   => spi_scl,
      spi_cs    => spi_cs,
      spi_dc    => open,
      send      => send,
      set_dc    => '0',
      done      => done,
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