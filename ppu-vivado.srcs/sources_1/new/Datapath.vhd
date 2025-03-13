----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2025 06:20:42 AM
-- Design Name: 
-- Module Name: Datapath - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Datapath is
    Port (  clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            instr       : in STD_LOGIC_VECTOR (31 downto 0);
            
            i_pos_x : in STD_LOGIC_VECTOR (9 downto 0);
            i_pos_y : in STD_LOGIC_VECTOR (9 downto 0);
            
            i_addr_reg    : in STD_LOGIC_VECTOR (1 downto 0);
            i_val_reg     : in STD_LOGIC_VECTOR (9 downto 0);
            i_we_reg      : in std_logic;
            
            i_bg_tuile_id : in STD_LOGIC_VECTOR (5 downto 0);
            i_bg_tuile_col : in STD_LOGIC_VECTOR (6 downto 0);
            i_bg_tuile_row : in STD_LOGIC_VECTOR (6 downto 0);
            i_we_bg_buf   : in Std_logic;
            
            i_we_bg_tuile_buffer          : in Std_logic;
            i_color_code_bg_tuile_buf     : in STD_LOGIC_VECTOR (3 downto 0);
            i_color_code_pos_bg_tuile_buf : in STD_LOGIC_VECTOR (11 downto 0);
            
            i_acteur_id           : in STD_LOGIC_VECTOR (2 downto 0);
            i_pos_acteur_x        : in STD_LOGIC_VECTOR (9 downto 0);
            i_pos_acteur_y        : in STD_LOGIC_VECTOR (9 downto 0);
            i_we_acteur_pos       : in Std_logic;
            i_acteur_tuile_id     : in STD_LOGIC_VECTOR (1 downto 0);
            i_acteur_new_tuile_id : in STD_LOGIC_VECTOR (5 downto 0);
            i_we_acteur_tuile     : in Std_logic;
            i_tuile_flip          : in STD_LOGIC_VECTOR (1 downto 0);
            i_we_tuile_flip       : in Std_logic;
            
            i_we_acteur_tuile_buf             : in Std_logic;
            i_color_code_acteur_tuile_buf     : in STD_LOGIC_VECTOR (3 downto 0);
            i_color_code_pos_acteur_tuile_buf : in STD_LOGIC_VECTOR (11 downto 0);
            
            i_color_code_dest     : in STD_LOGIC_VECTOR (3 downto 0);
            i_write_enable_color  : in Std_logic;
            i_new_rgb             : in STD_LOGIC_VECTOR (23 downto 0);
           
            o_rgb_color           : out STD_LOGIC_VECTOR (23 downto 0)
        );
end Datapath;

architecture Behavioral of Datapath is

component BancRegistre is
    Port ( clk          : in std_logic;
           reset        : in std_logic; 
           i_addr_reg   : in STD_LOGIC_VECTOR (0 downto 0);
           i_val_reg    : in STD_LOGIC_VECTOR (9 downto 0);
           i_we         : in std_logic;
           
           o_offset_x   : out STD_LOGIC_VECTOR (9 downto 0);
           o_offset_y   : out STD_LOGIC_VECTOR (9 downto 0));
end component;

component GestionnaireActeur is
    Port ( clk : in std_logic;
           reset : in std_logic;
           i_acteur_id : in std_logic_vector(2 downto 0);
           i_global_x : in std_logic_vector(9 downto 0);
           i_global_y : in std_logic_vector(9 downto 0);
           i_pos_x : in std_logic_vector(9 downto 0);
           i_pos_y : in std_logic_vector(9 downto 0);
           i_we_pos : in std_logic;
           i_acteur_tuile_index : in std_logic_vector(1 downto 0);
           i_acteur_new_tuile_id : in std_logic_vector(5 downto 0);
           i_we_acteur_tuile : in std_logic;
           i_tuile_flip : in std_logic_vector(1 downto 0);
           i_we_tuile_flip : in std_logic;
           o_tuile_id : out std_logic_vector(5 downto 0);
           o_tuile_pixel_x : out std_logic_vector(2 downto 0);
           o_tuile_pixel_y : out std_logic_vector(2 downto 0));
