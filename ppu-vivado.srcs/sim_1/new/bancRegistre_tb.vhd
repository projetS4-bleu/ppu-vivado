----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2025 06:47:15 PM
-- Design Name: 
-- Module Name: banc_registre_tb - Behavioral
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

entity BancRegistre_tb is
--  Port ( );
end BancRegistre_tb;

architecture Behavioral of BancRegistre_tb is
component BancRegistre is
        Port ( 
           clk          : in std_logic;
           reset        : in std_logic; 
           i_addr_reg   : in STD_LOGIC_VECTOR (0 downto 0);
           i_val_reg    : in STD_LOGIC_VECTOR (9 downto 0);
           i_we         : in std_logic;
           
           o_offset_x   : out STD_LOGIC_VECTOR (9 downto 0);
           o_offset_y   : out STD_LOGIC_VECTOR (9 downto 0));
end component;

signal i_addr_reg           :std_logic_vector(0 downto 0);
signal i_val_reg            :std_logic_vector(9 downto 0);
signal i_we_reg             :std_logic;
signal i_reset              : std_logic:='0';

signal o_offset_x           :std_logic_vector(9 downto 0);
signal o_offset_y           :std_logic_vector(9 downto 0);

signal tb_expectted_value   :std_logic_vector(9 downto 0);
signal tb_register_modified :string(1 to 8);

signal clk                : std_logic := '0';
constant clk_period         :time :=10ns;
constant period             :time :=10ns;

begin

uut:BancRegistre
Port map(                    
           clk               =>   clk,
           reset             =>   i_reset,
           i_addr_reg          =>   i_addr_reg,
           i_val_reg           =>   i_val_reg,      
           i_we            =>   i_we_reg,
                                  
           o_offset_x          =>   o_offset_x,     
           o_offset_y          =>   o_offset_y     
);

--Clock artificiel
clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;



process is
begin

--Tests pour une seules valeurs modifi?s
i_addr_reg <="0";
i_val_reg <= "0000000000";
i_we_reg<='1';
tb_expectted_value  <= "0000000000";
tb_register_modified<="offset_x";

wait for period;

i_addr_reg          <="1";
i_val_reg           <= "0101010101";
i_we_reg<='1';
tb_expectted_value  <= "0101010101";
tb_register_modified<="offset_y";
wait for period;

--Tests r?criture sur d'ancienne valeurs dans le registre
i_addr_reg <="0";
i_val_reg <= "1111111111";
i_we_reg<='1';
tb_expectted_value  <= "1111111111";
tb_register_modified<="offset_x";

wait for period;

i_addr_reg          <="1";
i_val_reg           <= "1111100000";
i_we_reg<='1';
tb_expectted_value  <= "1111100000";
tb_register_modified<="offset_y";
wait for period;

--Tests reset
tb_register_modified<="reset+we";
i_reset <= '1';
i_we_reg<='0';
wait for period;

i_reset <= '0';
wait for period;

end process;

end Behavioral;