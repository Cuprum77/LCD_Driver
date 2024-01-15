library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
    -- inputs
    sysclk  : in std_logic; -- 125 MHz external clock
    btn     : in std_logic_vector (3 downto 0);
    -- outputs
    jb      : out std_logic_vector (7 downto 0);
    jc      : out std_logic_vector (7 downto 0);
    jd      : out std_logic_vector (7 downto 0);
    je      : out std_logic_vector (7 downto 0);
    led     : out std_logic_vector (3 downto 0)
  );
end entity;

architecture RTL of top is

  component Sequencer is
    port(
      -- Clock and reset
      clk             : in std_logic;  -- 100 MHz clock
      rst             : in std_logic;  -- Reset
      -- SPI ports
      spi_sda         : out std_logic; -- SPI SDA (Data)
      spi_scl         : out std_logic; -- SPI SCL (Clock)
      spi_cs          : out std_logic; -- SPI CS (Chip Select)
      spi_dc          : out std_logic; -- SPI DC (Data/Command)
      -- Sequencer outputs
      done            : out std_logic; -- HIGH when done
      sequencer_error : out std_logic  -- HIGH if error
    );
  end component;

  component rgb is
    generic(
      pixel_format : std_logic_vector(2 downto 0) := "010"
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
      sysclk  : in std_logic;
      LED     : out std_logic_vector(3 downto 0)
    );
  end component;

  signal clk    : std_logic;
  signal rst    : std_logic;
  signal rst_n  : std_logic;

  -- spi bus
  signal sda    : std_logic;
  signal scl    : std_logic;
  signal cs     : std_logic;

  -- sequencer
  signal done   : std_logic;
  signal s_err  : std_logic;

  -- rgb
  signal r      : std_logic_vector(7 downto 0);
  signal g      : std_logic_vector(7 downto 0);
  signal b      : std_logic_vector(7 downto 0);
  signal pclk   : std_logic;
  signal de     : std_logic;
  signal vs     : std_logic;
  signal hs     : std_logic;
  signal data   : std_logic_vector(23 downto 0);

begin

  -- map the clock and reset (remove later)
  clk <= sysclk;
  rst <= btn(0);
  rst_n <= not rst;

  -- solid white color for now
  r <= (others => '1');
  g <= (others => '1');
  b <= (others => '1');

  -- map the PMOD connectors to the correct pins
  -- PMOD JB
  jb(0) <= data(16);
  jb(1) <= data(14);
  jb(2) <= data(12);
  jb(4) <= data(17);
  jb(5) <= data(15);
  jb(6) <= data(13);

  -- PMOD JC
  jc(0) <= data(10);
  jc(1) <= data(8);
  jc(2) <= data(6);
  jc(4) <= data(11);
  jc(5) <= data(9);
  jc(6) <= data(7);

  -- PMOD JD
  jd(0) <= data(4);
  jd(1) <= data(2);
  jd(2) <= data(0);
  jd(4) <= data(5);
  jd(5) <= data(3);
  jd(6) <= data(1);

  -- PMOD JE
  je(0) <= vs;
  je(1) <= pclk;
  je(2) <= scl;
  je(3) <= rst_n;
  je(4) <= hs;
  je(5) <= de;
  je(6) <= cs;
  je(7) <= sda;

  -- map the sequencer module
  sequencer_comp : sequencer
    port map (
      clk             => clk,
      rst             => rst,
      spi_sda         => sda,
      spi_scl         => scl,
      spi_cs          => cs,
      spi_dc          => open,
      done            => done,
      sequencer_error => s_err
    );

  -- map the rgb module
  rgb_comp : rgb
    port map (
      clk       => clk,
      rst       => rst,
      enable    => done,
      r         => r,
      g         => g,
      b         => b,
      x         => open,
      y         => open,
      rgb_pclk  => pclk,
      rgb_de    => de,
      rgb_vs    => vs,
      rgb_hs    => hs,
      rgb_data  => data 
    );

  -- map the heart module
  heart_comp : heart
    port map (
      sysclk  => sysclk,
      LED     => led
    );

end architecture;