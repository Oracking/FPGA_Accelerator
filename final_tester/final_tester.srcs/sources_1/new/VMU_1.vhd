library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.configuration_pack.all;

Library UNISIM;
use UNISIM.vcomponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

use IEEE.STD_LOGIC_UNSIGNED.all;


entity VMU_1 is
  Port ( 
    weight_matrix_row : in layer_1_in;
    input_vector : in layer_1_in;
    bias: in fixed_point;
    clk : in std_logic;
    reset: in std_logic;
    random_rounding_bits : in rounding_bits;
    result : out fixed_point;
    done : out std_logic
  );
end VMU_1;

architecture Behavioral of VMU_1 is

    signal w_sig : fixed_point := (others => '0');
    signal in_sig : fixed_point := (others => '0');
    
    signal dsp_reset : std_logic := '0';
    signal dsp_enable: std_logic := '0';
    
    signal start: std_logic := '0';
    signal inverted_clk: std_logic;
    signal result_buffer: dsp_out_fixed_point := (others => '0');
    signal result_buffer_temp: dsp_out_fixed_point := (others => '0');
    
    signal i : integer := 0;

begin

    inverted_clk <= not clk;

    process(clk, reset)
    begin
        if (reset = '1') then
            start <= '0';
            dsp_reset <= '1';
            dsp_enable <= '1';
        elsif (rising_edge(clk)) then
            case start is
                when '0' =>
                    i <= 0;
                    done <= '0';
                    start <= '1';
                    dsp_reset <= '0';
                    dsp_enable <= '1';
                when others =>
                    case i is
                        when 0 to weight_matrix_row'length - 1 =>
                            w_sig <= weight_matrix_row(i);
                            in_sig <= input_vector(i);
                            i <= i + 1;
                        when weight_matrix_row'length =>
                            w_sig <= bias;
                            in_sig <= fixed_point_one;
                            i <= i + 1; 
                        when weight_matrix_row'length + 1 =>
                            result_buffer_temp <= (result_buffer + (rounding_extension & random_rounding_bits));
                            i <= i + 1;
                            dsp_enable <= '0';
                        when weight_matrix_row'length + 2 =>
                            if (signed(dsp_out_max_value) < signed(result_buffer_temp)) then
                                result <= fixed_point_max_positive;
                            elsif (signed(result_buffer_temp) < signed(dsp_out_min_value)) then
                                result <= fixed_point_max_negative;
                            else
                                result <= result_buffer_temp(rounding_slice_range_up downto rounding_slice_range_down);
                            end if;
                            done <= '1';
                        when others =>
                            done <= '1';
                            dsp_enable <= '0';
                    end case;
            end case; 
        end if;
    end process;
    

    MACC_MACRO_inst : MACC_MACRO
        generic map (
            DEVICE => "7SERIES",  -- Target Device: "VIRTEX5", "7SERIES", "SPARTAN6" 
            LATENCY => 1,         -- Desired clock cycle latency, 1-4
            WIDTH_A => fixed_point'length,        -- Multiplier A-input bus width, 1-25
            WIDTH_B => fixed_point'length,        -- Multiplier B-input bus width, 1-18     
            WIDTH_P => dsp_out_fixed_point'length)        -- Accumulator output bus width, 1-48
        port map (
            P => result_buffer,     -- MACC ouput bus, width determined by WIDTH_P generic 
            A => w_sig,     -- MACC input A bus, width determined by WIDTH_A generic 
            ADDSUB => '1', -- 1-bit add/sub input, high selects add, low selects subtract
            B => in_sig,           -- MACC input B bus, width determined by WIDTH_B generic 
            CARRYIN => '0', -- 1-bit carry-in input to accumulator
            CE => dsp_enable,      -- 1-bit active high input clock enable
            CLK => inverted_clk,    -- 1-bit positive edge clock input
            LOAD => '0', -- 1-bit active high input load accumulator enable
            LOAD_DATA => "000000000000000000000000000000000000000000000000", -- Load accumulator input data, 
                                  -- width determined by WIDTH_P generic
            RST => dsp_reset    -- 1-bit input active high reset
        );
    
end Behavioral;
