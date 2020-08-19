library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.configuration_pack.all;

Library UNISIM;
use UNISIM.vcomponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

use IEEE.STD_LOGIC_UNSIGNED.all;

entity MMSU_5 is
  Port ( 
    weight_matrix : in layer_5_w;
    input_vector : in layer_5_in;
    bias_vector: in layer_5_b;
    reset: in std_logic;
    clk: in std_logic;
    random_rounding_bits: in rounding_bits;
    done: out std_logic;
    result : out layer_5_out
  );
end MMSU_5;
    
    
architecture Behavioral of MMSU_5 is

    component VMU_5
        Port ( 
            weight_matrix_row : in layer_5_in;
            input_vector : in layer_5_in;
            bias: in fixed_point;
            clk : in std_logic;
            reset: in std_logic;
            random_rounding_bits: in rounding_bits;
            result: out fixed_point;
            done: out std_logic
        );
    end component;
    
    signal done_vector: std_logic_vector(result'length-1 downto 0);
    signal c_buffer: unrounded_layer_5_out;
    constant done_vector_value: std_logic_vector(result'length-1 downto 0) := (others => '1');
    
begin

    single_vector_multiplier_generate: for i in 0 to result'length-1 generate
        vector_multiply: VMU_5 port map(
            weight_matrix_row => weight_matrix(i),
            input_vector => input_vector,
            bias => bias_vector(i),
            clk => clk,
            reset => reset,
            random_rounding_bits => random_rounding_bits,
            result => result(i),
            done => done_vector(i)
        );
    end generate single_vector_multiplier_generate;
        
        
    process(reset, done_vector)
    begin
        if (reset = '1') then
            done <= '0';
        elsif (done_vector = done_vector_value) then
            done <= '1';
        else
            done <= '0';
        end if;
    end process;
    
end Behavioral;
