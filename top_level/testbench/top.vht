library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;
use uvvm_util.spi_bfm_pkg.all;

entity top_tb is
end top_tb;

architecture RTL of top_tb is
  -- constants
  constant clk_period : time := 10ns; -- 100 MHz

  -- signals
  signal sysclk         : std_logic := '0';
  signal btn            : std_logic := '0';
  signal hdmi_rx_hpd    : std_logic := '0';
  signal hdmi_rx_sda    : std_logic := '0';
  signal hdmi_rx_scl    : std_logic := '0';
  signal hdmi_rx_cec    : std_logic := '0';
  signal hdmi_rx_clk_n  : std_logic := '0';
  signal hdmi_rx_clk_p  : std_logic := '0';
  signal hdmi_rx_n      : std_logic_vector(2 downto 0) := (others => '0');
  signal hdmi_rx_p      : std_logic_vector(2 downto 0) := (others => '0');
  signal jb             : std_logic_vector (5 downto 0) := (others => '0');
  signal jc             : std_logic_vector (5 downto 0) := (others => '0');
  signal jd             : std_logic_vector (5 downto 0) := (others => '0');
  signal je             : std_logic_vector (7 downto 0) := (others => '0');
  signal led            : std_logic_vector (3 downto 0) := (others => '0');

  -- adding the component declaration
  component top is
    port (
      -- inputs
      sysclk        : in std_logic; -- 125 MHz external clock
      btn           : in std_logic;
      -- hdmi in
      hdmi_rx_hpd   : out std_logic;
      hdmi_rx_sda   : inout std_logic;
      hdmi_rx_scl   : inout std_logic;
      hdmi_rx_cec   : inout std_logic;
      hdmi_rx_clk_n : in std_logic;
      hdmi_rx_clk_p : in std_logic;
      hdmi_rx_n     : in std_logic_vector(2 downto 0);
      hdmi_rx_p     : in std_logic_vector(2 downto 0);
      -- outputs
      jb            : out std_logic_vector (5 downto 0);
      jc            : out std_logic_vector (5 downto 0);
      jd            : out std_logic_vector (5 downto 0);
      je            : out std_logic_vector (7 downto 0);
      led           : out std_logic_vector (3 downto 0)
    );
  end component top;

  signal clk_en : boolean := true;

begin

  -- adding the component instantiation
  DUT : top
    port map (
      sysclk  => sysclk,
      btn     => btn,
      hdmi_rx_hpd => hdmi_rx_hpd,
      hdmi_rx_sda => hdmi_rx_sda,
      hdmi_rx_scl => hdmi_rx_scl,
      hdmi_rx_cec => hdmi_rx_cec,
      hdmi_rx_clk_n => hdmi_rx_clk_n,
      hdmi_rx_clk_p => hdmi_rx_clk_p,
      hdmi_rx_n => hdmi_rx_n,
      hdmi_rx_p => hdmi_rx_p,
      jb      => jb,
      jc      => jc,
      jd      => jd,
      je      => je,
      led     => led
    );

  -- clock generator
  clock_generator(sysclk, clk_en, clk_period, "clock");

  main : process
  begin
    set_log_file_name("Top_log.txt");
    set_alert_stop_limit(ERROR, 0); -- Do not stop
    report_global_ctrl(VOID); -- Show global control
    enable_log_msg(ALL_MESSAGES); -- Show all log messages

    log(ID_LOG_HDR, "Starting the simulation for the entire project!");
    log(ID_LOG_HDR, "This will take at least 10 minutes!");

    clk_en <= true; -- Start the clock generator

    -- Generate a reset signal
    wait for 1 * clk_period;
    gen_pulse(btn, clk_period, "Generating Reset");
    wait for 1 * clk_period;

    -- Let it simulate for a while (this will actually take a while)
    wait for 1000 ms;

    -- Finish the simulation
    std.env.stop;
    wait; -- Stop completely
  end process;

end architecture;