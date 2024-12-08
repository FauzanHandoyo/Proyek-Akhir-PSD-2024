library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Untuk konversi tipe

entity DisplayController is
    Port (
        clk          : in  STD_LOGIC;              -- Clock input
        minutes      : in  INTEGER range 0 to 99;  -- Menit input
        seconds      : in  INTEGER range 0 to 59;  -- Detik input
        display_7seg : out STD_LOGIC_VECTOR(6 downto 0); -- 7-segment output
        digit_select : out STD_LOGIC_VECTOR(3 downto 0)  -- Digit selector
    );
end DisplayController;

architecture Behavioral of DisplayController is
    -- Sinyal internal untuk penghitungan digit
    signal digit_counter : INTEGER range 0 to 3 := 0;
    signal display_data  : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_minutes   : STD_LOGIC_VECTOR(7 downto 0);
    signal bcd_seconds   : STD_LOGIC_VECTOR(7 downto 0);

    -- Proses decoding angka ke 7-segment
    function decode_7seg(input_digit : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case input_digit is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when others => return "1111111"; -- Blank
        end case;
    end function;
begin
    -- Proses untuk mengubah waktu ke format BCD
    process(minutes, seconds)
    begin
        bcd_minutes <= std_logic_vector(to_unsigned(minutes, 8));
        bcd_seconds <= std_logic_vector(to_unsigned(seconds, 8));
    end process;

    -- Proses untuk rotasi digit pada tampilan
    process(clk)
    begin
        if rising_edge(clk) then
            digit_counter <= (digit_counter + 1) mod 4;
            case digit_counter is
                when 0 => -- Menit puluhan
                    display_data <= bcd_minutes(7 downto 4);
                    digit_select <= "1110";
                when 1 => -- Menit satuan
                    display_data <= bcd_minutes(3 downto 0);
                    digit_select <= "1101";
                when 2 => -- Detik puluhan
                    display_data <= bcd_seconds(7 downto 4);
                    digit_select <= "1011";
                when 3 => -- Detik satuan
                    display_data <= bcd_seconds(3 downto 0);
                    digit_select <= "0111";
                when others =>
                    display_data <= "0000";
            end case;
        end if;
    end process;

    -- Dekode data ke tampilan 7-segmen
    display_7seg <= decode_7seg(display_data);
end Behavioral;
