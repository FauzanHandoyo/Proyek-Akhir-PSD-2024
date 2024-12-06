-- File_IO.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity File_IO is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        duration_in  : in  STD_LOGIC_VECTOR(15 downto 0); -- Duration to save
        highest_in   : in  STD_LOGIC_VECTOR(15 downto 0); -- Highest time to save
        write_enable : in  STD_LOGIC; -- Control writing to file
        read_enable  : in  STD_LOGIC; -- Control reading from file
        file_name    : in  string; -- Name of the file (could be fixed or passed dynamically)
        data_out     : out STD_LOGIC_VECTOR(15 downto 0)  -- Output data when reading from file
    );
end File_IO;

architecture Behavioral of File_IO is

    -- Declare file for output (for writing)
    file out_file  : text open write_mode is "user_data.txt";
    -- Declare file for input (for reading)
    file in_file   : text open read_mode  is "user_data.txt";
    variable line_buf : line;
    variable data_str : string(1 to 16);

begin

    -- Process for writing data to file when reset = 1 and stop = 1
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Open the file for writing if reset is active
                file_open(out_file, "user_data.txt", write_mode);
                
                if write_enable = '1' then
                    -- Write duration and highest time to the file
                    data_str := to_string(duration_in);
                    write(line_buf, data_str);
                    writeline(out_file, line_buf);

                    data_str := to_string(highest_in);
                    write(line_buf, data_str);
                    writeline(out_file, line_buf);
                end if;
            end if;
        end if;
    end process;

    -- Process for reading data from file if needed
    process(clk)
    begin
        if rising_edge(clk) then
            if read_enable = '1' then
                -- Open the file for reading
                file_open(in_file, "user_data.txt", read_mode);

                -- Read the data from the file and assign it to output
                readline(in_file, line_buf);
                read(line_buf, data_str);
                data_out <= to_std_logic_vector(data_str);
            end if;
        end if;
    end process;

end Behavioral;

-- Helper function to convert std_logic_vector to string
function to_string(input : STD_LOGIC_VECTOR(15 downto 0)) return string is
    variable result : string(1 to 16);
begin
    for i in 0 to 15 loop
        result(i+1) := character'VAL(to_integer(unsigned(input(i))));
    end loop;
    return result;
end function;

-- Helper function to convert string to std_logic_vector
function to_std_logic_vector(input : string) return STD_LOGIC_VECTOR is
    variable result : STD_LOGIC_VECTOR(15 downto 0);
begin
    for i in 0 to 15 loop
        result(i) := STD_LOGIC'VALUE(input(i+1));
    end loop;
    return result;
end function;
