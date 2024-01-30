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
    sysclk        : in    std_logic; --! 125 MHz external clock
    btn           : in    std_logic; --! Reset button
    hdmi_rx_hpd   : out   std_logic; --! Hot plug detection
    hdmi_rx_sda   : inout std_logic; --! I2C SDA
    hdmi_rx_scl   : inout std_logic; --! I2C SCL
    hdmi_rx_clk_n : in    std_logic; --! TMDS clock negative
    hdmi_rx_clk_p : in    std_logic; --! TMDS clock positive
    hdmi_rx_n     : in    std_logic_vector(2 downto 0);  --! TMDS data negative
    hdmi_rx_p     : in    std_logic_vector(2 downto 0);  --! TMDS data positive
    jb            : out   std_logic_vector (5 downto 0); --! PMOD JB
    jc            : out   std_logic_vector (5 downto 0); --! PMOD JC
    jd            : out   std_logic_vector (5 downto 0); --! PMOD JD
    je            : out   std_logic_vector (7 downto 0); --! PMOD JE
    led           : out   std_logic_vector (3 downto 0)  --! LEDs
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
    generic(
      clk_div : integer := 23;  --! Clock divider, 2**23 for ~6 Hz on 50 MHz
      led_cnt : integer := 4    --! Number of LEDs
    );
    port(
      clk : in  std_logic;      --! Clock input
      rst : in  std_logic;      --! Reset input, asynchronous
      led : out std_logic_vector((led_cnt-1) downto 0)  --! LED output
    );
  end component heart_rider;

  --! Declare the Xilinx PLL
  component pll_200 is
    port (
      clk_out : out std_logic;  --! Clock out, 200 MHz
      reset   : in  std_logic;  --! Reset
      clk_in  : in  std_logic   --! Clock in, 125 MHz
    );
  end component pll_200;

  --! Declare the HDMI to RGB component
  component dvi2rgb_0 is
    port (
      tmds_clk_p    : in std_logic;
      tmds_clk_n    : in std_logic;
      tmds_data_p   : in std_logic_vector(2 downto 0);
      tmds_data_n   : in std_logic_vector(2 downto 0);
      refclk        : in std_logic;
      arst          : in std_logic;
      vid_pdata     : out std_logic_vector(23 downto 0);
      vid_pvde      : out std_logic;
      vid_phsync    : out std_logic;
      vid_pvsync    : out std_logic;
      pixelclk      : out std_logic;
      apixelclklckd : out std_logic;
      plocked       : out std_logic;
      sda_i         : in std_logic;
      sda_o         : out std_logic;
      sda_t         : out std_logic;
      scl_i         : in std_logic;
      scl_o         : out std_logic;
      scl_t         : out std_logic;
      prst          : in std_logic
    );
  end component dvi2rgb_0;

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

  --! Clocks and reset
  signal clk_50     : std_logic := '0';
  signal clk_200    : std_logic := '0';
  --! Alias the reset button
  alias rst is btn;
  --! Alias the system clock
  alias clk_125 is sysclk;

  --! SPI bus
  signal sda        : std_logic := '0';
  signal scl        : std_logic := '0';
  signal cs         : std_logic := '0';

  --! Sequencer signals
  signal disp_rst_n : std_logic := '0';
  signal done       : std_logic := '0';

  --! RGB signals
  signal pclk       : std_logic := '0'; --! Pixel clock
  signal de         : std_logic := '0'; --! Data enable
  signal vs         : std_logic := '0'; --! Vertical sync
  signal hs         : std_logic := '0'; --! Horizontal sync
  signal data       : std_logic_vector(23 downto 0) := (others => '0');

  --! HDMI specific signals
  signal sda_i      : std_logic;
  signal sda_o      : std_logic;
  signal sda_t      : std_logic;
  signal scl_i      : std_logic;
  signal scl_o      : std_logic;
  signal scl_t      : std_logic;
  signal hdmi_data  : std_logic_vector(23 downto 0) := (others => '0');

