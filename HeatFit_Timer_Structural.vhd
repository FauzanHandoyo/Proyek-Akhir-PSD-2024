library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HeatFit_Timer is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        heart_rate  : in  STD_LOGIC;
        duration    : out STD_LOGIC_VECTOR(15 downto 0);
        memory      : out STD_LOGIC_VECTOR(15 downto 0);
        highest_time: out STD_LOGIC_VECTOR(15 downto 0);
        latest_time : out STD_LOGIC_VECTOR(15 downto 0);
        avg_time    : out STD_LOGIC_VECTOR(15 downto 0);
        active_state: out STD_LOGIC;
        stop_state  : out STD_LOGIC;
        reset_state : out STD_LOGIC;
        hours       : out STD_LOGIC_VECTOR(7 downto 0);
        minutes     : out STD_LOGIC_VECTOR(7 downto 0);
        seconds     : out STD_LOGIC_VECTOR(7 downto 0)
    );
end HeatFit_Timer;

architecture Structural of HeatFit_Timer is

    component HeatFit_Timer_Behavioral is
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            heart_rate  : in  STD_LOGIC;
            duration    : out STD_LOGIC_VECTOR(15 downto 0);
            memory      : out STD_LOGIC_VECTOR(15 downto 0);
            highest_time: out STD_LOGIC_VECTOR(15 downto 0);
            latest_time : out STD_LOGIC_VECTOR(15 downto 0);
            avg_time    : out STD_LOGIC_VECTOR(15 downto 0);
            active_state: out STD_LOGIC;
            stop_state  : out STD_LOGIC;
            reset_state : out STD_LOGIC;
            hours       : out STD_LOGIC_VECTOR(7 downto 0);
            minutes     : out STD_LOGIC_VECTOR(7 downto 0);
            seconds     : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

begin

    -- Instantiate the Behavioral module
    Behavioral_Instance: HeatFit_Timer_Behavioral
        Port map (
            clk         => clk,
            reset       => reset,
            heart_rate  => heart_rate,
            duration    => duration,
            memory      => memory,
            highest_time=> highest_time,
            latest_time => latest_time,
            avg_time    => avg_time,
            active_state=> active_state,
            stop_state  => stop_state,
            reset_state => reset_state,
            hours       => hours,
            minutes     => minutes,
            seconds     => seconds
        );

end Structural;
