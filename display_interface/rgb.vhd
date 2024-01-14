library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgb is
  generic(
    pixel_format : integer := 0
  );
  port(
    -- clock and reset
    clk     : in std_logic;
    rst     : in std_logic;
    enable  : in std_logic;
    -- pixel data
    r       : in std_logic_vector(7 downto 0);
    g       : in std_logic_vector(7 downto 0);
    b       : in std_logic_vector(7 downto 0);
    -- data output
    data    : out std_logic_vector(23 downto 0);
  );
end entity rgb;