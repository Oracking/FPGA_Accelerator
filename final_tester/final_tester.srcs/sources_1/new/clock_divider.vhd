library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity clock_divider is
    Port ( clk : in STD_LOGIC;
           refresh_clk : out STD_LOGIC;
           second_clk : out STD_LOGIC);
end clock_divider;

architecture Behavioral of clock_divider is
    signal refresh_clock: STD_LOGIC_VECTOR(18 downto 0);
    signal second_clock: STD_LOGIC;
    
    signal intermittent_second_divider: STD_LOGIC_VECTOR(6 downto 0);
    signal second_counter: STD_LOGIC_VECTOR(18 downto 0);
    
begin

    refresh_clk <= refresh_clock(18);
    second_clk <= second_clock;

    process(clk)
    begin
        if(rising_edge(clk)) then
            if refresh_clock < "1111111111111111111" then
                refresh_clock <= refresh_clock + 1;
            else
                refresh_clock <= "0000000000000000000";
            end if;
        end if;
    end process;
    
    
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (intermittent_second_divider < "1111111") then
                intermittent_second_divider <= intermittent_second_divider + 1;
            else
                intermittent_second_divider <= "0000000";
            end if;
        end if;
    end process;
    
    
    process(intermittent_second_divider(6))
    begin
        if (rising_edge(intermittent_second_divider(6))) then
            if (second_counter < "1011111010111100000") then
                second_counter <= second_counter + 1;
            else
                second_counter <= "0000000000000000000";
                second_clock <= second_clock xor '1';
            end if;
        end if;
    end process;


end Behavioral;