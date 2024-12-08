library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HeartRateMonitor is
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        hr_sensor  : in  STD_LOGIC_VECTOR(7 downto 0);
        hr_alert   : out STD_LOGIC;
        heart_rate : out INTEGER range 0 to 255
    );
end HeartRateMonitor;

architecture Behavioral of HeartRateMonitor is
    constant HR_MAX : INTEGER := 180;
    constant HR_MIN : INTEGER := 60;
    signal hr_value : INTEGER range 0 to 255 := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            hr_value <= 0;
        elsif rising_edge(clk) then
            hr_value <= to_integer(unsigned(hr_sensor));
        end if;
    end process;

    heart_rate <= hr_value;
    hr_alert <= '1' when (hr_value > HR_MAX or hr_value < HR_MIN) else '0';
end Behavioral;
