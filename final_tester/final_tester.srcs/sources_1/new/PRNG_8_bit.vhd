library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity PRNG_8_bit is
  Port ( 
    clk: in std_logic;
    random_bit: out std_logic;
    done: out std_logic
  );
end PRNG_8_bit;

architecture Behavioral of PRNG_8_bit is
    signal seed : std_logic_vector(7 downto 0) := "10001101";
    signal sig_random_number: std_logic_vector(7 downto 0) := "10001000";
begin

    random_bit <= sig_random_number(0);
    done <= not clk;
    
    process(clk)
    variable leading_bit: std_logic := '0';
    begin
        if rising_edge(clk) then
            leading_bit := sig_random_number(7) xor sig_random_number(3) xor sig_random_number(2) xor sig_random_number(0);
            sig_random_number <= leading_bit & sig_random_number(7 downto 1);
        end if;
    end process;

end Behavioral;
