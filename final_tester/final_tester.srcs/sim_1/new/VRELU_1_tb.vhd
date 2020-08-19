library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.configuration_pack.all;

entity VRELU_1_tb is
--  Port ( );
end VRELU_1_tb;

architecture Behavioral of VRELU_1_tb is

    component VRELU_1 is
      Port ( 
        input: in layer_3_in;
        reset: in std_logic;
        clk: in std_logic;
        done: out std_logic;
        result: out layer_3_in
      );
    end component;
    
    signal reset, clk, done : std_logic;
    signal input, result: layer_3_in;
    
begin

    UUT: VRELU_1 port map(input => input, reset => reset, clk => clk, done => done, result => result);


    input <= ("1000000000000000","0001111000101110","1000101111110110",
"0111111111111111","1010101110001000","0111111111111111",
"0101100110011100","1001110110101111","1000000000000000",
"1000000000000000","1111011110010111","1000000000000000",
"1001011010111000","0111110110101101","0111111111111111",
"0111110101111100");
    
    
    process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;
    
    process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 100 ns;
    end process;

end Behavioral;
