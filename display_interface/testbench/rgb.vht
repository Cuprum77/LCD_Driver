library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;
use uvvm_util.spi_bfm_pkg.all;

entity rgb_tb is
end rgb_tb;

architecture tb of rgb_tb is
  -- constants
  constant clk_period : time := 10ns; -- 100 MHz

  -- signals
  signal clk      : std_logic := '0';
  signal rst      : std_logic := '0';
  signal enable   : std_logic := '0';
  signal r        : std_logic_vector(7 downto 0) := (others => '0');
  signal g        : std_logic_vector(7 downto 0) := (others => '0');
  signal b        : std_logic_vector(7 downto 0) := (others => '0');
  signal x        : std_logic_vector(11 downto 0) := (others => '0');
  signal y        : std_logic_vector(11 downto 0) := (others => '0');
  signal rgb_pclk : std_logic := '0';
  signal rgb_de   : std_logic := '0';
  signal rgb_vs   : std_logic := '0';
  signal rgb_hs   : std_logic := '0';
  signal rgb_data : std_logic_vector(23 downto 0) := (others => '0');

  -- adding the component declaration
  component rgb is
    generic(
      pixel_format : std_logic_vector(2 downto 0) := (others => '0')
    );
    port(
      -- clock and reset
      clk         : in std_logic;
      rst         : in std_logic;
      enable      : in std_logic;
      -- pixel data
      r           : in std_logic_vector(7 downto 0);
      g           : in std_logic_vector(7 downto 0);
      b           : in std_logic_vector(7 downto 0);
      -- current pixel position
      x           : out std_logic_vector(11 downto 0);
      y           : out std_logic_vector(11 downto 0);
      -- data output
      rgb_pclk    : out std_logic;
      rgb_de      : out std_logic;
      rgb_vs      : out std_logic;
      rgb_hs      : out std_logic;
      rgb_data    : out std_logic_vector(23 downto 0)
    );
  end component;

  signal clk_en : boolean := true;
  
begin

  DUT : rgb
    generic map(
      pixel_format => "010" -- RGB666
    )
    port map(
      clk         => clk,
      rst         => rst,
      enable      => enable,
      r           => r,
      g           => g,
      b           => b,
      x           => x,
      y           => y,
      rgb_pclk    => rgb_pclk,
      rgb_de      => rgb_de,
      rgb_vs      => rgb_vs,
      rgb_hs      => rgb_hs,
      rgb_data    => rgb_data
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
    check_value(x, x"000", "Checking X helper signal");
    check_value(y, x"000", "Checking Y helper signal");
    check_value(rgb_pclk, '0', "Checking RGB_PCLK");
    check_value(rgb_de, '1', "Checking RGB_DE");
    check_value(rgb_vs, '1', "Checking RGB_VS");
    check_value(rgb_hs, '1', "Checking RGB_HS");
    check_value(rgb_data, x"000000", "Checking RGB_DATA");

    -- enable the module
    enable <= '1';
    -- give it generic white color
    r <= x"FF";
    g <= x"FF";
    b <= x"FF";

    -- Let it simulate for a while
    wait for 406 * 966 * 10 * clk_period;

    -- Give it some time before stopping it completely
    wait for 10 * clk_period;

    -- Finish the simulation
    std.env.stop;
    wait; -- Stop completely
  end process;

end architecture;