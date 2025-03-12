----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/04/2025 12:51:49 PM
-- Design Name: 
-- Module Name: ActeurTuileBuffer - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ActeurTuileBuffer is
    Port ( clk : in std_logic;
           reset : in std_logic;
           tuile_id : in STD_LOGIC_VECTOR (5 downto 0);
           tuile_pixel_x : in STD_LOGIC_VECTOR (2 downto 0);
           tuile_pixel_y : in STD_LOGIC_VECTOR (2 downto 0);
           we_color_code : in std_logic;
           new_color_code : in STD_LOGIC_VECTOR (3 downto 0);
           new_color_code_pos : in STD_LOGIC_VECTOR (11 downto 0);
           color_code : out STD_LOGIC_VECTOR (3 downto 0));
end ActeurTuileBuffer;

architecture Behavioral of ActeurTuileBuffer is
    constant pixel_cols : integer := 8;
    constant pixel_rows : integer := 8;
    constant nb_pixels  : integer := pixel_cols * pixel_rows;
    constant nb_acteur_tuiles : integer := 64 * nb_pixels;
    
    type t_vram_buffer_type is array (0 to (nb_acteur_tuiles)-1) of std_logic_vector(3 downto 0);
    signal r_acteur_tuile_buffer : t_vram_buffer_type := (others => (others => '0'));

    signal s_pixel_col : unsigned(2 downto 0);
    signal s_pixel_row : unsigned(2 downto 0);
    signal s_acteur_tuile : unsigned(5 downto 0);
    
    signal s_new_pixel_col : unsigned(2 downto 0);
    signal s_new_pixel_row : unsigned(2 downto 0);
    signal s_new_acteur_tuile : unsigned(5 downto 0);
    
    signal s_tuile_index : integer range 0 to (nb_acteur_tuiles)-1;
begin
    s_pixel_col <= unsigned(tuile_pixel_x);
    s_pixel_row <= unsigned(tuile_pixel_y);
    s_acteur_tuile <= unsigned(tuile_id);
    s_tuile_index <= to_integer(s_acteur_tuile + s_pixel_col + s_pixel_row * pixel_rows);
    
    process (clk, reset)
        begin
            if reset = '1' then
                r_acteur_tuile_buffer <= (others => (others => '0'));
            elsif rising_edge(clk) then
                if we_color_code = '1' then
                    s_new_acteur_tuile <= unsigned(new_color_code_pos(11 downto 6));
                    s_new_pixel_col <= unsigned(new_color_code_pos(5 downto 3));
                    s_new_pixel_row <= unsigned(new_color_code_pos(2 downto 0));
                    r_acteur_tuile_buffer(to_integer(s_new_acteur_tuile + s_new_pixel_col + s_new_pixel_row * pixel_rows))
                         <= new_color_code;
                end if;
                
                -- Lecture de la couleur à cette adresse
                color_code <= r_acteur_tuile_buffer(s_tuile_index);
            end if;
        end process;

end Behavioral;
