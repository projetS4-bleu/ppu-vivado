----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/07/2025 03:17:00 PM
-- Design Name: 
-- Module Name: PaletteDeCouleur - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PaletteDeCouleur is
    Port (
    clk : in std_logic ;
    reset : in std_logic ;
    color_code : in std_logic_vector (3 downto 0); -- code couleur sélectionné
    color_code_next : in std_logic_vector (3 downto 0); -- code couleur a mettre a jour
    write_enable_color : in std_logic; -- signal d'ecriture pour mise a jour
    new_rgb : in std_logic_vector (23 downto 0); -- nouvelle valeur rgb
    rgb_color : out std_logic_vector(23 downto 0) -- sortie rgb 24 bits
     );
end PaletteDeCouleur;

architecture Behavioral of PaletteDeCouleur is

    type palette_couleur is array(0 to 15) of std_logic_vector (23 downto 0);
    signal palette : palette_couleur := (
        x"000000",  -- 0: Noir
        x"FFFFFF",  -- 1: Blanc
        x"FF0000",  -- 2: Rouge
        x"330000",  -- 3: Marron foncé
        x"660000",  -- 4: Brun foncé 
        x"663300",  -- 5: Brun
        x"800000",  -- 6: Marron
        x"808080",  -- 7: Gris
        x"E6E6FA",  -- 8: Lavande
        x"800080",  -- 9: Violet
        x"FDF5E6",  -- 10: Beige
        x"0000FF",  -- 11: Bleu
        x"FFFF00",  -- 12: Jaune
        x"FFA500",  -- 13: Orange
        x"87CEEB",  -- 14: Bleu ciel
        x"228B22"   -- 15: Vert foncé
    );
begin

 -- Processus pour la mise à jour de la palette et la sortie
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                palette(0) <= x"000000";  -- Noir
                palette(1) <= x"FFFFFF";  -- Blanc
                palette(2) <= x"FF0000";  -- Rouge
                palette(3) <= x"330000";  -- Marron fonc/
                palette(4) <= x"660000";  -- Brun foncé 
                palette(5) <= x"663300";  -- Brun
                palette(6) <= x"800000"; -- Marron
                palette(7) <= x"808080"; -- Gris
                palette(8) <= x"E6E6FA";  -- lavande
                palette(9) <= x"800080";  -- Violet
                palette(10) <= x"FDF5E6"; -- Beige
                palette(11) <= x"0000FF"; -- bleu
                palette(12) <= x"FFFF00"; -- jaune
                palette(13) <= x"FFA500"; --orange
                palette(14) <=  x"87CEEB"; -- bleu ciel
                palette(15) <= x"228B22"; -- vert foncé
            else
                -- Mise à jour de la palette si demandé
                if write_enable_color = '1' then
                    palette(to_integer(unsigned(color_code_next))) <= new_rgb;
                end if;
            end if;
            
            -- Sortie de la couleur actuelle
            rgb_color <= palette(to_integer(unsigned(color_code)));
        end if;
    end process;
end Behavioral;