end component;

component BackgroundBuffer is
    Port ( clk : in std_logic;
           reset : in std_logic;
           i_we : in std_logic;
           i_global_x : in std_logic_vector (9 downto 0);
           i_global_y : in std_logic_vector (9 downto 0);
           i_write_tuile_id : in std_logic_vector(5 downto 0);
           i_write_tuile_col : in std_logic_vector(6 downto 0);
           i_write_tuile_row : in std_logic_vector(6 downto 0);
           o_tuile_id : out std_logic_vector (5 downto 0);
           o_pixel_offset_x : out std_logic_vector (2 downto 0);
           o_pixel_offset_y : out std_logic_vector (2 downto 0));
end component ;

component BackgroundTuileBuffer is
    Port ( 
        clk                 : in std_logic;
        reset               : in std_logic;
        i_we                : in std_logic;
        i_write_color_code  : in std_logic_vector(3 downto 0);
        i_write_color_code_pos  : in std_logic_vector(11 downto 0);
        i_tuile_id          : in std_logic_vector  (5 downto 0);
        i_pixel_offset_x    : in std_logic_vector (2 downto 0);
        i_pixel_offset_y    : in std_logic_vector (2 downto 0);
        o_color_code        : out std_logic_vector   (3 downto 0)
    );
end component;

