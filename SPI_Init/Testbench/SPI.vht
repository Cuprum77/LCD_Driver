library ieee;
use ieee.std_logic_1164.all;

entity SPI_TB is
end SPI_TB;

architecture SPI_ARCH of SPI_TB is
    -- constants
    constant clk_period : time := 10ns; -- 100 MHz

    -- signals, these are all initialized to 0
    signal sys_clk : std_logic := '0';
    signal sys_rst : std_logic := '0';
    signal sda : std_logic := '0';
    signal scl : std_logic := '0';
    signal cs : std_logic := '0';
    -- signal DC : std_logic := '0'; -- we don't need this signal
    signal send : std_logic := '0';
    signal bit_width : std_logic_vector(2 downto 0) := (others => '0');
    signal data : std_logic_vector(31 downto 0) := (others => '0');
    signal done : std_logic := '0';

    component SPIDriver is
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
    end component SPIDriver;

begin

    -- set up the component
    UUT : SPIDriver
        port map(
            sys_clk => sys_clk,
            sys_rst => sys_rst,
            sda => sda,
            scl => scl,
            cs => cs,
            dc => open,
            send => send,
            bit_width => bit_width,
            set_dc => '0',
            data => data,
            done => done
        );

    -- init process, where code that only runs once goes
    init_process : process
    begin
        sys_rst <= '1';
        wait for 10 ns;
        sys_rst <= '0';
    wait;
    end process init_process;

    -- clock process, generates the clock signal
    clk_process : process
    begin
        sys_clk <= '0';
        loop 
            wait for clk_period/2;
            sys_clk <= not sys_clk;
        end loop;
    wait;
    end process clk_process;

    -- always process, where we generate our test signals
    always_process : process
    begin
        wait for 15 ns; -- wait for the init process to finish
        bit_width <= "100"; -- 8 bit
        data <= x"aaaaaaaa"; -- 10101010
        send <= '1';
        wait for 5 ns; -- give the driver a clock cycle
        send <= '0';
    wait;
    end process always_process;

end SPI_ARCH;