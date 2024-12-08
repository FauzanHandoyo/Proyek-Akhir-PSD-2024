library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HeatFit_Timer_tb is
end HeatFit_Timer_tb;

architecture Behavioral of HeatFit_Timer_tb is
    -- Component declaration for the unit under test (UUT)
    component HeatFit_Timer
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            heart_rate  : in  STD_LOGIC;
            pause       : in  STD_LOGIC; -- Added pause signal
            duration    : out STD_LOGIC_VECTOR(15 downto 0);
            memory      : out STD_LOGIC_VECTOR(15 downto 0);
            highest_time: out STD_LOGIC_VECTOR(15 downto 0);
            latest_time : out STD_LOGIC_VECTOR(15 downto 0);
            avg_time    : out STD_LOGIC_VECTOR(15 downto 0);
            active_state: out STD_LOGIC;
            stop_state  : out STD_LOGIC;
            reset_state : out STD_LOGIC;
            paused_state: out STD_LOGIC; -- Added paused state
            hours       : out STD_LOGIC_VECTOR(7 downto 0);
            minutes     : out STD_LOGIC_VECTOR(7 downto 0);
            seconds     : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Signals to connect to UUT
    signal clk         : STD_LOGIC := '0';
    signal reset       : STD_LOGIC := '0';
    signal heart_rate  : STD_LOGIC := '0';
    signal pause       : STD_LOGIC := '0'; -- Pause signal
    signal duration    : STD_LOGIC_VECTOR(15 downto 0);
    signal memory      : STD_LOGIC_VECTOR(15 downto 0);
    signal highest_time: STD_LOGIC_VECTOR(15 downto 0);
    signal latest_time : STD_LOGIC_VECTOR(15 downto 0);
    signal avg_time    : STD_LOGIC_VECTOR(15 downto 0);
    signal active_state: STD_LOGIC;
    signal stop_state  : STD_LOGIC;
    signal reset_state : STD_LOGIC;
    signal paused_state: STD_LOGIC; -- Paused state
    signal hours       : STD_LOGIC_VECTOR(7 downto 0);
    signal minutes     : STD_LOGIC_VECTOR(7 downto 0);
    signal seconds     : STD_LOGIC_VECTOR(7 downto 0);

    -- Signals for File_IO testing
    signal write_enable : STD_LOGIC := '0';
    signal read_enable  : STD_LOGIC := '0';
    signal file_data_out: STD_LOGIC_VECTOR(15 downto 0);

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instantiate the UUT
    uut: HeatFit_Timer
        Port map (
            clk         => clk,
            reset       => reset,
            heart_rate  => heart_rate,
            pause       => pause, -- Connect pause signal
            duration    => duration,
            memory      => memory,
            highest_time=> highest_time,
            latest_time => latest_time,
            avg_time    => avg_time,
            active_state=> active_state,
            stop_state  => stop_state,
            reset_state => reset_state,
            paused_state=> paused_state, -- Map paused state
            hours       => hours,
            minutes     => minutes,
            seconds     => seconds
        );

    -- Clock generation process
    clk_process : process
    begin
        while True loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test stimulus process
    stimulus_process : process
    begin
        -- Initial state
        reset <= '0';
        heart_rate <= '0';
        pause <= '0';
        write_enable <= '0';
        read_enable <= '0';
        wait for 20 ns;

        -- Write to the file
        write_enable <= '1';
        wait for 50 ns;
        write_enable <= '0';

        -- Delay to ensure writing is complete
        wait for 50 ns;

        -- Read from the file
        read_enable <= '1';
        wait for 50 ns;
        read_enable <= '0';

        -- End simulation
        wait;
    end process;

end Behavioral;
