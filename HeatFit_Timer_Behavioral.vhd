library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HeatFit_Timer_Behavioral is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        heart_rate  : in  STD_LOGIC;
        pause       : in  STD_LOGIC; -- New pause signal
        duration    : out STD_LOGIC_VECTOR(15 downto 0);
        memory      : out STD_LOGIC_VECTOR(15 downto 0);
        highest_time: out STD_LOGIC_VECTOR(15 downto 0);
        latest_time : out STD_LOGIC_VECTOR(15 downto 0);
        avg_time    : out STD_LOGIC_VECTOR(15 downto 0);
        active_state: out STD_LOGIC;
        stop_state  : out STD_LOGIC;
        reset_state : out STD_LOGIC;
        paused_state: out STD_LOGIC; -- New paused state indicator
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
    signal active_state_reg  : STD_LOGIC := '0';
    signal stop_state_reg    : STD_LOGIC := '0';
    signal reset_state_reg   : STD_LOGIC := '0';
    signal paused_state_reg  : STD_LOGIC := '0'; -- New signal for pause state
    signal hours_reg         : unsigned(7 downto 0) := (others => '0');
    signal minutes_reg       : unsigned(7 downto 0) := (others => '0');
    signal seconds_reg       : unsigned(7 downto 0) := (others => '0');

    -- Session data for calculations
    type session_array is array(0 to 15) of unsigned(15 downto 0);
    signal session_times : session_array := (others => (others => '0'));

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
        variable total_time : unsigned(31 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Handle reset logic
                if reset_processing = '0' then
                    -- Save the session time and calculate average
                    if session_count_reg < session_times'length then
                        session_times(to_integer(session_count_reg)) <= counter;
                    end if;

                    -- Update highest time if necessary
                    if counter > highest_time_reg then
                        highest_time_reg <= counter;
                    end if;

                    -- Update latest time
                    latest_time_reg <= counter;

                    -- Increment session count
                    session_count_reg <= session_count_reg + 1;

                    -- Calculate total time using a loop
                    total_time := (others => '0');
                    for i in session_times'range loop
                        total_time := total_time + resize(session_times(i), total_time'length);
                    end loop;

                    -- Update average time
                    if session_count_reg > 0 then
                        avg_time_reg <= resize(total_time / session_count_reg, 16);
                    end if;

                    -- Reset the counter
                    counter <= (others => '0');
                    reset_processing <= '1';
                end if;
                reset_state_reg <= '1';
                active_state_reg <= '0';
                stop_state_reg <= '0';
                paused_state_reg <= '0'; -- Clear pause state on reset
            else
                reset_state_reg <= '0';
                if reset_processing = '1' then
                    reset_processing <= '0';
                end if;
            end if;

            -- Handle pause functionality
            if pause = '1' then
                paused_state_reg <= '1'; -- Set pause state
            else
                paused_state_reg <= '0'; -- Clear pause state

                -- State control
                if reset = '0' and heart_rate = '1' then
                    state <= '1';
                    active_state_reg <= '1';
                    stop_state_reg <= '0';
                elsif reset = '0' and heart_rate = '0' then
                    state <= '0';
                    active_state_reg <= '0';
                    stop_state_reg <= '1';
                end if;

                -- Increment counter only if not paused
                if state = '1' then
                    counter <= counter + 1;
                end if;

                -- Convert counter to hours, minutes, and seconds
                seconds_reg <= resize(counter mod 60, 8);
                minutes_reg <= resize((counter / 60) mod 60, 8);
                hours_reg <= resize(counter / 3600, 8);
            end if;
        end if;
    end process;

    -- Assign outputs
    duration <= std_logic_vector(counter);
    memory <= std_logic_vector(memory_reg);
    highest_time <= std_logic_vector(highest_time_reg);
    latest_time <= std_logic_vector(latest_time_reg);
    avg_time <= std_logic_vector(avg_time_reg);
    active_state <= active_state_reg;
    stop_state <= stop_state_reg;
    reset_state <= reset_state_reg;
    paused_state <= paused_state_reg; -- New output for pause state
    hours <= std_logic_vector(hours_reg);
    minutes <= std_logic_vector(minutes_reg);
    seconds <= std_logic_vector(seconds_reg);

end Behavioral;
