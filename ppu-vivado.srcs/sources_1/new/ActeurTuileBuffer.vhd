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
           i_tuile_id : in STD_LOGIC_VECTOR (5 downto 0);
           i_tuile_pixel_x : in STD_LOGIC_VECTOR (2 downto 0);
           i_tuile_pixel_y : in STD_LOGIC_VECTOR (2 downto 0);
           i_we : in std_logic;
           i_write_color_code : in STD_LOGIC_VECTOR (3 downto 0);
           i_write_color_code_pos : in STD_LOGIC_VECTOR (11 downto 0);
           o_color_code : out STD_LOGIC_VECTOR (3 downto 0));
end ActeurTuileBuffer;

architecture Behavioral of ActeurTuileBuffer is
    constant c_pixel_nb_cols : integer := 8;
    constant c_pixel_nb_rows : integer := 8;
    constant c_nb_acteur_tuiles_px : integer := 64 * c_pixel_nb_cols * c_pixel_nb_rows;    -- 64 tuiles x nb_pixels/tuile
    
    type t_vram_buffer_type is array (0 to (c_nb_acteur_tuiles_px)-1) of std_logic_vector(3 downto 0);
    signal r_acteur_tuile_buffer : t_vram_buffer_type := (others => (others => '0'));

    signal s_pixel_col : unsigned(2 downto 0);
    signal s_pixel_row : unsigned(2 downto 0);
    signal s_tuile_id : unsigned(11 downto 0);
    signal s_pixel_index : integer range 0 to (c_nb_acteur_tuiles_px)-1;
    
    signal s_write_pixel_col : unsigned(2 downto 0);
    signal s_write_pixel_row : unsigned(2 downto 0);
    signal s_write_tuile_id : unsigned(11 downto 0);
    signal s_write_pixel_index : integer range 0 to (c_nb_acteur_tuiles_px)-1;

begin
    s_pixel_col <= unsigned(i_tuile_pixel_x);
    s_pixel_row <= unsigned(i_tuile_pixel_y);
    s_tuile_id <= shift_left(unsigned(i_tuile_id), 6); -- tuile_id x 64 px/tuiles
    s_pixel_index <= to_integer(s_tuile_id + s_pixel_col + s_pixel_row * c_pixel_nb_rows);
    
    s_write_tuile_id <= shift_left(unsigned(i_write_color_code_pos(11 downto 6)), 6) ;
    s_write_pixel_col <= unsigned(i_write_color_code_pos(5 downto 3));
    s_write_pixel_row <= unsigned(i_write_color_code_pos(2 downto 0));
    s_write_pixel_index <= to_integer(s_write_tuile_id + s_write_pixel_col + s_write_pixel_row * c_pixel_nb_rows);

    process (clk, reset)
        begin
            if reset = '1' then
                r_acteur_tuile_buffer <= (others => (others => '0'));
            elsif rising_edge(clk) then
                if i_we = '1' then
                    r_acteur_tuile_buffer(s_write_pixel_index) <= i_write_color_code;
                end if;
                o_color_code <= r_acteur_tuile_buffer(s_pixel_index);
            end if;
        end process;

end Behavioral;
