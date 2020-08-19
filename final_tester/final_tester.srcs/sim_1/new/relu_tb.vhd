----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/31/2020 05:43:39 PM
-- Design Name: 
-- Module Name: relu_tb - Behavioral
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

entity relu_tb is
--  Port ( );
end relu_tb;

architecture Behavioral of relu_tb is
    component relu is
        Port ( 
            input: in fixed_point;
            reset: in std_logic;
            clk: in std_logic;
            result: out fixed_point;
            done: out std_logic 
        );
    end component;
    
    signal input, result: fixed_point;
    signal reset, clk, done: std_logic;
    
begin

    UUT: relu port map(input => input, reset => reset, clk => clk, result => result, done => done); 
    
    process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;
    
    
    process
    begin
        input <= "0000001100000000";
        reset <= '1';
        wait for 5 ns;
        reset <= '0';
        wait for 20 ns;
        input <= "1010000000000000";
        wait for 100 ns;
        
        input <= "1000001100000000";
        reset <= '1';
        wait for 5 ns;
        reset <= '0';
        wait for 20 ns;
        input <= "1010000000000000";
        wait for 100 ns;
        
    end process;

end Behavioral;
