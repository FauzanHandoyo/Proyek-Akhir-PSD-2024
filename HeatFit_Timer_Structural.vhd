-- HeatFit_Timer_Structural.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity HeatFit_Timer is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        heart_rate  : in  STD_LOGIC;
        pause       : in  STD_LOGIC; -- Added pause signal
        duration    : out STD_LOGIC_VECTOR(15 downto 0);
        memory      : out STD_LOGIC_VECTOR(15 downto 0);
        highest_time: out STD_LOGIC_VECTOR(15 downto 0);
        latest_time : out STD_LOGIC_VECTOR(15 downto 0);
        avg_time    : out STD_LOGIC_VECTOR(15 downto 0);
        active_state: out STD_LOGIC;
        stop_state  : out STD_LOGIC;
        reset_state : out STD_LOGIC;
        paused_state: out STD_LOGIC; -- Added paused state
        hours       : out STD_LOGIC_VECTOR(7 downto 0);
        minutes     : out STD_LOGIC_VECTOR(7 downto 0);
        seconds     : out STD_LOGIC_VECTOR(7 downto 0)
    );
end HeatFit_Timer;

architecture Structural of HeatFit_Timer is

    -- Instantiate the HeatFit_Timer_Behavioral component
    component HeatFit_Timer_Behavioral is
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            heart_rate  : in  STD_LOGIC;
            pause       : in  STD_LOGIC; -- Added pause signal
            duration    : out STD_LOGIC_VECTOR(15 downto 0);
            memory      : out STD_LOGIC_VECTOR(15 downto 0);
            highest_time: out STD_LOGIC_VECTOR(15 downto 0);
            latest_time : out STD_LOGIC_VECTOR(15 downto 0);
            avg_time    : out STD_LOGIC_VECTOR(15 downto 0);
            active_state: out STD_LOGIC;
            stop_state  : out STD_LOGIC;
            reset_state : out STD_LOGIC;
            paused_state: out STD_LOGIC; -- Added paused state
            hours       : out STD_LOGIC_VECTOR(7 downto 0);
            minutes     : out STD_LOGIC_VECTOR(7 downto 0);
            seconds     : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Instantiate the File_IO component for logging data to a file
    component File_IO is
        Port (
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            duration_in  : in  STD_LOGIC_VECTOR(15 downto 0); -- Duration to save
            highest_in   : in  STD_LOGIC_VECTOR(15 downto 0); -- Highest time to save
            write_enable : in  STD_LOGIC; -- Control writing to file
            read_enable  : in  STD_LOGIC; -- Control reading from file
            file_name    : in  string; -- File name (could be fixed or dynamic)
            data_out     : out STD_LOGIC_VECTOR(15 downto 0)  -- Output data when reading
        );
    end component;

    -- Internal signals
    signal duration_signal    : STD_LOGIC_VECTOR(15 downto 0);
    signal highest_time_signal: STD_LOGIC_VECTOR(15 downto 0);
    signal stop_signal        : STD_LOGIC;
    signal write_enable_signal: STD_LOGIC := '0'; -- Control for writing to the file
    signal read_enable_signal : STD_LOGIC := '0'; -- Initially, no read

begin

    -- Instantiate HeatFit_Timer_Behavioral
    Behavioral_Instance: HeatFit_Timer_Behavioral
        Port map (
            clk         => clk,
            reset       => reset,
            heart_rate  => heart_rate,
            pause       => pause,
            duration    => duration_signal,
            memory      => memory,
            highest_time=> highest_time_signal,
            latest_time => latest_time,
            avg_time    => avg_time,
            active_state=> active_state,
            stop_state  => stop_signal,
            reset_state => reset_state,
            paused_state=> paused_state,
            hours       => hours,
            minutes     => minutes,
            seconds     => seconds
        );

    -- Instantiate File_IO
    File_IO_Instance: File_IO
        Port map (
            clk         => clk,
            reset       => reset,
            duration_in => duration_signal,  -- Duration value to be logged
            highest_in  => highest_time_signal, -- Highest time value to be logged
            write_enable => write_enable_signal, -- Enable writing when reset and stop are triggered
            read_enable  => read_enable_signal
            file_name    => "user_data.txt",     -- The file to save user data
            data_out     => memory  -- Output data from the file (if needed for reading)
        );

    -- Logic to control write_enable signal based on reset and stop signals
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' and stop_signal = '1' then
                -- Enable writing to the file when both reset and stop signals are active
                write_enable_signal <= '1';
            else
                -- Disable writing when reset and stop are not both active
                write_enable_signal <= '0';
            end if;
        end if;
    end process;

end Structural;