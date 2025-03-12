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

entity bancRegistre is
    Port ( clk          : in std_logic;
           reset        : in std_logic; 
           addr_reg     : in STD_LOGIC_VECTOR (1 downto 0);
           val_reg      : in STD_LOGIC_VECTOR (9 downto 0);
           we_reg       : in STD_LOGIC_VECTOR (9 downto 0);
           
           pixel_x      : inout STD_LOGIC_VECTOR (9 downto 0);
           pixel_y      : inout STD_LOGIC_VECTOR (9 downto 0);
           offset_x     : inout STD_LOGIC_VECTOR (9 downto 0);
           offset_y     : inout STD_LOGIC_VECTOR (9 downto 0));
end bancRegistre;

architecture Behavioral of bancRegistre is
signal reset_vector : STD_LOGIC_VECTOR (9 downto 0);
begin

process(clk)
begin
    
    if rising_edge(clk) then
        if reset = '1' then
            pixel_x     <= "0000000000";
            pixel_y     <= "0000000000";
            offset_x    <= "0000000000";
            offset_y    <= "0000000000";
            --Logique inverser pour sauver un NOT dans le case
            reset_vector<= "0000000000";
        else
           reset_vector <= "1111111111";
           case (addr_reg) is
                 when "00" =>
                    offset_x <= ((offset_x and not(we_reg)) or (val_reg and we_reg)) and reset_vector;
                 when "01" =>
                    offset_y <= ((offset_y and not(we_reg)) or (val_reg and we_reg))and reset_vector;
                 when "10" =>
                    pixel_x <= ((pixel_x and not(we_reg)) or (val_reg and we_reg))and reset_vector;
                 when "11" =>
                    pixel_y <= ((pixel_y and not(we_reg)) or (val_reg and we_reg))and reset_vector;
                 when others =>
        end case; 
        end if;
    
        
    
    end if;
        


end process;

end Behavioral;
