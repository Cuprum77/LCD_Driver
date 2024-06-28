--------------------------------------------------------------------------
--! @file sequencer.vhd
--! @brief Outputs the initialization codes for the display in the correct order
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

entity sequencer is
  port(
    -- Clock and reset
    clk             : in  std_logic;  --! Clock
    rst             : in  std_logic;  --! Reset, synchronous
    settings        : in  t_spi_settings; --! Settings for the display
    spi_sda         : out std_logic;  --! SPI SDA (Data)
    spi_scl         : out std_logic;  --! SPI SCL (Clock)
    spi_cs          : out std_logic;  --! SPI CS (Chip Select)
    spi_dc          : out std_logic;  --! SPI DC (Data/Command)
    disp_rst_n      : out std_logic;  --! Reset for the display
    done            : out std_logic;  --! HIGH when done
    sequencer_error : out std_logic   --! HIGH if error
  );
end entity sequencer;

architecture rtl of sequencer is
  --! Setup the variables for the statem machine
  type state_machine is (
    reset_state,
    fetch_rom_data_state,
    wait_for_rom_state,
    process_instruction_state,
    command_instruction_state,
    length_instruction_state,
    set_length_state,
    data_instruction_state,
    wait_instruction_state,
    wait_init_state,
    wait_calculate_state,
    wait_state,
    start_transmission_state,
    end_transmission_state,
    give_spi_time_1_state,
    give_spi_time_2_state,
    wait_for_spi_state,
    verify_pointer_state,
    idle_state,
    error_state
  );
  signal sequencer_state : state_machine := reset_state; --! Initialize to reset_state

  --! Add the component for the SPI
  component spi is
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
  end component spi;

  --! Add the component for the ROM
  component rom is
    port(
      clk         : in  std_logic;  --! Clock signal
      rst         : in  std_logic;  --! Reset signal, asynchronous
      address     : in  std_logic_vector(7 downto 0);  --! Address of the ROM
      instruction : out std_logic_vector(7 downto 0);  --! Instruction data
      data        : out std_logic_vector(31 downto 0); --! Payload data
      size        : out std_logic_vector(7 downto 0)   --! Size of the ROM, constant
    );
  end component rom;

  --! Add the component for the resetter
  component resetter is
    port (
      clk         : in  std_logic;  --! Clock
      rst         : in  std_logic;  --! Reset, synchronous
      settings    : in  t_spi_settings; --! Settings
      disp_rst_n  : out std_logic;  --! Display reset, active low
      done        : out std_logic   --! Done signal
    );
  end component resetter;

  -- setup the internal signals that handle the ROM
  signal rom_pointer          : std_logic_vector(7 downto 0) := (others => '0');
  signal rom_address          : std_logic_vector(7 downto 0) := (others => '0');
  signal rom_instruction      : std_logic_vector(7 downto 0) := (others => '0');
  signal rom_data             : std_logic_vector(31 downto 0) := (others => '0');
  signal rom_size             : std_logic_vector(7 downto 0) := (others => '0');

  -- setup the internal signals that handle the spi
  signal spi_send   : std_logic := '0';
  signal spi_set_dc : std_logic := '0';
  signal spi_done   : std_logic := '0';
  signal spi_data   : std_logic_vector(31 downto 0);
  signal spi_width  : std_logic_vector(2 downto 0);

  -- setup the internal signals that handle the wait counter
  signal wait_count : integer := 0;

  -- setup the internal signals that handle the resetter
  signal rst_rst        : std_logic := '0';
  signal rst_done_temp  : std_logic := '0';
  signal rst_done       : std_logic := '0';

  -- internal signal
  signal command_dc_bit : std_logic := '0';

  --! Create internal signals for the settings
  signal enable_resetter : std_logic;
  signal invert_dc       : std_logic;

