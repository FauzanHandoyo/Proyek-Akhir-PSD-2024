library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_HeartFitTimerSystem is
end tb_HeartFitTimerSystem;

architecture behavior of tb_HeartFitTimerSystem is
    component HeartFitTimerSystem
        Port (
            clk             : in  STD_LOGIC;
            reset           : in  STD_LOGIC;
            heart_sensor    : in  STD_LOGIC;
            heart_pulse     : out INTEGER range 0 to 200;
            stopwatch_time  : out INTEGER range 0 to 9999;
            calorie_burned  : out INTEGER range 0 to 9999;
            level           : out STD_LOGIC_VECTOR(2 downto 0);
            mode            : out STD_LOGIC_VECTOR(1 downto 0);
            lap_storage     : out STD_LOGIC_VECTOR(39 downto 0);
            running         : out STD_LOGIC
        );
    end component;

    signal clk          : STD_LOGIC := '0';
    signal reset        : STD_LOGIC := '0';
    signal heart_sensor : STD_LOGIC := '0';
    signal heart_pulse  : INTEGER range 0 to 200;
    signal stopwatch_time : INTEGER range 0 to 9999;
    signal calorie_burned : INTEGER range 0 to 9999;
    signal level        : STD_LOGIC_VECTOR(2 downto 0);
    signal mode         : STD_LOGIC_VECTOR(1 downto 0);
    signal lap_storage  : STD_LOGIC_VECTOR(39 downto 0);
    signal running      : STD_LOGIC;

    constant clk_period : time := 10 ns;

begin
    -- Clock Process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Unit Under Test
    UUT: HeartFitTimerSystem
        Port map (
            clk => clk,
            reset => reset,
            heart_sensor => heart_sensor,
            heart_pulse => heart_pulse,
            stopwatch_time => stopwatch_time,
            calorie_burned => calorie_burned,
            level => level,
            mode => mode,
            lap_storage => lap_storage,
            running => running
        );

    -- Stimulus Process
    stimulus: process
    begin
        -- Reset system
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';

        -- Activate heart rate sensor
        heart_sensor <= '1';
        wait for clk_period * 50;

        -- Deactivate heart rate sensor
        heart_sensor <= '0';
        wait for clk_period * 20;

        -- Reactivate heart rate sensor
        heart_sensor <= '1';
        wait for clk_period * 50;

        -- End simulation
        wait;
    end process;

end behavior;
