----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2025 06:39:29 PM
-- Design Name: 
-- Module Name: banc_registre - Behavioral
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

entity banc_registre is
    Port ( i_clk          : in std_logic;
           i_reset        : in std_logic; 
           i_addr_reg     : in STD_LOGIC_VECTOR (1 downto 0);
           i_val_reg      : in STD_LOGIC_VECTOR (9 downto 0);
           i_we_reg       : in STD_LOGIC;
           
           o_offset_x     : out STD_LOGIC_VECTOR (9 downto 0);
           o_offset_y     : out STD_LOGIC_VECTOR (9 downto 0));
end banc_registre;

architecture Behavioral of banc_registre is

signal o_offset_x_initial: std_logic_vector(9 downto 0) := (others => '0');
signal o_offset_y_initial: std_logic_vector(9 downto 0) := (others => '0');

begin

process(i_clk)
begin

    if rising_edge(i_clk) then
        if i_reset = '1' then
            o_offset_x_initial    <= "0000000000";
            o_offset_y_initial    <= "0000000000";
        elsif (i_we_reg = '1') then
           if (i_addr_reg(0) = '1') then
                o_offset_x_initial <= i_val_reg;
           end if;
           if(i_addr_reg(1) = '1') then
                o_offset_y_initial <= i_val_reg;
           end if;
                   
        end if;
    
    end if;


end process;

    o_offset_x <= o_offset_x_initial;
    o_offset_y <= o_offset_y_initial;

end Behavioral;