begin

  --! Get the settings from the settings record
  enable_resetter <= settings.resetter_en;
  invert_dc       <= settings.invert_dc;

  -- Map the SPIDriver component
  -- The SPI physical signals will simply be forwarded to the top level file
  spi_comp : spi
    port map(
      clk       => clk,
      rst       => rst,
      settings  => settings,
      spi_sda   => spi_sda,
      spi_scl   => spi_scl,
      spi_cs    => spi_cs,
      spi_dc    => spi_dc,
      send      => spi_send,
      set_dc    => spi_set_dc,
      spi_done  => spi_done,
      data      => spi_data,
      bit_width => spi_width
    );

  -- Map the ROM component
  rom_comp : rom
    port map(
      clk         => clk,
      rst         => rst,
      address     => rom_address,
      instruction => rom_instruction,
      data        => rom_data,
      size        => rom_size
    );

  -- If the resetter is enabled, pipe our rst signal through, else set it to '1'
  rst_rst <= rst when enable_resetter = '1' else '1';
  rst_done <= rst_done_temp when enable_resetter = '1' else '1';
  command_dc_bit <= '0' when invert_dc = '1' else '1';

  -- Map the resetter
  resetter_comp : resetter
    port map (
      clk         => clk,
      rst         => rst_rst,
      settings    => settings,
      disp_rst_n  => disp_rst_n,
      done        => rst_done_temp
    );

  -- This is the main state machine that ensures the signals get sent in sequence
  sequencer_state_machine : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sequencer_state <= reset_state;
         -- Reset the error signal
        sequencer_error <= '0';
        done <= '0';
      else
        case sequencer_state is
          -- Set up the state machine, this is also the reset state
          when reset_state =>
            sequencer_error <= '0';
            done <= '0';
            rom_pointer <= (others => '0'); -- Reset the pointer

            -- only continue if the done signal is HIGH
            if rst_done = '1' then
              sequencer_state <= fetch_rom_data_state;
            end if;

          -- Set the ROM address to the pointer
          when fetch_rom_data_state =>
            rom_address <= rom_pointer;
            sequencer_state <= wait_for_rom_state;

          -- Give the ROM some time
          when wait_for_rom_state =>
            sequencer_state <= process_instruction_state;
          
          -- Load the data from the ROM
          when process_instruction_state =>
            case rom_instruction is
              -- Command data
              when x"10" =>
                spi_width <= "000"; -- 8 bit width
                spi_set_dc <= command_dc_bit; -- Set the DC signal
                spi_data <= rom_data; -- Set the data
                sequencer_state <= start_transmission_state;
              -- Length data
              when x"20" =>
                sequencer_state <= set_length_state;
                -- Payload data
              when x"21" =>
                spi_set_dc <= not command_dc_bit; -- Set the DC signal
                spi_data <= rom_data; -- Set the data
                sequencer_state <= start_transmission_state;
              -- Wait data
              when x"30" =>
                sequencer_state <= wait_init_state;
              -- If the instruction is not recognized, set the error signal
              when others =>
                sequencer_state <= error_state;
            end case;

          -- Set the length of the payload
          when set_length_state =>
            case rom_data is
              when x"00000000" =>
                spi_width <= "000"; -- 8 bit width
              when x"00000001" =>
                spi_width <= "001"; -- 16 bit width
              when x"00000002" =>
                spi_width <= "010"; -- 18 bit width
              when x"00000003" =>
                spi_width <= "011"; -- 24 bit width
              when x"00000004" =>
                spi_width <= "100"; -- 32 bit width
              when others =>
                sequencer_state <= error_state;
            end case;

            -- Jump to the verification state
            sequencer_state <= verify_pointer_state;

          -- Setup the wait counter
          when wait_init_state =>
            wait_count <= to_integer(unsigned(rom_data));
            sequencer_state <= wait_calculate_state;

          -- Calculate the wait counter
          when wait_calculate_state =>
            -- Translate to clock cycles
            -- 1 / 100 MHz = 10 ns
            -- 10 ns * 100_000 = 1 ms
            -- Multiply wait_count by 100_000
            wait_count <= wait_count * 100_000;
            sequencer_state <= wait_state;

          -- Wait for the wait counter to reach 0
          when wait_state =>
            if wait_count = 0 then
              sequencer_state <= verify_pointer_state;
            else
              wait_count <= wait_count - 1;
            end if;

          -- Start the SPI transmission
          when start_transmission_state =>
            spi_send <= '1';
            sequencer_state <= end_transmission_state;
            
          -- End the SPI transmission
          when end_transmission_state =>
            spi_send <= '0';
            sequencer_state <= give_spi_time_1_state;

          -- Give the SPI some time
          when give_spi_time_1_state =>
            sequencer_state <= give_spi_time_2_state;

          -- Give the SPI some time
          when give_spi_time_2_state =>
            sequencer_state <= wait_for_spi_state;

          -- Wait for the SPI to finish
          when wait_for_spi_state =>
            if spi_done = '1' then
              sequencer_state <= verify_pointer_state;
            end if;

          -- Load the instruction from the ROM
          when verify_pointer_state =>
            if rom_pointer = rom_size then
              sequencer_state <= idle_state;
            else
              rom_pointer <= rom_pointer + 1;
              sequencer_state <= fetch_rom_data_state;
            end if;

          -- Do absolutely nothing here
          -- When we reach this state, we are done.
          when idle_state =>
            done <= '1';

          -- If we reach this state, something went wrong.
          -- Set the error signal and freeze the state machine in this state
          -- until the reset signal is asserted.
          when error_state =>
            sequencer_error <= '1';

          -- If we reach this state, something went wrong.
          -- Set the next state to the error state
          when others =>
            sequencer_state <= error_state;

        end case;
      end if;
    end if;
  end process;

end architecture rtl;