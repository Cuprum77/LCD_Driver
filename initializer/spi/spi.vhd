library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- spi
--
-- This is a modified version of the SPI interface
-- The SPI interface is modified to work with the display
-- This is based off a clock of 100 MHz

entity spi is
  generic(
    alternative_dc : boolean := false -- If the SPI DC is the first bit instead of a dedicated pin
  );
  port(
    -- Clock and reset
    clk       : in std_logic; -- 100 MHz
    rst       : in std_logic; -- Reset, active HIGH
    -- SPI ports
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
end entity;

architecture RTL of spi is
  type state_machine is (
    idle_state,
    start_state,
    shiftout_state,
    clk1_state,
    stop_state,
    hold_state
  ); 

  signal spi_state : state_machine := idle_state;
    
  signal delay_cnt       	: std_logic_vector(1 downto 0) := (others => '0');
  signal delay_done_full 	: std_logic := '0';
  signal delay_done_half 	: std_logic := '0';
  signal delay_done      	: std_logic := '0';

  signal data_int : std_logic_vector(32 downto 0);
  signal bit_cnt  : integer range 0 to 32;
	
begin

  -- This process handles the delay counter
  -- This is essentially a glorified frequency divider, which gets reset when the delay is done
  delay_process : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or delay_done = '1' or spi_state = idle_state or spi_state = hold_state then
        delay_cnt <= (others => '0');
      else
        delay_cnt <= delay_cnt + 1;
      end if; 
    end if;
  end process;

  -- These are the delay signals, which gets squished into one
  -- Where the full delay is 2 cycles and half delay is 1 cycle
  -- Useful for setting the clock high and low with the appropriate delays
  delay_done_full <= '1' when delay_cnt = "10" else '0';
  delay_done_half <= '1' when delay_cnt = "01" else '0';
  delay_done <= delay_done_half when spi_state = clk1_state or spi_state = shiftout_state else delay_done_full;

  -- This is the bit counter
  -- It will set the number of bits to be shifted out and count down appropriately
  bit_cnt_process : process(clk)
  begin
    if rising_edge(clk)then
      if rst = '1' or spi_state = idle_state or spi_state = hold_state then
        case bit_width is
          when "001" => 
            if alternative_dc = true then
              bit_cnt <= 16;
            else
              bit_cnt <= 15;
            end if;
          when "010" => 
            if alternative_dc = true then
              bit_cnt <= 18;
            else
              bit_cnt <= 17;
            end if;
          when "011" => 
            if alternative_dc = true then
              bit_cnt <= 24;
            else
              bit_cnt <= 23;
            end if;
          when "100" => 
            if alternative_dc = true then
              bit_cnt <= 32;
            else
              bit_cnt <= 31;
            end if;
          when others => 
            if alternative_dc = true then
              bit_cnt <= 8;
            else
              bit_cnt <= 7;
            end if;
        end case;
      elsif spi_state = clk1_state and delay_done = '1' and bit_cnt > 0 then
        bit_cnt <= bit_cnt - 1;
      end if;
    end if;
  end process;

  -- set the DATA/command or d/c pin
  spi_dc <= set_dc when rst = '0' else '0';

  -- This is the main state machine
  -- It should be able to shift out however many bits are needed
  -- With the appropriate delays and clock signals
  interface_process : process(clk)
  begin
  if rising_edge(clk) then
    if rst = '1' then
      spi_state <= idle_state;
    else
      case spi_state is
        -- waiting for a command
        when idle_state =>
          spi_sda <= '0';
          spi_scl <= '0';
          spi_cs <= '1';
          done <= '1';
          
          if SEND = '1' then
            spi_state <= start_state;
          else
            spi_state <= idle_state;
          end if;

        -- start the transmission
        when start_state =>
          spi_scl <= '0';
          spi_cs <= '0';
          done <= '0';
          -- copy the input data to our internal register
          data_int(31 downto 0) <= data;
          
          -- if we are to set the DC as part of the SPI, do so here
          if alternative_dc = true then
            data_int(bit_cnt) <= set_dc;
          end if;
          
          if delay_done = '1' then
            spi_state <= shiftout_state;
          end if;

        -- shift out the DATA and set the clock low
        when shiftout_state =>
          spi_sda <= data_int(bit_cnt);
          spi_scl <= '0';
          
          if delay_done = '1' then
            spi_state <= clk1_state;
          end if;

        -- set the clock high
        when clk1_state =>
          spi_scl <= '1';
				
          if delay_done = '1' then
            if bit_cnt = 0 then
              spi_state <= stop_state;
            else
              spi_state <= shiftout_state;
            end if;
          end if;

        -- stop the transmission
        when stop_state =>
          spi_sda <= '0';
          spi_scl <= '0';
       
          if delay_done = '1' then
            spi_state <= hold_state;
          end if;

        -- hold the transmission
        when hold_state =>
          spi_cs <= '1'; 
          done <= '1';

          if send = '1' then
            spi_state <= start_state;
          else
            spi_state <= idle_state;
          end if;      
      end case;
    end if;
  end if;
end process;

end architecture;