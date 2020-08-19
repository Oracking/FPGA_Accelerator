library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.configuration_pack.all;

entity rounding_bits_generator_tb is

end rounding_bits_generator_tb;

architecture Behavioral of rounding_bits_generator_tb is
    
    component rounding_bits_generator is
        Port ( 
            clk: in std_logic;
            random_rounding_bits: out rounding_bits;
            done: out std_logic
        );
    end component;
    
    signal clk, done: std_logic;
    signal random_rounding_bits: rounding_bits;
    
begin

    UUT: rounding_bits_generator port map(clk => clk, random_rounding_bits => random_rounding_bits, done => done);
    
    process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

end Behavioral;
