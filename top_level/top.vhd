library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Note, the 100 MHz PLL has been down-clocked to 50 MHz to cope with the PMOD output impedance!

entity top is
  port (
    -- inputs
    sysclk  : in std_logic; -- 125 MHz external clock
    btn     : in std_logic;
    -- outputs
    jb      : out std_logic_vector (5 downto 0);
    jc      : out std_logic_vector (5 downto 0);
    jd      : out std_logic_vector (5 downto 0);
    je      : out std_logic_vector (7 downto 0);
    led     : out std_logic_vector (3 downto 0)
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
  component PLL_100M is
    port
    (-- Clock in ports
      -- Clock out ports
      clk_out : out std_logic;
      -- Status and control signals
      reset   : in std_logic;
      clk_in  : in std_logic
    );
  end component;

  signal clk        : std_logic := '0';
  signal rst        : std_logic := '0';

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

begin

  -- map the reset button
  rst <= btn;

  checkerboard_proc : process(clk)
  begin
    if rising_edge(clk) then
      if x(4) = '0' and y(4) = '0' then
        r <= (others => '0');
        g <= (others => '0');
        b <= (others => '0');
      else
        r <= (others => '1');
        g <= (others => '1');
        b <= (others => '1');
      end if;
    end if;
  end process;

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
  je(0) <= vs;
  je(1) <= pclk;
  je(2) <= scl;
  je(3) <= disp_rst_n;
  je(4) <= hs;
  je(5) <= de;
  je(6) <= cs;
  je(7) <= sda;

  -- map the sequencer module
  sequencer_comp : sequencer
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
  rgb_comp : rgb
    generic map (
      pixel_format  => "010",
      h_area        => 480,
      h_front_porch => 2,
      h_sync        => 2,
      h_back_porch  => 2,
      v_area        => 960,
      v_front_porch => 2,
      v_sync        => 2,
      v_back_porch  => 2
    )
    port map (
      clk           => clk,
      rst           => rst,
      enable        => done,
      r             => r,
      g             => g,
      b             => b,
      x             => x,
      y             => y,
      rgb_pclk      => pclk,
      rgb_de        => de,
      rgb_vs        => vs,
      rgb_hs        => hs,
      rgb_data      => data 
    );

  -- map the heart module
  heart_comp : heart
    port map (
      clk => sysclk,
      rst => rst,
      led => led
    );

  -- map the pll module
  pll_comp : PLL_100M
    port map (
      clk_out => clk,
      reset   => '0',
      clk_in  => sysclk
    );

end architecture;