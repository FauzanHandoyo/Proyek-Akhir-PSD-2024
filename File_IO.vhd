library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity File_IO is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        duration_in  : in  STD_LOGIC_VECTOR(15 downto 0); -- Duration to save
        highest_in   : in  STD_LOGIC_VECTOR(15 downto 0); -- Highest time to save
        write_enable : in  STD_LOGIC; -- Control writing to file
        read_enable  : in  STD_LOGIC; -- Control reading from file
        data_out     : out STD_LOGIC_VECTOR(15 downto 0)  -- Output data when reading from file
    );
end File_IO;

architecture Behavioral of File_IO is
    file out_file : text open write_mode is "user_data.txt";
    file in_file  : text open read_mode is "user_data.txt";

    
begin
    process(clk)
        variable line_buf : line;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data_out <= (others => '0');
            elsif write_enable = '1' then

                report "Writing duration: " & integer'image(to_integer(unsigned(duration_in)));
                report "Writing highest: " & integer'image(to_integer(unsigned(highest_in)));

                write(line_buf, integer'image(to_integer(unsigned(duration_in))));
                writeline(out_file, line_buf);

                write(line_buf, integer'image(to_integer(unsigned(highest_in))));
                writeline(out_file, line_buf);
            end if;
        end if;
    end process;

    process(clk)
        variable line_buf : line;
        variable temp_int : integer;
    begin
        if rising_edge(clk) then
            if read_enable = '1' then
                report "Reading from file...";
                readline(in_file, line_buf);
                read(line_buf, temp_int);

                report "Data read: " & integer'image(temp_int);
                
                data_out <= std_logic_vector(to_unsigned(temp_int, 16));
            end if;
        end if;
    end process;
end Behavioral;