component ActeurTuileBuffer is
    Port ( clk : in std_logic;
           reset : in std_logic;
           i_tuile_id : in STD_LOGIC_VECTOR (5 downto 0);
           i_tuile_pixel_x : in STD_LOGIC_VECTOR (2 downto 0);
           i_tuile_pixel_y : in STD_LOGIC_VECTOR (2 downto 0);
           i_we : in std_logic;
           i_write_color_code : in STD_LOGIC_VECTOR (3 downto 0);
           i_write_color_code_pos : in STD_LOGIC_VECTOR (11 downto 0);
           o_color_code : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component PaletteDeCouleur is
    Port (
    clk : in std_logic ;
    reset : in std_logic ;
    i_color_code : in std_logic_vector (3 downto 0); -- code couleur sélectionné
    i_color_code_dest : in std_logic_vector (3 downto 0); -- code couleur a mettre a jour
    i_we : in std_logic; -- signal d'ecriture pour mise a jour
    i_new_rgb : in std_logic_vector (23 downto 0); -- nouvelle valeur rgb
    o_rgb_color : out std_logic_vector(23 downto 0) -- sortie rgb 24 bits
     );
end component;

signal s_offset_x   : std_logic_vector(9 downto 0);
signal s_offset_y   : std_logic_vector(9 downto 0);

signal s_global_x   : std_logic_vector(9 downto 0);
signal s_global_y   : std_logic_vector(9 downto 0);

signal s_acteur_tuile_id   : std_logic_vector(5 downto 0);
signal s_acteur_tuile_pixel_x   : std_logic_vector(2 downto 0);
signal s_acteur_tuile_pixel_y   : std_logic_vector(2 downto 0);

signal s_bg_tuile_id   : std_logic_vector(5 downto 0);
signal s_bg_tuile_pixel_x   : std_logic_vector(2 downto 0);
signal s_bg_tuile_pixel_y   : std_logic_vector(2 downto 0);

signal s_bg_color_code   : std_logic_vector(3 downto 0);
signal s_acteur_color_code   : std_logic_vector(3 downto 0);

signal s_Data2Palette_muxout   : std_logic_vector(3 downto 0);
signal s_rgb_color   : std_logic_vector(23 downto 0);

begin

o_rgb_color <= s_rgb_color;

------------------------------------------------------------------------
-- BancRegistre
------------------------------------------------------------------------
inst_BancRegistre: BancRegistre
    Port map ( 
           clk   => clk,
           reset => reset,
           i_addr_reg  => i_addr_reg,
           i_val_reg => i_val_reg,
           i_we => i_we_reg,
           o_offset_x  => s_offset_x,
           o_offset_y => s_offset_y
    );

------------------------------------------------------------------------
-- Additionneur offset
------------------------------------------------------------------------
s_global_x <= s_offset_x + i_pos_x;
s_global_y <= s_offset_y + i_pos_y;

------------------------------------------------------------------------
-- BackgroundBuffer
------------------------------------------------------------------------
inst_BackgroundBuffer: BackgroundBuffer
    Port map ( 
           clk   => clk,
           reset => reset,
           i_we  => i_we_bg_buf,
           i_global_x => s_global_x,
           i_global_y => s_global_y,
           i_write_tuile_id  => i_bg_tuile_id,
           i_write_tuile_col => i_bg_tuile_col,
           i_write_tuile_row => i_bg_tuile_row,
           o_tuile_id        => s_bg_tuile_id,
           o_pixel_offset_x  => s_bg_tuile_pixel_x,
           o_pixel_offset_y  => s_bg_tuile_pixel_y
    );
    
------------------------------------------------------------------------
-- BackgroundTuileBuffer
------------------------------------------------------------------------
inst_BackgroundTuileBuffer: BackgroundTuileBuffer
    Port map ( 
           clk   => clk,
           reset => reset,
           i_we => i_we_bg_tuile_buffer,
           i_write_color_code => i_color_code_bg_tuile_buf,
           i_write_color_code_pos => i_color_code_pos_bg_tuile_buf,
           i_tuile_id => s_bg_tuile_id,
           i_pixel_offset_x => s_bg_tuile_pixel_x,
           i_pixel_offset_y => s_bg_tuile_pixel_y,
           o_color_code => s_bg_color_code
    );
    
------------------------------------------------------------------------
-- Gestionnaire d'acteurs
------------------------------------------------------------------------
inst_GestionnaireActeur: GestionnaireActeur
    Port map ( 
           clk          => clk,
           reset        => reset,
           i_acteur_id  => i_acteur_id,
           i_global_x   => s_global_x,
           i_global_y   => s_global_y,
           i_pos_x      => i_pos_acteur_x,
           i_pos_y      => i_pos_acteur_y,
           i_we_pos     => i_we_acteur_pos,
           i_acteur_tuile_index  => i_acteur_tuile_id,
           i_acteur_new_tuile_id => i_acteur_new_tuile_id,
           i_we_acteur_tuile     => i_we_acteur_tuile,
           i_tuile_flip     => i_tuile_flip,
           i_we_tuile_flip  => i_we_tuile_flip,
           o_tuile_id       => s_acteur_tuile_id,
           o_tuile_pixel_x  => s_acteur_tuile_pixel_x,
           o_tuile_pixel_y  => s_acteur_tuile_pixel_y
    );
    
------------------------------------------------------------------------
-- ActeurTuileBuffer
------------------------------------------------------------------------
inst_ActeurTuileBuffer: ActeurTuileBuffer
    Port map ( 
           clk      => clk,
           reset    => reset,
           i_we     => i_we_acteur_tuile_buf,
           i_write_color_code     => i_color_code_acteur_tuile_buf,
           i_write_color_code_pos => i_color_code_pos_acteur_tuile_buf,
           i_tuile_id       => s_acteur_tuile_id,
           i_tuile_pixel_x  => s_acteur_tuile_pixel_x,
           i_tuile_pixel_y  => s_acteur_tuile_pixel_y,
           o_color_code     => s_acteur_color_code
    );  

------------------------------------------------------------------------
-- Mux vers color converter
------------------------------------------------------------------------

s_Data2Palette_muxout    <= s_acteur_color_code when s_acteur_color_code /= "0000" else -- 1 dès qu'au moins un de ses bits d'entrée est 1.
						      s_bg_color_code;

------------------------------------------------------------------------
-- ActeurTuileBuffer
------------------------------------------------------------------------
inst_PaletteDeCouleur: PaletteDeCouleur
    Port map ( 
           clk => clk,
           reset => reset,
           i_color_code => s_Data2Palette_muxout,
           i_color_code_dest => i_color_code_dest,
           i_we => i_write_enable_color,
           i_new_rgb => i_new_rgb,
           o_rgb_color => s_rgb_color
           
    ); 

end Behavioral;
