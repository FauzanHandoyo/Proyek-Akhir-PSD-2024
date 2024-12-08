library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BuzzerController is
    Port (
        clk        : in  STD_LOGIC;
        timer_done : in  STD_LOGIC;
        hr_alert   : in  STD_LOGIC;
        buzzer_pwm : out STD_LOGIC
    );
end BuzzerController;

architecture Behavioral of BuzzerController is
    signal pwm_counter : INTEGER range 0 to 99 := 0;
    signal pwm_signal  : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if pwm_counter = 99 then
                pwm_counter <= 0;
            else
                pwm_counter <= pwm_counter + 1;
            end if;

            if pwm_counter < 50 then
                pwm_signal <= '1';
            else
                pwm_signal <= '0';
            end if;
        end if;
    end process;

    buzzer_pwm <= pwm_signal when (timer_done = '1' or hr_alert = '1') else '0';
end Behavioral;
