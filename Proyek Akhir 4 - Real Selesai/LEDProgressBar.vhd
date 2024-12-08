library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LEDProgressBar is
    Port (
        minutes : in  INTEGER range 0 to 99;
        seconds : in  INTEGER range 0 to 59;
        led_bar : out STD_LOGIC_VECTOR(7 downto 0)
    );
end LEDProgressBar;

architecture Behavioral of LEDProgressBar is
begin
    led_bar <= std_logic_vector(to_unsigned((minutes * 60 + seconds) / 75, 8));
end Behavioral;
