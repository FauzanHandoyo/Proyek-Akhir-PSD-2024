library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HeartFitTimerSystem is
    Port (
        clk             : in  STD_LOGIC;              -- Clock input
        reset           : in  STD_LOGIC;              -- Reset signal
        heart_sensor    : in  STD_LOGIC;              -- Heart rate sensor control
        heart_pulse     : out INTEGER range 0 to 200; -- Heart rate output
        stopwatch_time  : out INTEGER range 0 to 9999;-- Stopwatch output
        calorie_burned  : out INTEGER range 0 to 9999;-- Calories burned
        level           : out STD_LOGIC_VECTOR(2 downto 0); -- Level output
        mode            : out STD_LOGIC_VECTOR(1 downto 0); -- Mode output
        lap_storage     : out STD_LOGIC_VECTOR(39 downto 0); -- Timelapse storage
        running         : out STD_LOGIC               -- Timer running status
    );
end HeartFitTimerSystem;

architecture HeartFitTimerSystem_Arch of HeartFitTimerSystem is

    -- Declare components for structural design
    component ClockDivider is
        Port (
            clk     : in  STD_LOGIC;
            clk_1hz : out STD_LOGIC
        );
    end component;

    component TimerCore is
        Port (
            clk_1hz      : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            level_done   : out STD_LOGIC;
            mode_done    : out STD_LOGIC;
            current_level : out STD_LOGIC_VECTOR(2 downto 0);
            current_mode  : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    component CalorieBurn is
        Port (
            clk_1hz      : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            timer_enable : in  STD_LOGIC;
            mode         : in  STD_LOGIC_VECTOR(1 downto 0);
            level        : in  STD_LOGIC_VECTOR(2 downto 0);
            calories     : out INTEGER range 0 to 9999
        );
    end component;

    -- Internal signals for connecting components and processes
    signal clk_1hz       : STD_LOGIC;
    signal level_done    : STD_LOGIC;
    signal mode_done     : STD_LOGIC;
    signal current_level : STD_LOGIC_VECTOR(2 downto 0);
    signal current_mode  : STD_LOGIC_VECTOR(1 downto 0);
    signal stopwatch     : INTEGER range 0 to 9999 := 0;
    signal calories      : INTEGER range 0 to 9999 := 0;
    signal lap_storage_int : STD_LOGIC_VECTOR(39 downto 0) := (others => '0');
    signal lap_index     : INTEGER range 0 to 5 := 0;
    signal heart_rate    : INTEGER range 0 to 200 := 0;

    -- Procedure for simulating heart rate based on mode and level
    procedure simulate_heart_rate(
        signal heart_sensor : in STD_LOGIC;
        signal current_mode : in STD_LOGIC_VECTOR(1 downto 0);
        signal current_level : in STD_LOGIC_VECTOR(2 downto 0);
        signal heart_rate : out INTEGER range 0 to 200
    ) is
    begin
        if (heart_sensor = '1') then
            case current_mode is
                when "00" =>  -- Walking
                    heart_rate <= 60 + (10 * to_integer(unsigned(current_level)));
                when "01" =>  -- Running
                    heart_rate <= 100 + (10 * to_integer(unsigned(current_level)));
                when "10" =>  -- Climbing
                    heart_rate <= 150 + (10 * to_integer(unsigned(current_level)));
                when others =>
                    heart_rate <= 0; -- Default (sensor off)
            end case;
        else
            heart_rate <= 0; -- Sensor off
        end if;
    end simulate_heart_rate;

begin

    -- Structural Instantiations
    ClockDividerInst : ClockDivider
        Port map (
            clk => clk,
            clk_1hz => clk_1hz
        );

    TimerCoreInst : TimerCore
        Port map (
            clk_1hz => clk_1hz,
            reset => reset,
            level_done => level_done,
            mode_done => mode_done,
            current_level => current_level,
            current_mode => current_mode
        );

    CalorieBurnInst : CalorieBurn
        Port map (
            clk_1hz => clk_1hz,
            reset => reset,
            timer_enable => level_done,
            mode => current_mode,
            level => current_level,
            calories => calories
        );

    -- Behavioral Logic: Stopwatch and Heart Rate Simulation
    process(clk_1hz, reset)
    begin
        if reset = '1' then
            stopwatch <= 0;
        elsif rising_edge(clk_1hz) then
            if level_done = '1' then
                stopwatch <= stopwatch + 1; -- Increment stopwatch at each level
            end if;
            simulate_heart_rate(heart_sensor, current_mode, current_level, heart_rate);
        end if;
    end process;

    -- Dataflow Logic: Assign output values directly based on the calculated values
    stopwatch_time <= stopwatch;
    calorie_burned <= calories;
    level <= current_level;
    mode <= current_mode;
    lap_storage <= lap_storage_int;
    running <= heart_sensor; -- System is running if sensor is active
    heart_pulse <= heart_rate;

    -- Timelapse Logic: Store lap times
    process(clk_1hz, reset)
    begin
        if reset = '1' then
            lap_storage_int <= (others => '0');
            lap_index <= 0;
        elsif rising_edge(clk_1hz) then
            if level_done = '1' or mode_done = '1' then
                if lap_index < 5 then
                    lap_storage_int((lap_index * 8) + 7 downto lap_index * 8) <= std_logic_vector(to_unsigned(stopwatch, 8));
                    lap_index <= lap_index + 1; -- Move to next lap index
                end if;
            end if;
        end if;
    end process;

end HeartFitTimerSystem_Arch;
