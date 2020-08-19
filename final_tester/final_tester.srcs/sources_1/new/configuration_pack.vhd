library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package configuration_pack is
    -- Base Types --
    constant fixed_point_word_length: integer := 16;
    constant dsp_out_fixed_point_length: integer := 48;
    constant rounding_bits_length: integer := 8;
    subtype fixed_point is std_logic_vector(fixed_point_word_length-1 downto 0);
    subtype dsp_out_fixed_point is std_logic_vector(dsp_out_fixed_point_length-1 downto 0);
    subtype rounding_bits is std_logic_vector(rounding_bits_length-1 downto 0);
    
    
    -- Constants --
    constant num_neurons_layer_0: integer := 3;
    constant num_neurons_layer_1: integer := 16;
    constant num_neurons_layer_3: integer := 16;
    constant num_neurons_layer_5: integer := 3;
    
    constant fixed_point_one: fixed_point := "0000000100000000";
    constant fixed_point_max_positive: fixed_point := (fixed_point_word_length-1 => '0', others => '1');
    constant fixed_point_max_negative: fixed_point := (fixed_point_word_length-1 => '1', others => '0');
    
    constant rounding_slice_range_up: integer := 23;
    constant rounding_slice_range_down: integer := 8;
    
    constant dsp_out_max_value: dsp_out_fixed_point := (rounding_slice_range_up - 1 downto 0 => '1', others => '0');
    constant dsp_out_min_value: dsp_out_fixed_point := (rounding_slice_range_up - 1 downto 0 => '0', others => '1');
    
    constant rounding_extension: std_logic_vector((dsp_out_fixed_point'length - rounding_bits'length - 1) downto 0) := (others => '0'); 

    -- Layer Input and Output Sizes --
    -- Layer 0 --
    type layer_0_out is array(integer range 0 to num_neurons_layer_0 - 1) of fixed_point;
    
    -- Layer 1 --
    subtype layer_1_in is layer_0_out;
    type layer_1_w is array(integer range 0 to num_neurons_layer_1 - 1) of layer_1_in;
    type layer_1_b is array(integer range 0 to num_neurons_layer_1 - 1) of fixed_point;
    type unrounded_layer_1_out is array(integer range 0 to num_neurons_layer_1 - 1) of dsp_out_fixed_point;
    type layer_1_out is array(integer range 0 to num_neurons_layer_1 - 1) of fixed_point;
    
    -- Layer 2 --
    subtype layer_2_in is layer_1_out;
    subtype layer_2_out is layer_2_in;
    
    -- Layer 3 --
    subtype layer_3_in is layer_2_out;
    type layer_3_w is array(integer range 0 to num_neurons_layer_3 - 1) of layer_3_in;
    type layer_3_b is array(integer range 0 to num_neurons_layer_3 - 1) of fixed_point;
    type unrounded_layer_3_out is array(integer range 0 to num_neurons_layer_3 - 1) of dsp_out_fixed_point;
    type layer_3_out is array(integer range 0 to num_neurons_layer_3 - 1) of fixed_point;
    
    -- Layer 4 --
    subtype layer_4_in is layer_3_out;
    subtype layer_4_out is layer_4_in;
    
    -- Layer 5 --
    subtype layer_5_in is layer_4_out;
    type layer_5_w is array(integer range 0 to num_neurons_layer_5 - 1) of layer_5_in;
    type layer_5_b is array(integer range 0 to num_neurons_layer_5 - 1) of fixed_point;
    type unrounded_layer_5_out is array(integer range 0 to num_neurons_layer_5 - 1) of dsp_out_fixed_point;
    type layer_5_out is array(integer range 0 to num_neurons_layer_5 - 1) of fixed_point;
    
    -- Layer 6 --
    subtype layer_6_in is layer_5_out;
    subtype layer_6_out is layer_6_in;
      
end package;