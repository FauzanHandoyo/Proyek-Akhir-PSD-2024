library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HeatFit_Timer_Behavioral is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        heart_rate  : in  STD_LOGIC;
        duration    : out STD_LOGIC_VECTOR(15 downto 0);
        memory      : out STD_LOGIC_VECTOR(15 downto 0);
        highest_time: out STD_LOGIC_VECTOR(15 downto 0);
        latest_time : out STD_LOGIC_VECTOR(15 downto 0);
        avg_time    : out STD_LOGIC_VECTOR(15 downto 0);
        active_state: out STD_LOGIC;
        stop_state  : out STD_LOGIC;
        reset_state : out STD_LOGIC;
        hours       : out STD_LOGIC_VECTOR(7 downto 0);
        minutes     : out STD_LOGIC_VECTOR(7 downto 0);
        seconds     : out STD_LOGIC_VECTOR(7 downto 0)
    );
end HeatFit_Timer_Behavioral;

architecture Behavioral of HeatFit_Timer_Behavioral is
    -- Internal signals and registers
    signal state             : STD_LOGIC := '0'; -- 0: Idle, 1: Counting
    signal counter           : unsigned(15 downto 0) := (others => '0');
    signal memory_reg        : unsigned(15 downto 0) := (others => '0');
    signal highest_time_reg  : unsigned(15 downto 0) := (others => '0');
    signal latest_time_reg   : unsigned(15 downto 0) := (others => '0');
    signal total_time_reg    : unsigned(31 downto 0) := (others => '0');
    signal session_count_reg : unsigned(15 downto 0) := (others => '0');
    signal avg_time_reg      : unsigned(15 downto 0) := (others => '0');
    signal reset_prev        : STD_LOGIC := '0';
    signal reset_edge        : STD_LOGIC := '0';
    signal reset_processing  : STD_LOGIC := '0';
    signal first_session_done: STD_LOGIC := '0';
    signal active_state_reg  : STD_LOGIC := '0';
    signal stop_state_reg    : STD_LOGIC := '0';
    signal reset_state_reg   : STD_LOGIC := '0';
    signal hours_reg         : unsigned(7 downto 0) := (others => '0');
    signal minutes_reg       : unsigned(7 downto 0) := (others => '0');
    signal seconds_reg       : unsigned(7 downto 0) := (others => '0');

begin

    -- Rising edge detection for reset
    process(clk)
    begin
        if rising_edge(clk) then
            reset_edge <= reset and not reset_prev;
            reset_prev <= reset;
        end if;
    end process;

    -- Main timer logic
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Handle reset logic
                if reset_processing = '0' then
                    memory_reg <= counter;
                    if counter > highest_time_reg then
                        highest_time_reg <= counter;
                    end if;
                    if first_session_done = '0' then
                        avg_time_reg <= counter;
                        first_session_done <= '1';
                    else
                        total_time_reg <= total_time_reg + resize(counter, 32);
                        session_count_reg <= session_count_reg + 1;
                        if session_count_reg > 0 then
                            avg_time_reg <= resize(total_time_reg / session_count_reg, 16);
                        end if;
                    end if;
                    counter <= (others => '0');
                    reset_processing <= '1';
                end if;
                reset_state_reg <= '1';
                active_state_reg <= '0';
                stop_state_reg <= '0';
            else
                reset_state_reg <= '0';
                if reset_processing = '1' then
                    latest_time_reg <= counter;
                    reset_processing <= '0';
                end if;
            end if;

            if reset = '0' and heart_rate = '1' then
                state <= '1';
                active_state_reg <= '1';
                stop_state_reg <= '0';
            elsif reset = '0' and heart_rate = '0' then
                state <= '0';
                active_state_reg <= '0';
                stop_state_reg <= '1';
            end if;

            if state = '1' then
                counter <= counter + 1;
            end if;

            seconds_reg <= resize(counter mod 60, 8);
            minutes_reg <= resize((counter / 60) mod 60, 8);
            hours_reg <= resize(counter / 3600, 8);
        end if;
    end process;

    duration <= std_logic_vector(counter);
    memory <= std_logic_vector(memory_reg);
    highest_time <= std_logic_vector(highest_time_reg);
    latest_time <= std_logic_vector(latest_time_reg);
    avg_time <= std_logic_vector(avg_time_reg);
    active_state <= active_state_reg;
    stop_state <= stop_state_reg;
    reset_state <= reset_state_reg;
    hours <= std_logic_vector(hours_reg);
    minutes <= std_logic_vector(minutes_reg);
    seconds <= std_logic_vector(seconds_reg);

end Behavioral;
