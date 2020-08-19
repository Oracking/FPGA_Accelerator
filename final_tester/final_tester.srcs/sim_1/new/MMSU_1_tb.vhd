library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.configuration_pack.all;

entity MMSU_1_tb is
--  Port ( );
end MMSU_1_tb;

architecture Behavioral of MMSU_1_tb is
    component MMSU_1
      Port ( 
        weight_matrix : in layer_2_w;
        input_vector : in layer_2_in;
        bias_vector: in layer_2_b;
        reset: in std_logic;
        clk: in std_logic;
        random_rounding_bits: in rounding_bits;
        done: out std_logic;
        result_buffer_out: out unrounded_layer_2_out;
        result : out layer_3_in;
        max_value: out dsp_out_fixed_point;
        min_value: out dsp_out_fixed_point
      );
    end component;
    
    component rounding_bits_generator is
      Port ( 
        clk: in std_logic;
        random_rounding_bits: out rounding_bits;
        done: out std_logic
      );
    end component;
    
    
    signal weight_matrix: layer_2_w;
    signal input_vector: layer_2_in;
    signal bias_vector: layer_2_b;
    signal reset: std_logic := '0';
    signal clk: std_logic := '0';
    signal done: std_logic := '0';
    signal random_rounding_bits: rounding_bits;
    signal result_buffer_out: unrounded_layer_2_out;
    signal result: layer_3_in; 
    signal max_value, min_value: dsp_out_fixed_point;
    
    signal generator_done: std_logic;
    
begin

    GENERATOR: rounding_bits_generator port map(clk => clk, random_rounding_bits => random_rounding_bits, done => generator_done);

    UUT: MMSU_1 port map(weight_matrix => weight_matrix, input_vector => input_vector, bias_vector => bias_vector, 
                         reset => reset, clk => clk, random_rounding_bits => random_rounding_bits, done => done, 
                         result => result, result_buffer_out => result_buffer_out, max_value => max_value, 
                         min_value => min_value);
                         
    
    
    weight_matrix <= (("1111110111110101","1111100011000101","1111011111111110"),
("1111011101001010","1111000110101001","0000011101001010"),
("0000101010001000","1111100100100011","0000001000110010"),
("0000111100000101","0000100001111011","1111101111000010"),
("0000010101110101","1111110101001011","1111111001011111"),
("1111010010110101","0000000110100011","0000010000110100"),
("0000100011111010","1111011000001100","1111111100011011"),
("1111101000111100","1111010111010001","1111100111010111"),
("1111100111000100","0000001010001111","1111010110100101"),
("0000100010010101","0000010111000111","1111000110110011"),
("0000010010100001","1111000100100000","0000101001110111"),
("1111011010011001","0000011100001001","1111100100011110"),
("1111110001111001","1111011011010011","0000110100000100"),
("0000001000100100","0000100000001000","1111110101101001"),
("0000101101010110","0000010010101000","1111111001001111"),
("1111000101110001","0000110011001101","1111001110110100"));
    
    input_vector <=  ("0000100010101011","1111111001000111","1111101010111110");
    
    
    bias_vector <=  ("0000010001000000","1111110100110100","1111010001010010",
"1111000001010101","0000101110100111","1111010011001101",
"1111100111110011","0000011000111101","0000010010001011",
"1111000110011011","1111111000011011","0000111111111011",
"0000010011111101","0000010110110111","1111100101100101",
"1111001111001001");
    
    
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
        wait for 10ns;
        reset <= '0';
        wait for 100ns;
    
    end process;
    


end Behavioral;