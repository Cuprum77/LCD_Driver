library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;
use uvvm_util.spi_bfm_pkg.all;

entity sequencer_tb is
end sequencer_tb;

architecture RTL of sequencer_tb is
  -- constants
  constant clk_period : time := 10ns; -- 100 MHz

  -- signals
  signal clk              : std_logic := '0';
  signal rst              : std_logic := '0';
  signal spi_sda          : std_logic := '0';
  signal spi_scl          : std_logic := '0';
  signal spi_cs           : std_logic := '0';
  signal disp_rst_n       : std_logic := '0';
  signal done             : std_logic := '0';
  signal sequencer_error  : std_logic := '0';

  -- adding the component declaration
  component Sequencer is
    generic(
      -- Allow us to disable the resetter for testing and debugging
      enable_resetter : boolean := true
    );
    port(
      -- Clock and reset
      clk             : in std_logic;  -- 100 MHz clock
      rst             : in std_logic;  -- Reset
      -- SPI ports
      spi_sda         : out std_logic; -- SPI SDA (Data)
      spi_scl         : out std_logic; -- SPI SCL (Clock)
      spi_cs          : out std_logic; -- SPI CS (Chip Select)
      spi_dc          : out std_logic; -- SPI DC (Data/Command)
      -- display ports
      disp_rst_n      : out std_logic; -- Reset for the display
      -- Sequencer outputs
      done            : out std_logic; -- HIGH when done
      sequencer_error : out std_logic  -- HIGH if error
    );
  end component;

  type rom_t is array(0 to 18) of std_logic_vector(31 downto 0);
  constant spi_result : rom_t :=(
    -- reset the display
    x"00000001",
    -- set the display to sleep out
    x"00000011",
    -- set the pixel format
    x"0000003a",
    x"00000055",
    -- set rotation
    x"00000036",
    x"00000000",
    -- set the display pointer's x position
    x"0000002a",
    x"00000000",
    x"00000000",
    x"000000ef",
    x"00000000",
    -- set the display pointer's y position
    x"0000002b",
    x"00000000",
    x"00000000",
    x"0000003f",
    x"00000001",
    -- turn on the display inversion
    x"00000021",
    -- normal mode on
    x"00000013",
    -- enable the display
    x"00000029"
  );

  signal clk_en   : boolean := false;
  signal data_rx  : std_logic_vector(31 downto 0) := (others => '0');

begin

  DUT : Sequencer
    generic map(
      enable_resetter => false
    )
    port map(
      clk             => clk,
      rst             => rst,
      spi_sda         => spi_sda,
      spi_scl         => spi_scl,
      spi_cs          => spi_cs,
      disp_rst_n      => disp_rst_n,
      done            => done,
      sequencer_error => sequencer_error
    );

  -- clock generator
  clock_generator(clk, clk_en, clk_period, "clock");

  main : process
  begin
    set_log_file_name("Sequencer_log.txt");
    set_alert_stop_limit(ERROR, 0); -- Do not stop
    report_global_ctrl(VOID); -- Show global control
    enable_log_msg(ALL_MESSAGES); -- Show all log messages

    log(ID_LOG_HDR, "Starting the simulation for the Sequencer module");

    clk_en <= true; -- Start the clock generator

    -- Generate a reset signal
    wait for 1 * clk_period;
    gen_pulse(rst, clk_period, "Generating Reset");
    wait for 1 * clk_period;

    -- Verify that the signals are the correct states after a reset
    log(ID_LOG_HDR, "Verifying that the signals meet requirements");
    check_value(spi_sda, '0', "Checking SPI_SDA");
    check_value(spi_scl, '0', "Checking SPI_SCL");
    check_value(spi_cs, '1', "Checking SPI_CS");
    check_value(done, '0', "Checking DONE");
    check_value(sequencer_error, '0', "Checking ERROR");

    -- The sequencer should have started now,just wait until instruction starts
    for j in 0 to 18 loop
      data_rx <= (others => '0'); -- Reset the data rx
      -- Set a header to the current index
      log(ID_LOG_HDR, "Checking instruction x" & to_hex_string(spi_result(j)) & " (" & to_string(j) & "/18)");
      wait until spi_cs = '0';
      for i in 7 downto 0 loop
        wait until spi_scl = '1';
        data_rx(i) <= spi_sda;
        wait until spi_scl = '0';
      end loop;
      check_value(data_rx, spi_result(j), "Checking data");
      wait until spi_cs = '1';
    end loop;

    -- Give it some extra time before continuing with the last test
    wait for 10 * clk_period;
    log(ID_LOG_HDR, "Verifying that the signals meet requirements");
    check_value(spi_sda, '0', "Checking SPI_SDA");
    check_value(spi_scl, '0', "Checking SPI_SCL");
    check_value(spi_cs, '1', "Checking SPI_CS");
    check_value(done, '1', "Checking DONE");
    check_value(sequencer_error, '0', "Checking ERROR");

    -- Give it some time before stopping it completely
    wait for 10 * clk_period;

    -- Finish the simulation
    std.env.stop;
    wait; -- Stop completely
  end process;

end architecture;
