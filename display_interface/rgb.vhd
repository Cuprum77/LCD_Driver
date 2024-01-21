library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- rgb to vga converter
--
-- unlike the sequencer, this module only supports up to 24 bits of color data

entity rgb is
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
end entity;

architecture RTL of rgb is

  component rgb_clk is
    generic(
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
      -- data output
      rgb_pclk    : out std_logic := '1';
      rgb_de      : out std_logic;
      rgb_vs      : out std_logic;
      rgb_hs      : out std_logic;
      -- helper signals
      rgb_hcnt    : out std_logic_vector(11 downto 0);
      rgb_vcnt    : out std_logic_vector(11 downto 0)
    );
  end component;

  signal data_internal      : std_logic_vector(23 downto 0) := (others => '0');
  signal reset_internal     : std_logic := '0';
  signal rgb_de_internal    : std_logic := '0';

begin

  -- reset the internal buffer when the enable signal is low
  reset_internal <= '1' when enable = '0' or rst = '1' else '0';

  -- hook up the clock generator
  pixel_clk_gen : rgb_clk
    generic map (
      h_area        => h_area,
      h_front_porch => h_front_porch,
      h_sync        => h_sync,
      h_back_porch  => h_back_porch,
      v_area        => v_area,
      v_front_porch => v_front_porch,
      v_sync        => v_sync,
      v_back_porch  => v_back_porch
    )
    port map (
      clk         => clk,
      rst         => reset_internal,
      rgb_pclk    => rgb_pclk,
      rgb_de      => rgb_de_internal,
      rgb_vs      => rgb_vs,
      rgb_hs      => rgb_hs,
      rgb_hcnt    => x,
      rgb_vcnt    => y
    );

  -- pixel_format decides how many bits are used for each color
  -- x001: 16 bits total RGB565
  -- x010: 18 bits total RGB666
  -- x011: 24 bits total RGB888
  -- others: 16 bits total RGB565

  -- move the data to the internal buffer
  buffer_input : process(clk)
  begin
    if rising_edge(clk) then
      if reset_internal = '1' then
        data_internal <= (others => '0');
      else
        case(pixel_format) is
          -- 18 bits
          when "010" =>
            data_internal(23 downto 18) <= (others => '0');
            data_internal(17 downto 12) <= r(7 downto 2);
            data_internal(11 downto 6)  <= g(7 downto 2);
            data_internal(5 downto 0)   <= b(7 downto 2);

          -- 24 bits
          when "011" =>
            data_internal(23 downto 16) <= r;
            data_internal(15 downto 8)  <= g;
            data_internal(7 downto 0)   <= b;

          -- 16 bits
          when others =>
            data_internal(23 downto 16) <= (others => '0');
            data_internal(15 downto 11) <= r(7 downto 3);
            data_internal(10 downto 5)  <= g(7 downto 2);
            data_internal(4 downto 0)   <= b(7 downto 3);
        end case;
      end if;
    end if;
  end process;

  -- hook up the data output
  rgb_data <= data_internal when rgb_de_internal = '1' else (others => '0');
  rgb_de <= rgb_de_internal;

end architecture;