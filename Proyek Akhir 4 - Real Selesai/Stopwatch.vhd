library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Stopwatch is
    Port (
        clk_1hz    : in  STD_LOGIC;              -- Clock 1Hz input
        reset      : in  STD_LOGIC;              -- Reset signal
        start_stop : in  STD_LOGIC;              -- Start/Stop signal
        time       : out INTEGER range 0 to 9999 -- Stopwatch output
    );
end Stopwatch;

architecture Behavioral of Stopwatch is
    signal running : STD_LOGIC := '0';
    signal counter : INTEGER range 0 to 9999 := 0;
begin
    process(clk_1hz, reset)
    begin
        if reset = '1' then
            counter <= 0;
            running <= '0';
        elsif rising_edge(clk_1hz) then
            if start_stop = '1' then
                running <= NOT running;
            end if;

            if running = '1' then
                counter <= counter + 1;
            end if;
        end if;
    end process;

    time <= counter;
end Behavioral;
