--------------------------------------------------------------------------
--! @file driver_top.vhd
--! @brief Top level driver for the FPGA
--! @author Cuprum https://github.com/Cuprum77
--! @date 2024-01-27
--! @version 1.0
--------------------------------------------------------------------------

--! Use standard library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Xilinx specific libraries
library UNISIM;
use UNISIM.VComponents.all;

--! Work library
use work.driver_top_pkg.all;

entity display_top is
  port (
    clk_200       : in    std_logic; --! 125 MHz external clock
    hdmi_cec      : out   std_logic; --! Consumer Electronics Control
    hdmi_util     : out   std_logic; --! Utility channel
    hdmi_hpd      : out   std_logic; --! Hot plug detection
    hdmi_sda      : inout std_logic; --! I2C SDA
    hdmi_scl      : in    std_logic; --! I2C SCL
    hdmi_clk_n    : in    std_logic; --! TMDS clock negative
    hdmi_clk_p    : in    std_logic; --! TMDS clock positive
    hdmi_n        : in    std_logic_vector(2 downto 0);  --! TMDS data negative
    hdmi_p        : in    std_logic_vector(2 downto 0);  --! TMDS data positive
    rgb_sda       : out   std_logic; --! I2C SDA
    rgb_scl       : out   std_logic; --! I2C SCL
    rgb_cs        : out   std_logic; --! Chip select
    rgb_clk       : out   std_logic; --! Clock
    rgb_rst_n     : out   std_logic; --! Reset
    rgb_de        : out   std_logic; --! Data enable
    rgb_vs        : out   std_logic; --! Vertical sync
    rgb_hs        : out   std_logic; --! Horizontal sync
    rgb_d         : out   std_logic_vector(17 downto 0); --! RGB data, 6 bits per color
    led           : out   std_logic_vector (7 downto 0)  --! LEDs
  );
end entity;

architecture rtl of display_top is
  --! Declare the sequencer component
  component sequencer is
    port(
      -- Clock and reset
      clk             : in  std_logic;  --! Clock
      rst             : in  std_logic;  --! Reset, synchronous
      settings        : in  t_spi_settings; --! Settings for the display
      spi_sda         : out std_logic;  --! SPI SDA (Data)
      spi_scl         : out std_logic;  --! SPI SCL (Clock)
      spi_cs          : out std_logic;  --! SPI CS (Chip Select)
      spi_dc          : out std_logic;  --! SPI DC (Data/Command)
      disp_rst_n      : out std_logic;  --! Reset for the display
      done            : out std_logic;  --! HIGH when done
      sequencer_error : out std_logic   --! HIGH if error
    );
  end component sequencer;

  --! Declare the heart component
  component heart_rider is
    port(
      clk_200 : in  std_logic;      --! Clock input
      led     : out std_logic_vector(5 downto 0)  --! LED output
    );
  end component heart_rider;

  -- Declare the signal divider component
  component signal_divider is
    generic(
      div : integer := 2 --! Division factor, must be a power of 2
    );
    port(
      signal_input    : in  std_logic;  --! Input signal
      signal_divided  : out std_logic   --! Output signal, divided by the division factor
    );
  end component signal_divider;

  component i2c_edid is
    generic(
      hex_file : string := "edid.hex"
    );
    port(
      clk : in std_logic;
      rst : in std_logic;
      scl : in std_logic;
      sda : inout std_logic
    );
  end component i2c_edid;

  component dvi_decoder is
    generic (
      TMDS_INVERT : boolean := false
    );
    port (
      clkin       : in  std_logic;
      tmdsclk_p   : in  std_logic;
      tmdsclk_n   : in  std_logic;
      blue_p      : in  std_logic;
      green_p     : in  std_logic;
      red_p       : in  std_logic;
      blue_n      : in  std_logic;
      green_n     : in  std_logic;
      red_n       : in  std_logic;
      clk         : out std_logic;
      clkx5       : out std_logic;
      clkx5not    : out std_logic;
      reset       : out std_logic;
      hsync       : out std_logic;
      vsync       : out std_logic;
      de          : out std_logic;
      psalgnerr   : out std_logic;
      sdout       : out std_logic_vector(29 downto 0);
      red         : out std_logic_vector(7 downto 0);
      green       : out std_logic_vector(7 downto 0);
      blue        : out std_logic_vector(7 downto 0)
    );
  end component;

  --! Clocks and reset
  signal clk_50 : std_logic := '0';

  --! SPI bus
  signal sda    : std_logic := '0';
  signal scl    : std_logic := '0';
  signal cs     : std_logic := '0';

  --! Sequencer signals
  signal done   : std_logic := '0';
  signal pclk   : std_logic := '0';
  constant hdp  : std_logic := '1';

  --! HDMI specific signals
  signal red    : std_logic_vector(7 downto 0)  := (others => '0');
  signal green  : std_logic_vector(7 downto 0)  := (others => '0');
  signal blue   : std_logic_vector(7 downto 0)  := (others => '0');

  signal edid_data : std_logic_vector(7 downto 0) := (others => '0');
  signal edid_addr : std_logic_vector(7 downto 0) := (others => '0');

begin

  --! Map the sequencer module
  sequencer_inst : sequencer
    port map (
      clk             => clk_50,
      rst             => '0',
      settings        => c_spi_settings,
      spi_sda         => rgb_sda,
      spi_scl         => rgb_scl,
      spi_cs          => rgb_cs,
      spi_dc          => open,
      disp_rst_n      => rgb_rst_n,
      done            => done,
      sequencer_error => open
    );

  --! Map the heart module
  heart_inst : heart_rider
    port map (
      clk_200 => clk_200,
      led     => led(7 downto 2)
    );

  --! Map the clk divider
  clk_div_inst : signal_divider
    generic map (
      div => 4
    )
    port map(
      signal_input    => clk_200,
      signal_divided  => clk_50
    );

  --! Decoder
  dvi_dec_inst : dvi_decoder
    generic map(
      TMDS_INVERT => false
    )
    port map(
      clkin     => clk_200,
      tmdsclk_p => hdmi_clk_p,
      tmdsclk_n => hdmi_clk_n,
      blue_p    => hdmi_p(0),
      blue_n    => hdmi_n(0),
      green_p   => hdmi_p(1),
      green_n   => hdmi_n(1),
      red_p     => hdmi_p(2),
      red_n     => hdmi_n(2),
      clk       => rgb_clk,
      clkx5     => open,
      clkx5not  => open,
      reset     => open,
      hsync     => rgb_hs,
      vsync     => rgb_vs,
      de        => rgb_de,
      psalgnerr => open,
      sdout     => open,
      red       => red,
      green     => green,
      blue      => blue
    );

  --! I2C EDID
  i2c_edid_inst : i2c_edid
    generic map(
      hex_file => "edid.hex"
    )
    port map(
      clk => clk_200,
      rst => '0',
      sda => hdmi_sda,
      scl => hdmi_scl
    );

  --! Set the HPD signal to high to enable the HDMI receiver
  hdmi_hpd  <= done;
  hdmi_cec  <= done;
  hdmi_util <= '0';
  led(1)    <= hdp;
  led(0)    <= done;

  --! Red component (6 bits)
  rgb_d(17 downto 12) <= red(7 downto 2);
  --! Green component (6 bits)
  rgb_d(11 downto 6)  <= green(7 downto 2);
  --! Blue component (6 bits)
  rgb_d(5 downto 0)   <= blue(7 downto 2);

end architecture rtl;