begin

  --! Map the PMOD connectors to the correct pins
  --! PMOD JB
  jb(0) <= data(16);
  jb(1) <= data(14);
  jb(2) <= data(12);
  jb(3) <= data(17);
  jb(4) <= data(15);
  jb(5) <= data(13);

  --! PMOD JC
  jc(0) <= data(10);
  jc(1) <= data(8);
  jc(2) <= data(6);
  jc(3) <= data(11);
  jc(4) <= data(9);
  jc(5) <= data(7);

  --! PMOD JD
  jd(0) <= data(4);
  jd(1) <= data(2);
  jd(2) <= data(0);
  jd(3) <= data(5);
  jd(4) <= data(3);
  jd(5) <= data(1);

  --! PMOD JE
  je(0) <= vs;
  je(1) <= pclk;
  je(2) <= scl;
  je(3) <= disp_rst_n;
  je(4) <= hs;
  je(5) <= de;
  je(6) <= cs;
  je(7) <= sda;

  --! Map the sequencer module
  sequencer_inst : sequencer
    port map (
      clk             => clk_50,
      rst             => rst,
      settings        => c_spi_settings,
      spi_sda         => sda,
      spi_scl         => scl,
      spi_cs          => cs,
      spi_dc          => open,
      disp_rst_n      => disp_rst_n,
      done            => done,
      sequencer_error => open
    );

  --! Map the heart module
  heart_inst : heart_rider
    generic map (
      clk_div => 23,
      led_cnt => 4
    )
    port map (
      clk     => clk_125,
      rst     => rst,
      led     => led
    );

  --! Map the pll module
  pll_inst : pll_200
    port map (
      clk_out => clk_200,
      reset   => '0',
      clk_in  => clk_125
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

  --! Map the hdmi to rgb module
  hdmi_inst : dvi2rgb_0
    port map (
      tmds_clk_p    => hdmi_rx_clk_p,
      tmds_clk_n    => hdmi_rx_clk_n,
      tmds_data_p   => hdmi_rx_p,
      tmds_data_n   => hdmi_rx_n,
      refclk        => clk_200,
      arst          => rst,
      vid_pdata     => hdmi_data,
      vid_pvde      => de,
      vid_phsync    => hs,
      vid_pvsync    => vs,
      pixelclk      => pclk,
      apixelclklckd => open,
      plocked       => open,
      sda_i         => sda_i,
      sda_o         => sda_o,
      sda_t         => sda_t,
      scl_i         => scl_i,
      scl_o         => scl_o,
      scl_t         => scl_t,
      prst          => '0'
    );

  --! Use the Xilinx tri-state buffer for the I2C signals
  sda_iobuf_inst: iobuf
    generic map(
      drive      => 12,
      iostandard => "DEFAULT",
      slew       => "SLOW"
    )
    port map(
      o  => sda_i,  -- Buffer output
      io => hdmi_rx_sda, -- Buffer inout port(connect directly to top-level port)
      i  => sda_o,  -- Bufferinput
      t  => sda_t   -- 3-state enable input,high=input,low=output
    ); 

  --! Use the Xilinx tri-state buffer for the I2C signals
  scl_iobuf_inst: iobuf
    generic map(
      drive      => 12,
      iostandard => "DEFAULT",
      slew       => "SLOW"
    )
    port map(
      o  => scl_i,  -- Buffer output
      io => hdmi_rx_scl, -- Buffer inout port(connect directly to top-level port)
      i  => scl_o,  -- Buffer input
      t  => scl_t   -- 3-state enable input,high=input,low=output
    );

  --! Set the HPD signal to high to enable the HDMI receiver
  hdmi_rx_hpd <= '1';

  --! Rearrange the bits to match the rgb format
  --! Unused bits are set to 0
  data(23 downto 18) <= (others => '0');
  --! Red component (6 bits)
  data(17 downto 12) <= hdmi_data(23 downto 18);
  --! Green component (6 bits)
  data(11 downto 6) <= hdmi_data(7 downto 2);
  --! Blue component (6 bits)
  data(5 downto 0) <= hdmi_data(15 downto 10);

end architecture rtl;