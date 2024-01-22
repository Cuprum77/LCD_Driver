library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- RGB clock generator
-- 
-- Given that we work with a 100 MHz clock signal
-- We can generate a 25 MHz clock for the pixels
-- this should be more than enough for a 60 Hz refresh rate
-- while complying with the specs that limit the pixel clock
-- to a mere 30 MHz
--
-- this is adapted from an older project of mine
-- so i might not fully comprehend what is going on

entity rgb_clk is
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
    -- hdmi sync input
    hdmi_de     : in std_logic;
    hdmi_vs     : in std_logic;
    hdmi_hs     : in std_logic;
    -- data output
    rgb_pclk    : out std_logic := '1';
    rgb_de      : out std_logic;
    rgb_vs      : out std_logic;
    rgb_hs      : out std_logic;
    -- helper signals
    rgb_hcnt    : out std_logic_vector(11 downto 0);
    rgb_vcnt    : out std_logic_vector(11 downto 0)
  );
end entity;

architecture RTL of rgb_clk is

  signal clk_div      : std_logic_vector(3 downto 0) := (others => '0');
  signal hdmi_hs_cnt  : unsigned(11 downto 0) := (others => '0');
  signal h_cnt_int    : unsigned(11 downto 0) := (others => '0');
  signal v_cnt_int    : unsigned(11 downto 0) := (others => '0');
  signal line_done    : std_logic;
  signal hblank_n     : std_logic;
  signal vblank_n     : std_logic;
  signal px_clk       : std_logic;

begin

  -- count the horizontal sync hdmi signal
  hdmi_sync_process : process(px_clk, hdmi_hs)
  begin
    if rst = '1' or rising_edge(hdmi_hs) then
      hdmi_hs_cnt <= (others => '0');
    elsif rising_edge(px_clk) then
      hdmi_hs_cnt <= hdmi_hs_cnt + 1;
    end if;
  end process;

  -- generate the pixel clock by dividing the main clock by 4
  clk_divider : process(clk)
  begin
    if rst = '1' then
      clk_div <= (others => '0');
    elsif rising_edge(clk) then
      clk_div <= clk_div + 1;
    end if;
  end process;
  -- px_clk <= clk_div(3);
  px_clk <= clk;

  -- Create the horizontal signals
  hsync_process : process(px_clk, rst)
    variable h_area_var    : unsigned(11 downto 0) := 
      to_unsigned(h_area, h_cnt_int'length);
    variable h_sync_on     : unsigned(11 downto 0) := 
      to_unsigned((h_area + h_front_porch), h_cnt_int'length);
    variable h_sync_off    : unsigned(11 downto 0) := 
      to_unsigned((h_area + h_front_porch + h_sync), h_cnt_int'length);
    variable h_whole_frame : unsigned(11 downto 0) := 
      to_unsigned((h_area + h_front_porch + h_sync + h_back_porch), h_cnt_int'length);
  begin
    if rst = '1' then
      h_cnt_int <= (others => '0');
      hblank_n <= '1';
      rgb_hs <= '1';
      line_done <= '0';
      rgb_hcnt <= (others => '0');

    elsif rising_edge(px_clk) then
      if hdmi_hs_cnt <= h_whole_frame then
        h_cnt_int <= h_cnt_int + 1;
      
        line_done <= '0';

        if h_cnt_int <= h_area_var then
          rgb_hcnt <= std_logic_vector(h_cnt_int);
        end if;

        if h_cnt_int = "0000000000" then
          hblank_n <= '1';
        elsif h_cnt_int = h_area_var then
          hblank_n <= '0';
        elsif h_cnt_int = h_sync_on then
          rgb_hs <= '0';
        elsif h_cnt_int = h_sync_off then
          rgb_hs <= '1';
        elsif h_cnt_int >= h_whole_frame then
          h_cnt_int <= (others => '0');
          line_done <= '1';
        end if;
      end if;
    end if;
  end process;

  -- Create the vertical signals
  vsync_process : process(line_done)
    variable v_area_var    : unsigned(11 downto 0) := 
      to_unsigned(v_area, v_cnt_int'length);
    variable v_sync_on     : unsigned(11 downto 0) := 
      to_unsigned((v_area + v_front_porch), v_cnt_int'length);
    variable v_sync_off    : unsigned(11 downto 0) := 
      to_unsigned((v_area + v_front_porch + v_sync), v_cnt_int'length);
    variable v_whole_frame : unsigned(11 downto 0) := 
      to_unsigned((v_area + v_front_porch + v_sync + v_back_porch), v_cnt_int'length);
  begin
    if v_cnt_int < v_area_var then
      rgb_vcnt <= std_logic_vector(v_cnt_int);
    end if;

    if rst = '1' then
      v_cnt_int <= (others => '0');
      vblank_n <= '1';
      rgb_vs <= '1';
      rgb_vcnt <= (others => '0');

    elsif rising_edge(line_done) then
      v_cnt_int <= v_cnt_int + 1;
      
      if v_cnt_int = "0000000000" then
        vblank_n <= '1';
      elsif v_cnt_int = v_area_var then
        vblank_n <= '0';
      elsif v_cnt_int = v_sync_on then
        rgb_vs <= '0';
      elsif v_cnt_int = v_sync_off then
        rgb_vs <= '1';
      elsif v_cnt_int >= v_whole_frame then
        v_cnt_int <= (others => '0');
      end if;
    end if;
  end process;

  -- generate the data enable signal by combining the horizontal and vertical blanking signals
  rgb_de <= '1' when (hblank_n = '1' and vblank_n = '1') else '0';
  rgb_pclk <= px_clk;

end architecture;