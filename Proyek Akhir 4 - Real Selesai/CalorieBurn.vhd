library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CalorieBurn is
    Port (
        clk_1hz     : in  STD_LOGIC;              -- Clock 1Hz input
        reset       : in  STD_LOGIC;              -- Reset signal
        timer_enable: in  STD_LOGIC;              -- Timer aktif
        mode        : in  STD_LOGIC_VECTOR(1 downto 0); -- Mode
        level       : in  STD_LOGIC_VECTOR(2 downto 0); -- Level
        calories    : out INTEGER range 0 to 9999 -- Total calories burned
    );
end CalorieBurn;

architecture Behavioral of CalorieBurn is
    signal calorie_counter : INTEGER range 0 to 9999 := 0;
    signal burn_rate       : INTEGER := 0;
begin
    process(clk_1hz, reset)
    begin
        if reset = '1' then
            calorie_counter <= 0;
        elsif rising_edge(clk_1hz) then
            if timer_enable = '1' then
                -- Hitung pembakaran kalori
                case mode is
                    when "00" => burn_rate <= 1 * to_integer(unsigned(level)); -- Jalan
                    when "01" => burn_rate <= 3 * to_integer(unsigned(level)); -- Lari
                    when "10" => burn_rate <= 5 * to_integer(unsigned(level)); -- Menanjak
                    when others => burn_rate <= 0;
                end case;
                calorie_counter <= calorie_counter + burn_rate;
            end if;
        end if;
    end process;

    calories <= calorie_counter;
end Behavioral;
