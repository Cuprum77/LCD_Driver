library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- SPIDriver
--
-- This is a modified version of the SPI interface
-- The SPI interface is modified to work with the display
-- This is based off a clock of 100 MHz
--
----------------------------------------------------------------------------
-- Pin Descriptions
----------------------------------------------------------------------------
-- System Lines
--
-- SYS_CLK  | INPUT     | System Clock
-- SYS_RST  | INPUT     | System Reset
----------------------------------------------------------------------------
-- SPI Lines
--
-- SDA      | OUTPUT    | Serial Data
-- SCL      | OUTPUT    | Serial Clock
-- CS       | OUTPUT    | Chip Select
-- DC       | OUTPUT    | Data/Command
-- RST      | OUTPUT    | Reset
----------------------------------------------------------------------------
-- Display Lines
--
-- SEND     | INPUT     | Send Data
-- BIT_WIDTH| INPUT     | Bit Width
-- SET_DC   | INPUT     | Set Data/Command
-- DATA     | INPUT     | Data
-- DONE     | OUTPUT    | Done
----------------------------------------------------------------------------


entity SPIDriver is
	port(
        -- ports
        sys_clk		: in std_logic;
        sys_rst		: in std_logic;
        -- modified spi interface
        sda 		: out std_logic;
        scl 		: out std_logic;
        cs  		: out std_logic;
        dc  		: out std_logic;
        -- display DATA
        send		: in std_logic;
        bit_width 	: in std_logic_vector(2 downto 0);
        set_dc		: in std_logic;
        data 		: in std_logic_vector(31 downto 0);
        done		: out std_logic
    );
end entity SPIDriver;


architecture RTL of SPIDriver is
	type state_machine is (idle, start, shiftout, clk1, stop, hold); 
	signal new_state : state_machine;
    
	signal delay_cnt       	: std_logic_vector(1 downto 0);
	signal delay_DONE_full 	: std_logic;
	signal delay_DONE_half 	: std_logic;
	signal delay_DONE      	: std_logic;

	signal bit_cnt : integer range 0 to 31;
	
begin

	delay_process : process(SYS_CLK)
	begin
	  if rising_edge(SYS_CLK) then
			if SYS_RST = '1' or delay_DONE = '1' or new_state = idle or new_state = hold then
				 delay_cnt <= (others => '0');
			else
				 delay_cnt <= delay_cnt + 1;
			end if; 
	  end if;
	end process;

	delay_DONE_full <= '1' when delay_cnt = "10" else '0';
	delay_DONE_half <= '1' when delay_cnt = "01" else '0';

	delay_DONE <= delay_DONE_half when new_state = clk1 or new_state = shiftout else delay_DONE_full;

	bit_cnt_process : process(SYS_CLK)
	begin
		if rising_edge(SYS_CLK)then
			if SYS_RST = '1' or new_state = idle or new_state = hold then
				case BIT_WIDTH is
					when "000" => bit_cnt <= 7;
					when "001" => bit_cnt <= 15;
					when "010" => bit_cnt <= 17;
					when "011" => bit_cnt <= 23;
                    when "100" => bit_cnt <= 31;
					when others => bit_cnt <= 7;
				end case;
			elsif new_state = clk1 and delay_DONE = '1' and bit_cnt > 0 then
				bit_cnt <= bit_cnt - 1;
			end if;
		end if;
	end process;

	-- set the DATA/command or d/c pin
	DC <= SET_DC when SYS_RST = '0' else '0';

	interface_process : process(SYS_CLK)
	begin
	if rising_edge(SYS_CLK) then
		if SYS_RST = '1' then
			new_state <= idle;
		else
			case new_state is
				-- waiting for a command
				when idle =>
					SDA <= '0';
					SCL <= '0';
					CS <= '1';
					DONE <= '1';
					
					if SEND = '1' then
						new_state <= start;
					else
						new_state <= idle;
					end if;
				-- start the transmission
				when start =>
					SCL <= '0';
					CS <= '0';
					DONE <= '0';
					
					if delay_DONE = '1' then
						new_state <= shiftout;
					end if;
				-- shift out the DATA and set the clock low
				when shiftout =>
					SDA <= DATA(bit_cnt);
					SCL <= '0';
					
					if delay_DONE = '1' then
						new_state <= clk1;
					end if;
				-- set the clock high
				when clk1 =>
					SCL <= '1';
				
					if delay_DONE = '1' then
						if bit_cnt = 0 then
							new_state <= stop;
						else
							new_state <= shiftout;
						end if;
					end if;
				-- stop the transmission
				when stop =>
					SDA <= '0';
					SCL <= '0';
					
					if delay_DONE = '1' then
						new_state <= hold;
					end if;
				-- hold the transmission
				when hold =>
					CS <= '1'; 
					DONE <= '1';

					if SEND = '1' then
						new_state <= start;
					else
						new_state <= idle;
					end if;      
			end case;
		end if;
	end if;
end process;

end RTL;