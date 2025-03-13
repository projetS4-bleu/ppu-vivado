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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BancRegistre is
    Port ( clk          : in std_logic;
           reset        : in std_logic; 
           i_addr_reg   : in STD_LOGIC_VECTOR (0 downto 0);
           i_val_reg    : in STD_LOGIC_VECTOR (9 downto 0);
           i_we         : in std_logic;
           
           o_offset_x   : out STD_LOGIC_VECTOR (9 downto 0);
           o_offset_y   : out STD_LOGIC_VECTOR (9 downto 0));
end BancRegistre;

architecture Behavioral of BancRegistre is
type t_vram_registre is array (natural range <>) of std_logic_vector (9 downto 0);
signal r_reg : t_vram_registre(0 to 1) := (others => (others => '0'));
signal s_offset_x: std_logic_vector(9 downto 0) := (others => '0');
signal s_offset_y: std_logic_vector(9 downto 0) := (others => '0');

begin

process(clk, reset)
    begin
        if reset = '1' then
            r_reg <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if i_we = '1' then
                r_reg(to_integer(unsigned(i_addr_reg))) <= i_val_reg;
            end if;
            if i_addr_reg = "0" then
                s_offset_x <= r_reg(to_integer(unsigned(i_addr_reg)));
                s_offset_y <= "0000000000";
            else
                s_offset_y <= r_reg(to_integer(unsigned(i_addr_reg)));
                s_offset_x <= "0000000000";
            end if;
        end if;
    end process;
    
    o_offset_x <= s_offset_x;
    o_offset_y <= s_offset_y;

    

end Behavioral;
