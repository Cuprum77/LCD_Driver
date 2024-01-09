library ieee;
use ieee.std_logic_1164.all;

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
  signal sequencer_error  : std_logic := '0';

  -- adding the component declaration
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
      -- Error output
      sequencer_error : out std_logic  -- HIGH if error
    );
  end component;

begin

  DUUT : Sequencer
    port map(
      clk             => clk,
      rst             => rst,
      spi_sda         => spi_sda,
      spi_scl         => spi_scl,
      spi_cs          => spi_cs,
      sequencer_error => sequencer_error
    );

  -- init process, where code that only runs once goes
  init_process : process
  begin
    rst <= '1';
    wait for 1 ns;
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
  wait;
  end process always_process;

end architecture;
