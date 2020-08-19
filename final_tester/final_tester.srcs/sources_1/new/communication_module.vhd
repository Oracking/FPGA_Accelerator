library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity communication_module is
    Port (
        JC : in std_logic_vector(3 downto 0);
        arduino_signal: in std_logic;
        arduino_ready: in std_logic;
        
        clk: in std_logic;
        
        done: out std_logic;
        fpga_ready: out std_logic;
        result: out std_logic_vector(1 downto 0);
        
        led : out std_logic_vector(7 downto 0); -- Debug
        seg: out std_logic_vector(6 downto 0); -- Debug
        an: out std_logic_vector(3 downto 0); -- Debug
        dp: out std_logic -- Debug
    );
end communication_module;

architecture Behavioral of communication_module is
    component clock_divider
        Port ( 
            clk : in STD_LOGIC;
            refresh_clk : out STD_LOGIC;
            second_clk : out STD_LOGIC
        );
    end component;
    
    component display
        Port ( 
            A : in STD_LOGIC_VECTOR(3 downto 0);
            B : in STD_LOGIC_VECTOR(3 downto 0);
            C : in STD_LOGIC_VECTOR(3 downto 0);
            D : in STD_LOGIC_VECTOR(3 downto 0);
            E : in STD_LOGIC;
            CLK: in STD_LOGIC;
            seg: out STD_LOGIC_VECTOR(6 downto 0);
            an: out STD_LOGIC_VECTOR(3 downto 0);
            dp: out STD_LOGIC
        );
    end component;

    signal input_vector : std_logic_vector(15 downto 0) := "0000000000000000";
    signal i: integer := 0;
    signal refresh_clk: std_logic;
    signal unused: std_logic_vector(7 downto 0);
    
    signal state: std_logic := '1';
    signal arduino_signal_buffer : std_logic := '0';
    
    signal done_signal: std_logic := '1';
    signal done_counter: std_logic_vector(5 downto 0) := "111111"; 
    
    
begin

    CD1: clock_divider port map(clk => clk, refresh_clk => refresh_clk, second_clk => unused(0));
    
    D1: display port map(
        A => input_vector(15 downto 12), B => input_vector(11 downto 8), C => input_vector(7 downto 4), D => input_vector(3 downto 0),
        E => '1', clk => refresh_clk, seg => seg, an => an, dp => dp 
    );

    led(3 downto 0) <= JC;
    led(4) <= arduino_ready;
    led(7 downto 5) <= "000";
    
    done <= done_signal;

    fpga_ready <= '1';
    result <= "10";

    process(clk)
    variable temp_arduino_signal_buffer: std_logic;
    variable temp_input_value: std_logic_vector(3 downto 0);
    begin
        if(rising_edge(clk)) then
            if (state = '1' and done_signal = '0') then
                if (done_counter < "111111") then
                    done_counter <= done_counter + 1;
                else
                    done_signal <= '1';
                end if;
            end if;
        
            if (arduino_ready = '0') then
                i <= 0;
                state <= '1';
            elsif (arduino_signal_buffer = '0' and arduino_signal = '1') then
                state <= '0';
                done_signal <= '0';
            elsif (state = '0') then
                temp_input_value :=  JC;
                input_vector(i+3 downto i) <= temp_input_value;
                if i < 12 then
                    i <= i + 4;
                else   
                    i <= 0;
                end if;
                done_counter <= "000000";
                state <= '1';
            end if;
            
            if (arduino_signal = '1' or arduino_signal = '0') then
                temp_arduino_signal_buffer := arduino_signal;
                arduino_signal_buffer <= temp_arduino_signal_buffer;
            end if;
            
        end if;
    end process;
    

end Behavioral;