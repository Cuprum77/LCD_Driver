--------------------------------------------------------------------------
--! @file spi.vhd
--! @brief SPI interface for the display
--! @details This is a modified version of the SPI interface with variable
--! bit width
--! @author Cuprum https://github.com/Cuprum77
--! @date 2024-01-27
--! @version 1.0
--------------------------------------------------------------------------

--! Use standard library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Use unsigned library for arithmetic on std_logic_vector
use ieee.std_logic_unsigned.all;

--! Work library
use work.driver_top_pkg.all;

entity spi is
  port(
    clk       : in  std_logic; --! Clock
    rst       : in  std_logic; --! Reset, synchronous
    settings  : in  t_spi_settings; --! Settings for the display
    spi_sda   : out std_logic; --! SPI SDA (Data)
    spi_scl   : out std_logic; --! SPI SCL (Clock)
    spi_cs    : out std_logic; --! SPI CS (Chip Select)
    spi_dc    : out std_logic; --! SPI DC (Data/Command)
    send      : in  std_logic; --! Send, active high
    set_dc    : in  std_logic; --! If the SPI DC is set or not, active high
    spi_done  : out std_logic; --! Signals completion of a transmission
    data      : in  std_logic_vector(31 downto 0); --! Data to be transmitted
    bit_width : in  std_logic_vector(2 downto 0)   --! Number of bits to send
  );
end entity spi;

--! @brief SPI architecture
--! @details The goal is to create a SPI signal that is readable by the screen
architecture rtl of spi is
  --! SPI state machine type declaration
  type state_machine is (
    idle_state,
    start_state,
    shiftout_state,
    clk_state,
    stop_state
  ); 
  signal spi_state : state_machine := idle_state;
    
  --! Internal counter signals for the various delays
  signal delay_cnt       	: std_logic_vector(2 downto 0) := (others => '0');
  signal delay_done_full 	: std_logic := '0';
  signal delay_done_half 	: std_logic := '0';
  signal delay_done      	: std_logic := '0';

  --! Internal data signal, its one bit longer than the data to be transmitted to account for the potential DC bit
  signal data_int : std_logic_vector(data'length downto 0);
  --! Internal bit counter signal, used to count down the number of bits to be transmitted
  signal bit_cnt  : integer range 0 to (data'length);
  --! Internal alternative DC signal, used to determine if the DC bit is used or not
  signal alternative_dc : std_logic := '0';
	
begin

  --! Assign the alternative DC signal based on the settings
  alternative_dc <= settings.alt_spi_dc;

  --! Frequency generator for the SPI clock
  delay_process : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or delay_done = '1' or spi_state = idle_state then
        delay_cnt <= (others => '0');
      else
        delay_cnt <= delay_cnt + 1;
      end if; 
    end if;
  end process;

  --! Full delay is used for start and stop states
  delay_done_full <= '1' when delay_cnt(delay_cnt'length - 1) = '1' else '0';
  --! Half delay is used between shifting and clocking to ensure plenty of time for the data to settle
  delay_done_half <= '1' when delay_cnt(0) = '1' else '0';
  --! Delay done is used to determine when the delay is done, a "catch all"
  delay_done <= delay_done_half when spi_state = clk_state or spi_state = shiftout_state else delay_done_full;

  --! Bit counter, either sets the number of bits to be transmitted based on input, or counts down
  bit_cnt_process : process(clk)
  begin
    if rising_edge(clk)then
      --! Resetting the counter when the state machine is idle, or when the reset is active
      if rst = '1' or spi_state = idle_state then
        case bit_width is
          when "001" => 
            if alternative_dc = '1' then
              bit_cnt <= 16;
            else
              bit_cnt <= 15;
            end if;
          when "010" => 
            if alternative_dc = '1' then
              bit_cnt <= 18;
            else
              bit_cnt <= 17;
            end if;
          when "011" => 
            if alternative_dc = '1' then
              bit_cnt <= 24;
            else
              bit_cnt <= 23;
            end if;
          when "100" => 
            if alternative_dc = '1' then
              bit_cnt <= 32;
            else
              bit_cnt <= 31;
            end if;
          when others => 
            if alternative_dc = '1' then
              bit_cnt <= 8;
            else
              bit_cnt <= 7;
            end if;
        end case;
      --! Only count down if the delay is done and the bit counter is not zero (otherwise we are done)
      elsif spi_state = clk_state and delay_done = '1' and bit_cnt > 0 then
        bit_cnt <= bit_cnt - 1;
      end if;
    end if;
  end process bit_cnt_process;

  --! Set the DC pin if the alternative is not used
  dc_process : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        spi_dc <= '0';
      elsif alternative_dc = '0' then
        spi_dc <= set_dc;
      end if;
    end if;
  end process dc_process;
  
  --! Main state machine for the SPI
  interface_process : process(clk)
  begin
  if rising_edge(clk) then
    --! Resetting the state machine might as well put the SPI in idle state
    if rst = '1' then
      spi_state <= idle_state;
    else
      case spi_state is
        --! Idle state, waiting for the send signal to be active
        when idle_state =>
          spi_sda   <= '0';
          spi_scl   <= '0';
          spi_cs    <= '1';
          spi_done  <= '1';
          
          if send = '1' then
            spi_state <= start_state;
          else
            spi_state <= idle_state;
          end if;

        --! Start state, copies the data and prepares for transmission
        when start_state =>
          spi_scl   <= '0';
          spi_cs    <= '0';
          spi_done  <= '0';
          data_int((data'length - 1) downto 0) <= data;
          
          --! If we use the alternative DC system, append the DC bit to the start of the signal
          if alternative_dc = '1' then
            data_int(bit_cnt) <= set_dc;
          end if;
          
          if delay_done = '1' then
            spi_state <= shiftout_state;
          end if;

        --! Shiftout state, set the data bit to the correct value, clock bit to low
        when shiftout_state =>
          spi_sda <= data_int(bit_cnt);
          spi_scl <= '0';
          
          if delay_done = '1' then
            spi_state <= clk_state;
          end if;

        --! Clock state, set the clock bit to high
        when clk_state =>
          spi_scl <= '1';
				
          if delay_done = '1' then
            if bit_cnt = 0 then
              spi_state <= stop_state;
            else
              spi_state <= shiftout_state;
            end if;
          end if;

        --! Stop state, set the bus to "stop"
        when stop_state =>
          spi_sda <= '0';
          spi_scl <= '0';
       
          if delay_done = '1' then
            spi_state <= idle_state;
          end if;     
      end case;
    end if;
  end if;
end process interface_process;

end architecture rtl;