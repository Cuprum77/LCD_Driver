library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity heart is
  port(
    sysclk  : in std_logic;
    rst     : in std_logic;
    LED     : out std_logic_vector(3 downto 0)
  );
end entity;

architecture RTL of heart is

  signal heart_cnt    : unsigned(22 downto 0);
  signal heart_led    : std_logic_vector(3 downto 0) := "1000";
  signal heart        : std_logic;

begin

  -- Heart Counter
  proc_heart_cnt : process(sysclk)
  begin
    if rst = '1' then
      heart_cnt <= (others => '0');
    elsif rising_edge(sysclk) then
      heart_cnt <= heart_cnt + 1;
    end if;
  end process proc_heart_cnt;

  -- Create FIFO read Mux
  heart <= heart_cnt(22);

  heart_rider : process(heart)
	begin
    if rst = '1' then
      heart_led <= "1000";
		elsif rising_edge(heart) then
      heart_led <= heart_led(2 downto 0) & heart_led(3);
		end if;
	end process;

  LED <= heart_led;

end architecture;
