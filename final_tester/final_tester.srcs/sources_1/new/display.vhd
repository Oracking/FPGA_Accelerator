library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
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
end display;

architecture Behavioral of display is
    signal anode: STD_LOGIC_VECTOR(3 downto 0) := "1110";
    signal to_write: STD_LOGIC_VECTOR(3 downto 0) := A;
begin
    
    an <= anode;
    dp <= E;

    process(CLK)
    begin
        if(rising_edge(CLK)) then
            case anode is
                when "1110" =>
                    to_write <= C;
                    anode <= "1101";
                when "1101" =>
                    to_write <= D;
                    anode <= "1011";
                when "1011" =>
                    to_write <= A;
                    anode <= "0111";
                when others =>
                    to_write <= B;
                    anode <= "1110";
            end case;
        end if;
    end process;
    
    process(CLK)
    begin
        if (rising_edge(CLK)) then
            case to_write is
                when "0000" => seg <= "1000000";
                when "0001" => seg <= "1111001";
                when "0010" => seg <= "0100100";
                when "0011" => seg <= "0110000";
                when "0100" => seg <= "0011001";
                when "0101" => seg <= "0010010";
                when "0110" => seg <= "0000010";
                when "0111" => seg <= "1111000";
                when "1000" => seg <= "0000000";
                when "1001" => seg <= "0010000";
                
                when "1010" => seg <= "1000000";
                when "1011" => seg <= "1111001";
                when "1100" => seg <= "0100100";
                when "1101" => seg <= "0110000";
                when "1110" => seg <= "0011001";
                when "1111" => seg <= "0010010";
                when others => seg <= "0010000";
            end case;
        end if;
    end process;

end Behavioral;