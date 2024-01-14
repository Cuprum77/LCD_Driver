library ieee;
use ieee.std_logic_1164.all;

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

begin

  -- set up the component
  DUUT : SPIDriver
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

  -- init process, where code that only runs once goes
  init_process : process
  begin
    rst <= '1';
    wait for 10 ns;
    rst <= '0';
  wait;
  end process init_process;

  -- clock process, generates the clock signal
  clk_process : process
  begin
    clk <= '0';
    loop 
      wait for clk_period/2;
      clk <= not clk;
    end loop;
  wait;
  end process clk_process;

  -- always process, where we generate our test signals
  always_process : process
  begin
    wait for 15 ns; -- wait for the init process to finish
    bit_width <= "100"; -- 8 bit
    data <= x"aaaaaaaa"; -- 10101010
    send <= '1';
    wait for 5 ns; -- give the driver a clock cycle
    send <= '0';
  wait;
  end process always_process;

end architecture;