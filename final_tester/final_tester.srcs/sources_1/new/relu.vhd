library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.configuration_pack.all;

entity relu is
  Port ( 
    input: in fixed_point;
    reset: in std_logic;
    clk: in std_logic;
    result: out fixed_point;
    done: out std_logic 
  );
end relu;
    
architecture Behavioral of relu is
    signal start: integer := 0;
begin

    process(clk, reset)
    begin
        if (reset = '1') then
            done <= '0';
            start <= 0;
        elsif (rising_edge(clk)) then
            if (start = 0) then
            
                case input(15) is
                    when '1' =>
                        result <= (others => '0');
                    when others =>
                        result <= input;
                end case;
                
                start <= 1;
                done <= '1';
            end if;
        end if;
    end process;

end Behavioral;
