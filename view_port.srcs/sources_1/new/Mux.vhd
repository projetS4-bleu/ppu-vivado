----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/07/2025 11:47:07 PM
-- Design Name: 
-- Module Name: Mux - Behavioral
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

entity Mux is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           i_bg_color_code : in STD_LOGIC_VECTOR (3 downto 0); -- code couleur du background
           i_actor_color_code : in STD_LOGIC_VECTOR (3 downto 0); -- code couleur de l'acteur
           i_actor_valid : in STD_LOGIC; -- signal validite de lacteur
           o_color_code : out STD_LOGIC_VECTOR (3 downto 0)); -- code couleur selectione
end Mux;

architecture Behavioral of Mux is
    signal r_color_code: std_logic_vector (3 downto 0);
    
begin
    process(clk, reset)
    begin
        if reset = '1' then
                r_color_code <= (others => '0');
            elsif rising_edge(clk) then
                
                if i_actor_valid = '1' then
                    r_color_code <= i_actor_color_code;
                else
                    r_color_code <= i_bg_color_code;
                end if;
            end if;
    end process;
    
    o_color_code <= r_color_code;
end Behavioral;
