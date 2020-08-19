----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/01/2020 09:44:04 PM
-- Design Name: 
-- Module Name: test_component_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_component_tb is
--  Port ( );
end test_component_tb;

architecture Behavioral of test_component_tb is

    component test_component is
      Port ( 
        a: in std_logic_vector(7 downto 0);
        b: in std_logic_vector(7 downto 0);
        clk: in std_logic;
        c: out std_logic
      );
    end component;
    
    signal a, b: std_logic_vector(7 downto 0);
    signal clk, c: std_logic;

begin

    UUT: test_component port map(a => a, b => b, clk => clk, c => c);
    
    process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;
    
    process
    begin
        a <= "00010000";
        b <= "00010000";
        
        wait for 10 ns;
        
        a <= "00010000";
        b <= "00001000";
        
        wait for 10 ns;
        
        a <= "00010000";
        b <= "10000000";
        
        wait for 10 ns;
        
        a <= "11110000";
        b <= "10001000";
        
        wait for 100 ns;

    end process;

end Behavioral;
