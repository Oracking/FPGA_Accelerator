library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PRNG_8_bit_tb is
    
end PRNG_8_bit_tb;

architecture Behavioral of PRNG_8_bit_tb is

    component PRNG_8_bit is
      Port ( 
        clk: in std_logic;
        random_number: out std_logic;
        done: out std_logic
      );
    end component;
    
    signal clk, random_number, done: std_logic;

begin

    UUT: PRNG_8_bit port map(clk => clk, random_number => random_number, done => done);
    
    process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

end Behavioral;
