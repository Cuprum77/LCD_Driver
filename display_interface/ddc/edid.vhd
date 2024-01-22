library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Contains the EDID data for the display
-- 128 bytes of data

entity edid_rom is
  port (
    clk : in std_logic;
    rst : in std_logic;
    addr : in std_logic_vector(6 downto 0); -- 128 bytes
    data : out std_logic_vector(7 downto 0) -- 8 bits
  );
end entity edid_rom;

architecture RTL of edid_rom is

  -- create an array
  type edid_rom_type is array (0 to 127) of std_logic_vector(7 downto 0);

  -- fill the array
  constant edid_rom_data : edid_rom_type := (
    x"00", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", 
    x"0e", x"b0", x"69", x"00", x"00", x"00", x"00", x"00", 
    x"ff", x"22", x"01", x"03", x"80", x"04", x"09", x"00", 
    x"0a", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"01", x"00", 
    x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", 
    x"01", x"00", x"01", x"00", x"01", x"00", x"e2", x"04", 
    x"e0", x"02", x"10", x"c0", x"02", x"30", x"02", x"02", 
    x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"1e", 
    x"00", x"00", x"00", x"10", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"10", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"ed"
  );

begin

  rom_proc : process(clk, rst)
  begin
    if rst = '1' then
      data <= (others => '0');
    elsif rising_edge(clk) then
      data <= edid_rom_data(to_integer(unsigned(addr)));
    end if;
  end process rom_proc;

end architecture RTL;