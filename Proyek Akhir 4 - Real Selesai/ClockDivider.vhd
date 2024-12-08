library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ClockDivider is
    Port (
        clk     : in  STD_LOGIC;  -- Input clock
        clk_1hz : out STD_LOGIC  -- Output clock (simulasi cepat)
    );
end ClockDivider;

architecture Behavioral of ClockDivider is
    signal div_counter : INTEGER range 0 to 4 := 0;
    signal clk_div     : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if div_counter = 4 then -- Hitung hingga 5 untuk simulasi cepat
                div_counter <= 0;
                clk_div <= NOT clk_div;
            else
                div_counter <= div_counter + 1;
            end if;
        end if;
    end process;

    clk_1hz <= clk_div;
end Behavioral;
