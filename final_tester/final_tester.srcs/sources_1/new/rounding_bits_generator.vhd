library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.configuration_pack.all;

entity rounding_bits_generator is
  Port ( 
    clk: in std_logic;
    random_rounding_bits: out rounding_bits;
    done: out std_logic
  );
end rounding_bits_generator;

architecture Behavioral of rounding_bits_generator is

    component PRNG_8_bit is
        Port ( 
            clk: in std_logic;
            random_bit: out std_logic;
            done: out std_logic
        );
    end component;
    
    signal sig_PRNG_generated_bit: std_logic;
    signal sig_PRNG_done : std_logic;
    
    signal sig_generated_bits: rounding_bits := (others => '0');
    
begin

    done <= not clk;
    random_rounding_bits <= sig_generated_bits;

    PRNG_1: PRNG_8_bit port map(clk => clk, random_bit => sig_PRNG_generated_bit, done => sig_PRNG_done);

    process(sig_PRNG_done)
    begin
        if rising_edge(sig_PRNG_done) then
            sig_generated_bits <= (sig_PRNG_generated_bit & sig_generated_bits(sig_generated_bits'length-1 downto 1));
        end if;
    end process;

end Behavioral;
