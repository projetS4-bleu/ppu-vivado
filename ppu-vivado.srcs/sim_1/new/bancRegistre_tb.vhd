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

entity bancRegistre_tb is
--  Port ( );
end bancRegistre_tb;

architecture Behavioral of bancRegistre_tb is
component bancRegistre is
        Port ( 
           clk          : in std_logic;
           reset        : in std_logic;
           addr_reg     : in STD_LOGIC_VECTOR (1 downto 0);
           val_reg      : in STD_LOGIC_VECTOR (9 downto 0);
           we_reg       : in STD_LOGIC_VECTOR (9 downto 0);
           
           pixel_x      : inout STD_LOGIC_VECTOR (9 downto 0);
           pixel_y      : inout STD_LOGIC_VECTOR (9 downto 0);
           offset_x     : inout STD_LOGIC_VECTOR (9 downto 0);
           offset_y     : inout STD_LOGIC_VECTOR (9 downto 0));
end component;

signal i_clk                : std_logic := '0';
signal i_reset              : std_logic:='0';

signal i_addr_reg           :std_logic_vector(1 downto 0);
signal i_val_reg            :std_logic_vector(9 downto 0);
signal i_we_reg             :std_logic_vector(9 downto 0);


signal s_pixel_x            :std_logic_vector(9 downto 0);
signal s_pixel_y            :std_logic_vector(9 downto 0);
signal s_offset_x           :std_logic_vector(9 downto 0);
signal s_offset_y           :std_logic_vector(9 downto 0);

signal tb_expectted_value   :std_logic_vector(9 downto 0);
signal tb_register_modified :string(1 to 8);

constant clk_period         :time :=10ns;
constant period             :time :=10ns;

begin

uut: bancRegistre
Port map(                    
           clk               =>   i_clk,
           reset             =>   i_reset,
           addr_reg          =>   i_addr_reg,
           val_reg           =>   i_val_reg,      
           we_reg            =>   i_we_reg,       
                             
           pixel_x           =>   s_pixel_x,      
           pixel_y           =>   s_pixel_y,      
           offset_x          =>   s_offset_x,     
           offset_y          =>   s_offset_y     
);

--Clock artificiel
clk_process :process
   begin
        i_clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        i_clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;



process is
begin

--_ Initialisation des valeurs
tb_register_modified <="reset  i";
i_reset <='1';
wait for period;

i_reset <='0';
wait for period;

--Tests pour une seules valeurs modifiés
for i in 0 to 9 loop
    i_we_reg <=  "0000000000";
    i_addr_reg <= "00";
    i_val_reg <= "1111111111";
    i_we_reg(i) <=  '1';
    tb_register_modified <="offset_x";
    wait for period;
end loop;

for i in 0 to 9 loop
    i_we_reg <=  "0000000000";
    i_addr_reg <= "01";
    i_val_reg <= "1111111111";
    i_we_reg(i) <=  '1';
    tb_register_modified <="offset_y";
    wait for period;
end loop;

for i in 0 to 9 loop
    i_we_reg <=  "0000000000";
    i_addr_reg <= "10";
    i_val_reg <= "1111111111";
    i_we_reg(i) <=  '1';
    tb_register_modified <="pixel_x ";
    wait for period;
end loop;

for i in 0 to 9 loop
    i_we_reg <=  "0000000000";
    i_addr_reg <= "11";
    i_val_reg <= "1111111111";
    i_we_reg(i) <=  '1';
    tb_register_modified <="pixel_y ";
    wait for period;
end loop;


--_ Reset des valeurs
i_we_reg <=  "0000000000";
i_val_reg <= "0000000000";
tb_register_modified <="reset  1";
i_reset <='1';
wait for period;

i_reset <='0';
wait for period;

--Tests pour valeurs modifié deux valeurs
    i_addr_reg <= "00";
    i_val_reg <= "1111111111";
    i_we_reg <=  "0000000101";
    tb_register_modified <="offset_x";
    wait for period;
    
    i_addr_reg <= "01";
    i_val_reg <= "1111111111";
    i_we_reg <=  "0000000101";
    tb_register_modified <="offset_y";
    wait for period;    

    i_addr_reg <= "10";
    i_val_reg <= "1111111111";
    i_we_reg <=  "0000000101";
    tb_register_modified <="pixel_x ";
    wait for period;      
    
    i_addr_reg <= "11";
    i_val_reg <= "1111111111";
    i_we_reg <=  "0000000101";
    tb_register_modified <="pixel_y ";
    wait for period;      
    
--_ Reset des valeurs
i_we_reg <=  "0000000000";
i_val_reg <= "0000000000";
tb_register_modified <="reset  2";
i_reset <='1';
wait for period;

i_reset <='0';
wait for period;
    
    
    --Tests réécriture de 1 par des 0
for i in 0 to 9 loop
    i_addr_reg              <= "00";
    i_we_reg                <= "1111111111";
    i_val_reg               <= "1111111111";
    wait for period;
    i_we_reg                <= "0000000000";
    i_val_reg               <= "0000000000";
    i_we_reg(i)             <=  '1';
    tb_register_modified    <="offset_x";
    wait for period;
end loop;    

for i in 0 to 9 loop
    i_addr_reg              <= "01";
    i_we_reg                <= "1111111111";
    i_val_reg               <= "1111111111";
    wait for period;
    i_we_reg                <= "0000000000";
    i_val_reg               <= "0000000000";
    i_we_reg(i)             <=  '1';
    tb_register_modified    <="offset_y";
    wait for period;
end loop;

for i in 0 to 9 loop
    i_addr_reg              <= "10";
    i_we_reg                <= "1111111111";
    i_val_reg               <= "1111111111";
    wait for period;
    i_we_reg                <= "0000000000";
    i_val_reg               <= "0000000000";
    i_we_reg(i)             <=  '1';
    tb_register_modified    <="pixel_x ";
    wait for period;
end loop;

for i in 0 to 9 loop
    i_addr_reg              <= "11";
    i_we_reg                <= "1111111111";
    i_val_reg               <= "1111111111";
    wait for period;
    i_we_reg                <= "0000000000";
    i_val_reg               <= "0000000000";
    i_we_reg(i)             <=  '1';
    tb_register_modified    <="pixel_y ";
    wait for period;
end loop;     

end process;
end Behavioral;