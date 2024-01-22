library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ddc is
  port (
    clk : in std_logic;
    rst : in std_logic;
    sda : inout std_logic;
    scl : in std_logic
  );
end entity ddc;

architecture RTL of ddc is

  -- add the edid_rom
  component edid_rom is
    port (
      clk : in std_logic;
      rst : in std_logic;
      addr : in std_logic_vector(6 downto 0); -- 128 bytes
      data : out std_logic_vector(7 downto 0) -- 8 bits
    );
  end component edid_rom;

  -- set the slave address
  constant slave_addr_w : std_logic_vector(7 downto 0) := x"a0";
  constant slave_addr_r : std_logic_vector(7 downto 0) := x"a1";

  -- setup the statemachine
  type state is (
    idle_state,
    start_state,
    poll_device_addr_w_state,
    addr_w_ack_state,
    poll_device_reg_state,
    reg_ack_state,
    poll_device_addr_r_state,
    addr_r_ack_state,
    fetch_data_state,
    wait_for_data_state,
    shift_out_state,
    shift_decrement_state,
    shift_out_ack_state,
    increment_ptr_state
  );
  signal i2c_state : state := idle_state;

  -- signals for handling the rom
  signal bit_cnt  : integer range 0 to 8 := 0;
  signal addr_ptr : std_logic_vector(6 downto 0) := (others => '0');
  signal data_out : std_logic_vector(7 downto 0) := (others => '0');
  -- signal for receiving data
  signal data_in  : std_logic_vector(7 downto 0) := (others => '0');
  -- internal i2c signals
  signal sda_in   : std_logic := '0';
  signal sda_out  : std_logic := '0';
  signal response  : std_logic := '0';

begin

  -- create tri-state buffer for sda
  sda_in <= sda;
  sda <= sda_out when response = '1' else 'Z';

  -- instantiate the edid_rom
  edid_rom_inst : edid_rom
    port map (
      clk => clk,
      rst => rst,
      addr => addr_ptr,
      data => data_out
    );

  i2c_state_machine : process(clk, rst)
  begin
    if rst = '1' then
      i2c_state <= idle_state;
    elsif rising_edge(clk) then
      case i2c_state is
        when idle_state =>
          -- reset the bit counter
          bit_cnt <= 0;
          -- reset the address pointer
          addr_ptr <= (others => '0');
          -- reset the data in
          data_in <= (others => '0');

          -- i2c stats by pulling the sda line low
          if falling_edge(scl) then
            i2c_state <= start_state;
          end if;

        -- start state
        when start_state =>
          -- if scl goes low, the bus has started
          if falling_edge(scl) then
            i2c_state <= poll_device_addr_w_state;
          end if;

        -- i2c should now try to poll our address
        when poll_device_addr_w_state =>
          -- if we have received all 8 bits, check if it is our address
          if bit_cnt = 8 then
            if data_in = slave_addr_w then
              -- clear the bit counter
              bit_cnt <= 0;
              i2c_state <= addr_w_ack_state;
            else
              i2c_state <= idle_state;
            end if;
          -- if not, when scl goes high, shift in the data
          elsif rising_edge(scl) then
            data_in <= data_in(6 downto 0) & sda;
            bit_cnt <= bit_cnt + 1;
          end if;

        -- we now have to send an ack
        when addr_w_ack_state =>
          response <= '1';
          sda_out <= '0';
          -- if scl goes high, we have to send an ack
          if rising_edge(scl) then
            i2c_state <= poll_device_reg_state;
          end if;

        -- i2c should now try to poll our register
        when poll_device_reg_state =>
          if falling_edge(scl) then
            response <= '0';
          end if;
          -- i2c will now attempt to poll a register
          -- we dont really give a fuck about this value
          -- so simply count the required number of bits and we should be fine :clueless:
          if bit_cnt = 8 then
            i2c_state <= reg_ack_state;
          elsif rising_edge(scl) then
            bit_cnt <= bit_cnt + 1;
          end if;

        -- we have to again, send an ack
        when reg_ack_state =>
          response <= '1';
          sda_out <= '0';
          -- reset bit_cnt
          bit_cnt <= 0;
          -- if scl goes high, we have to send an ack
          if rising_edge(scl) then
            i2c_state <= poll_device_addr_r_state;
          end if;

        -- master should again send the address, but with read set
        when poll_device_addr_r_state =>
          if falling_edge(scl) then
            response <= '0';
          end if;
          -- if we have received all 8 bits, check if it is our address
          if bit_cnt = 8 then
            if data_in = slave_addr_r then
              -- clear the bit counter
              bit_cnt <= 0;
              i2c_state <= addr_r_ack_state;
            else
              i2c_state <= idle_state;
            end if;
          -- if not, when scl goes high, shift in the data
          elsif rising_edge(scl) then
            data_in <= data_in(6 downto 0) & sda_out;
            bit_cnt <= bit_cnt + 1;
          end if;

        -- we now have to send an ack
        when addr_r_ack_state =>
          response <= '1';
          sda_out <= '0';
          -- if scl goes high, we have to send an ack
          if rising_edge(scl) then
            i2c_state <= fetch_data_state;
          end if;

        -- we now have to fetch the data from the rom
        -- basically a fancy wait state
        when fetch_data_state =>
          if falling_edge(scl) then
            response <= '0';
          end if;
          i2c_state <= wait_for_data_state;

        -- because its not instant, wait a clock cycle
        when wait_for_data_state =>
          -- set the counter
          bit_cnt <= 8;
          i2c_state <= shift_out_state;

        -- we now have to shift out the data
        when shift_out_state =>
          -- if scl goes high, we can move to the next bit
          if bit_cnt = 0 then
            i2c_state <= shift_out_ack_state;
          elsif rising_edge(scl) then
            i2c_state <= shift_decrement_state;
          else
            -- shift out the data
            sda_out <= data_out(bit_cnt - 1);
          end if;

        -- decrement the bit pointer
        when shift_decrement_state =>
          bit_cnt <= bit_cnt - 1;
          i2c_state <= shift_out_state;

        -- we now have to send an ack
        when shift_out_ack_state =>
          -- if we have shifted out all the data, we have to send a nack
          if addr_ptr = 127 then
            sda_out <= '1';
            
            if rising_edge(scl) then
              i2c_state <= idle_state;
            end if;
          -- we have not shifted out all the data, send an ack
          else
            sda_out <= '0';

            if rising_edge(scl) then
              i2c_state <= increment_ptr_state;
            end if;
          end if;

        -- increment the address pointer
        when increment_ptr_state =>
          addr_ptr <= addr_ptr + 1;
          i2c_state <= fetch_data_state;

        -- shouldnt ever happen (hopefully)
        when others =>
          i2c_state <= idle_state;
      end case;
    end if;
  end process i2c_state_machine;

end architecture RTL;