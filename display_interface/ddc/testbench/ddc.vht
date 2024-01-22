library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;
use uvvm_util.spi_bfm_pkg.all;

entity ddc_tb is
end ddc_tb;

architecture rtl of ddc_tb is
  -- constants
  constant clk_period : time := 10 ns; -- 100 MHz
  constant i2c_period : time := 10 us; -- 100 kHz
  constant i2c_addr_w : std_logic_vector(7 downto 0) := x"a0";
  constant i2c_addr_r : std_logic_vector(7 downto 0) := x"a1";

  -- signals
  signal clk      : std_logic := '0';
  signal rst      : std_logic := '0';
  signal sda      : std_logic := '0';
  signal scl      : std_logic := '0';
  signal clk_en   : boolean := false;
  signal data_rx  : std_logic_vector(7 downto 0) := (others => '0');

  -- procedure for generating a scl pulse
  procedure scl_pulse(
    signal scl  : out std_logic ) is
  begin
    scl <= '1';
    wait for i2c_period / 2;
    scl <= '0';
    wait for i2c_period / 2;
  end procedure scl_pulse;

  -- procedure for transmitting a byte over i2c
  procedure i2c_transmit(
    signal sda    : inout std_logic;
    signal scl    : out std_logic;
    constant addr : in std_logic_vector(7 downto 0);
    constant data : in std_logic_vector(7 downto 0) ) is 
  begin
    -- set the bus to the start condition
    sda <= '0';
    wait for i2c_period / 4;
    scl <= '0';
    wait for i2c_period / 4;

    -- send the address
    for i in 7 downto 0 loop
      sda <= addr(i);
      scl_pulse(scl => scl);
    end loop;

    -- release the sda
    sda <= 'Z';
    -- pulse the scl to get the ack
    scl_pulse(scl => scl);

    -- send the register
    for i in 7 downto 0 loop
      sda <= data(i);
      scl_pulse(scl => scl);
    end loop;

    -- pulse the scl to get the ack
    scl_pulse(scl => scl);
  end procedure i2c_transmit;

  -- procedure for receiving a byte over i2c
  procedure i2c_receive(
    signal sda          : inout std_logic;
    signal scl          : out std_logic;
    constant addr       : in std_logic_vector(7 downto 0);
    signal data         : out std_logic_vector(7 downto 0);
    constant addr_send  : in boolean; -- if you want to transmit the address
    constant final_byte : in boolean ) is
  begin
    -- send the address if needed
    if addr_send then
      -- set the bus to the start condition
      sda <= '0';
      wait for i2c_period / 4;
      scl <= '0';
      wait for i2c_period / 4;

      -- send the address
      for i in 7 downto 0 loop
        sda <= addr(i);
        scl_pulse(scl => scl);
      end loop;

      -- release the sda
      sda <= 'Z';
      -- pulse for ack
      scl_pulse(scl => scl);
    end if;

    -- receive the data
    for i in 7 downto 0 loop
      scl <= '1';
      wait for i2c_period / 4;
      data(i) <= sda;
      wait for i2c_period / 4;
      scl <= '0';
      wait for i2c_period / 2;
    end loop;
    -- transmit the ack
    sda <= '1' when final_byte else 'Z';
    scl_pulse(scl => scl);

    -- set the bus to its default state
    if final_byte then
      sda <= '1';
      scl <= '1';
    end if;

  end procedure i2c_receive;

  -- dut component declaration
  component ddc is
    port (
      clk : in std_logic;
      rst : in std_logic;
      sda : inout std_logic;
      scl : in std_logic
    );
  end component ddc;

  -- create an array
  type edid_rom_type is array (0 to 127) of std_logic_vector(7 downto 0);

  -- fill the array
  constant edid_rom_data : edid_rom_type := (
    x"00", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", 
    x"0e", x"b0", x"69", x"00", x"00", x"00", x"00", x"00", 
    x"ff", x"22", x"01", x"04", x"91", x"04", x"09", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"01", x"00", 
    x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", 
    x"01", x"00", x"01", x"00", x"01", x"00", x"e2", x"04", 
    x"e0", x"02", x"10", x"c0", x"02", x"30", x"02", x"02", 
    x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"10", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"10", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"03"
  );

begin

  -- map our dut
  dut : ddc
    port map (
      clk => clk,
      rst => rst,
      sda => sda,
      scl => scl
    );

  -- clock generation
  clock_generator(clk, clk_en, clk_period, "clock");

  main : process
  begin
    set_log_file_name("DDC_log.txt");
    set_alert_stop_limit(ERROR, 0); -- Do not stop
    report_global_ctrl(VOID); -- Show global control
    enable_log_msg(ALL_MESSAGES); -- Show all log messages

    log(ID_LOG_HDR, "Starting the simulation for the DDC module");

    -- set the scl and sda to their default values
    sda <= '1';
    scl <= '1';
    clk_en <= true; -- Start the clock generator

    -- Generate a reset signal
    wait for 1 * clk_period;
    gen_pulse(rst, clk_period, "Generating Reset");
    wait for 5 * clk_period;

    -- verify the default values
    check_value(sda, '1', "Checking sda");
    check_value(scl, '1', "Checking scl");

    -- start the i2c transmission
    scl <= '0';

    -- transmit the address
    i2c_transmit(
      sda => sda,
      scl => scl,
      addr => i2c_addr_w,
      data => data_rx
    );
    -- receive the data
    log(ID_LOG_HDR, "Checking instruction x" & to_hex_string(edid_rom_data(0)) & " (0/127)");
    i2c_receive(
      sda => sda, 
      scl => scl, 
      addr => i2c_addr_r, 
      data => data_rx, 
      addr_send => true, 
      final_byte => false
    );
    -- verify the data
    check_value(data_rx, edid_rom_data(0), "Checking data");
    -- reset the rx data
    data_rx <= (others => '0');
    -- loop over the rest of the data
    for i in 1 to 126 loop
      log(ID_LOG_HDR, "Checking instruction x" & to_hex_string(edid_rom_data(i)) & " (" & to_string(i) & "/127)");
      i2c_receive(
        sda => sda, 
        scl => scl, 
        addr => i2c_addr_r, 
        data => data_rx, 
        addr_send => false, 
        final_byte => false
      );
      check_value(data_rx, edid_rom_data(i), "Checking data");
      -- reset the rx data
      data_rx <= (others => '0');
    end loop;
    log(ID_LOG_HDR, "Checking instruction x" & to_hex_string(edid_rom_data(127)) & " (127/127)");
    i2c_receive(
      sda => sda,
      scl => scl,
      addr => i2c_addr_r,
      data => data_rx,
      addr_send => false,
      final_byte => true
    );
    check_value(data_rx, edid_rom_data(127), "Checking data");    
    -- reset the rx data
    data_rx <= (others => '0');

    log(ID_LOG_HDR, "Finished the simulation for the DDC module");
    -- Finish the simulation
    std.env.stop;
    wait;
  end process;

end architecture rtl;