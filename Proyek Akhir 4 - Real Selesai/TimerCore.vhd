library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TimerCore is
    Port (
        clk_1hz     : in  STD_LOGIC;              -- Clock 1Hz input
        reset       : in  STD_LOGIC;              -- Reset signal
        level_done  : out STD_LOGIC;              -- Level selesai
        mode_done   : out STD_LOGIC;              -- Mode selesai
        current_level : out STD_LOGIC_VECTOR(2 downto 0); -- Level saat ini
        current_mode  : out STD_LOGIC_VECTOR(1 downto 0)  -- Mode saat ini
    );
end TimerCore;

architecture Behavioral of TimerCore is
    signal level      : INTEGER range 1 to 5 := 1; -- Level saat ini
    signal mode       : INTEGER range 0 to 2 := 0; -- Mode: 0 = Jalan, 1 = Lari, 2 = Menanjak
    signal level_timer : INTEGER range 0 to 99 := 0; -- Timer untuk setiap level
    signal max_levels  : INTEGER := 3; -- Default: Mode Jalan dengan 3 level
begin
    process(clk_1hz, reset)
    begin
        if reset = '1' then
            level <= 1;
            mode <= 0;
            level_timer <= 0;
            max_levels <= 3;
        elsif rising_edge(clk_1hz) then
            if level_timer = 99 then
                if level = max_levels then
                    -- Beralih ke mode berikutnya
                    if mode = 2 then
                        mode <= 0; -- Kembali ke mode pertama
                    else
                        mode <= mode + 1;
                    end if;
                    level <= 1; -- Reset ke level pertama
                    case mode + 1 is
                        when 0 => max_levels <= 3; -- Jalan: 3 level
                        when 1 => max_levels <= 5; -- Lari: 5 level
                        when 2 => max_levels <= 3; -- Menanjak: 3 level
                        when others => max_levels <= 3;
                    end case;
                else
                    level <= level + 1; -- Naik ke level berikutnya
                end if;
                level_timer <= 0;
            else
                level_timer <= level_timer + 1;
            end if;
        end if;
    end process;

    level_done <= '1' when level_timer = 99 else '0';
    mode_done <= '1' when level = max_levels and level_timer = 99 else '0';
    current_level <= std_logic_vector(to_unsigned(level, 3));
    current_mode <= std_logic_vector(to_unsigned(mode, 2));
end Behavioral;
