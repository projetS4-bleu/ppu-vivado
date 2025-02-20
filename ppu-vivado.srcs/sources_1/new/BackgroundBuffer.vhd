library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BackgroundBuffer is
    Port ( clk : in std_logic;
           reset : in std_logic;
           i_we : in std_logic;
           i_write_tuile_id : in std_logic_vector(5 downto 0);
           i_global_x : in std_logic_vector (9 downto 0);
           i_global_y : in std_logic_vector (9 downto 0);
           o_tuile_id : out std_logic_vector (5 downto 0);
           o_pixel_offset_x : out std_logic_vector (2 downto 0);
           o_pixel_offset_y : out std_logic_vector (2 downto 0));
end BackgroundBuffer;

architecture Behavioral of BackgroundBuffer is
    constant tuile_cols : integer := 128;
    constant tuile_rows : integer := 128;
    constant nb_tuiles : integer := tuile_cols * tuile_rows;

    type t_vram_buffer_type is array (0 to (nb_tuiles)-1) of std_logic_vector(5 downto 0);
    signal s_vram_buffer : t_vram_buffer_type := (others => (others => '0'));

    signal s_tile_col : unsigned(6 downto 0);
    signal s_tile_row : unsigned(6 downto 0);
    signal s_vram_index : integer range 0 to (nb_tuiles)-1;
begin
    s_tile_col <= unsigned(i_global_x(9 downto 3));
    s_tile_row <= unsigned(i_global_y(9 downto 3));
    s_vram_index <= to_integer(s_tile_col + s_tile_row * tuile_cols);

    process(clk, reset)
    begin
        if reset = '1' then
            s_vram_buffer <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if i_we = '1' and s_vram_index < (nb_tuiles) then
                s_vram_buffer(s_vram_index) <= i_write_tuile_id;
            end if;
            o_tuile_id <= s_vram_buffer(s_vram_index);
        end if;
    end process;
    
    o_pixel_offset_x <= i_global_x(2 downto 0);
    o_pixel_offset_y <= i_global_y(2 downto 0);
end Behavioral;
