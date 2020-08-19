----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/01/2020 11:05:03 AM
-- Design Name: 
-- Module Name: top_assembler - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.configuration_pack.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_assembler is
--  Port ( );
end top_assembler;

architecture Behavioral of top_assembler is
    component MMSU_1 is
      Port ( 
        a : in layer_2_w;
        b : in layer_2_in;
        reset: in std_logic;
        clk: in std_logic;
        random_number: in rounding_bits;
        done: out std_logic;
        c_buffer_out: out unrounded_layer_2_out;
        c : out layer_3_in
      );
    end component;
    
    component rounding_bits_generator is
      Port ( 
        clk: in std_logic;
        random_rounding_bits: out rounding_bits;
        done: out std_logic
      );
    end component;
    
    component VRELU_1 is
      Port ( 
        input: in layer_3_in;
        reset: in std_logic;
        clk: in std_logic;
        done: out std_logic;
        result: out layer_3_in
      );
    end component;
    
begin

    

end Behavioral;
