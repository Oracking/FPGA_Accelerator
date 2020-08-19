library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.configuration_pack.all;

entity VRELU_6 is
  Port ( 
    input: in layer_6_in;
    reset: in std_logic;
    clk: in std_logic;
    done: out std_logic;
    result: out layer_6_out
  );
end VRELU_6;

architecture Behavioral of VRELU_6 is

    signal done_vector: std_logic_vector(result'length-1 downto 0);
    signal done_vector_value: std_logic_vector(result'length-1 downto 0) := (others => '1');
    
    component relu is
      Port ( 
        input: in fixed_point;
        reset: in std_logic;
        clk: in std_logic;
        result: out fixed_point;
        done: out std_logic 
      );
    end component;

begin

    single_relu_generate: for i in 0 to result'length-1 generate
        scalar_relu: relu port map(
            input =>input(i),
            reset => reset,
            clk => clk,
            result => result(i),
            done => done_vector(i)
        );
    end generate single_relu_generate;
    
    process(done_vector)
    begin
        if (done_vector = done_vector_value) then
            done <= '1';
        else
            done <= '0';
        end if;
    end process;

end Behavioral;
