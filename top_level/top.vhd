library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
-- Xilinx specific libraries
library UNISIM;
use UNISIM.VComponents.all;

-- Note, the 100 MHz PLL has been down-clocked to 50 MHz to cope with the PMOD output impedance!

entity top is
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
end entity;

architecture RTL of top is

  component sequencer is
    generic(
      -- Allow us to disable the resetter for testing and debugging
      enable_resetter : boolean := true;
      invert_dc       : boolean := false -- If the SPI DC is inverted
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

  component rgb is
    generic(
      pixel_format : std_logic_vector(2 downto 0) := "010";
      -- horizontal timings
      h_area        : integer := 400;
      h_front_porch : integer := 2;
      h_sync        : integer := 2;
      h_back_porch  : integer := 2;
      -- vertical timings
      v_area        : integer := 960;
      v_front_porch : integer := 2;
      v_sync        : integer := 2;
      v_back_porch  : integer := 2
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

  component heart is
    port(
      clk : in std_logic;
      rst : in std_logic;
      LED : out std_logic_vector(3 downto 0)
    );
  end component;

  -- xilinx pll
  component pll_200 is
    port
    (-- Clock in ports
      -- Clock out ports
      clk_out : out std_logic;
      -- Status and control signals
      reset   : in std_logic;
      clk_in  : in std_logic
    );
  end component;

  -- hdmi to rgb
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
  end component;

  signal clk        : std_logic := '0';
  signal clk_200    : std_logic := '0';
  signal rst        : std_logic := '0';
  signal clk_div    : std_logic_vector(2 downto 0) := (others => '0');

  -- spi bus
  signal sda        : std_logic := '0';
  signal scl        : std_logic := '0';
  signal cs         : std_logic := '0';

  -- sequencer
  signal disp_rst_n : std_logic := '0';
  signal done       : std_logic := '0';
  signal s_err      : std_logic := '0';

  -- rgb
  signal r          : std_logic_vector(7 downto 0) := (others => '0');
  signal g          : std_logic_vector(7 downto 0) := (others => '0');
  signal b          : std_logic_vector(7 downto 0) := (others => '0');
  signal pclk       : std_logic := '0';
  signal de         : std_logic := '0';
  signal vs         : std_logic := '0';
  signal hs         : std_logic := '0';
  signal data       : std_logic_vector(23 downto 0) := (others => '0');
  signal x          : std_logic_vector(11 downto 0) := (others => '0');
  signal y          : std_logic_vector(11 downto 0) := (others => '0');

  -- hdmi
  signal sda_i      : std_logic;
  signal sda_o      : std_logic;
  signal sda_t      : std_logic;
  signal scl_i      : std_logic;
  signal scl_o      : std_logic;
  signal scl_t      : std_logic;
  signal hdmi_vde   : std_logic := '0';
  signal hdmi_hsync : std_logic := '0';
  signal hdmi_vsync : std_logic := '0';
  signal hdmi_data  : std_logic_vector(23 downto 0) := (others => '0');

begin

  -- map the reset button
  rst <= btn;

  -- map the PMOD connectors to the correct pins
  -- PMOD JB
  jb(0) <= data(16);
  jb(1) <= data(14);
  jb(2) <= data(12);
  jb(3) <= data(17);
  jb(4) <= data(15);
  jb(5) <= data(13);

  -- PMOD JC
  jc(0) <= data(10);
  jc(1) <= data(8);
  jc(2) <= data(6);
  jc(3) <= data(11);
  jc(4) <= data(9);
  jc(5) <= data(7);

  -- PMOD JD
  jd(0) <= data(4);
  jd(1) <= data(2);
  jd(2) <= data(0);
  jd(3) <= data(5);
  jd(4) <= data(3);
  jd(5) <= data(1);

  -- PMOD JE
  --je(0) <= vs;
  je(0) <= hdmi_vsync;
  je(1) <= pclk;
  je(2) <= scl;
  je(3) <= disp_rst_n;
  --je(4) <= hs;
  je(4) <= hdmi_hsync;
  --je(5) <= de;
  je(5) <= hdmi_vde;
  je(6) <= cs;
  je(7) <= sda;

  -- map the sequencer module
  sequencer_inst : sequencer
    generic map (
      enable_resetter => true,
      invert_dc       => true
    )
    port map (
      clk             => clk,
      rst             => rst,
      spi_sda         => sda,
      spi_scl         => scl,
      spi_cs          => cs,
      spi_dc          => open,
      disp_rst_n      => disp_rst_n,
      done            => done,
      sequencer_error => s_err
    );

  -- map the rgb module
  -- rgb_inst : rgb
  --   generic map (
  --     pixel_format  => "010",
  --     h_area        => 480,
  --     h_front_porch => 2,
  --     h_sync        => 2,
  --     h_back_porch  => 2,
  --     v_area        => 960,
  --     v_front_porch => 2,
  --     v_sync        => 2,
  --     v_back_porch  => 2
  --   )
  --   port map (
  --     clk           => clk,
  --     rst           => rst,
  --     enable        => done,
  --     r             => r,
  --     g             => g,
  --     b             => b,
  --     x             => x,
  --     y             => y,
  --     rgb_pclk      => pclk,
  --     rgb_de        => de,
  --     rgb_vs        => vs,
  --     rgb_hs        => hs,
  --     rgb_data      => data 
  --   );

  -- map the heart module
  heart_inst : heart
    port map (
      clk => sysclk,
      rst => rst,
      led => led
    );

  -- map the pll module
  pll_inst : pll_200
    port map (
      clk_out => clk_200,
      reset   => '0',
      clk_in  => sysclk
    );

  -- clk divider
  clk_div_proc : process(clk_200)
  begin
    if rising_edge(clk_200) then
      clk_div <= clk_div + 1;
    end if;
  end process;

  -- effectively divide the 200 MHz clock by 4 to get 50 MHz
  clk <= clk_div(2);

  -- map the hdmi to rgb module
  hdmi_inst : dvi2rgb_0
    port map (
      tmds_clk_p    => hdmi_rx_clk_p,
      tmds_clk_n    => hdmi_rx_clk_n,
      tmds_data_p   => hdmi_rx_p,
      tmds_data_n   => hdmi_rx_n,
      refclk        => clk_200,
      arst          => rst,
      vid_pdata     => data,
      vid_pvde      => de,
      vid_phsync    => hs,
      vid_pvsync    => vs,
      pixelclk      => open,
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

  hdmi_rx_hpd <= '1';

  -- map the rgb inputs
  --r <= x"00";
  --g <= x"f4";
  --b <= x"ff";
  r <= hdmi_data(7 downto 0);
  g <= hdmi_data(15 downto 8);
  b <= hdmi_data(23 downto 16);

end architecture;