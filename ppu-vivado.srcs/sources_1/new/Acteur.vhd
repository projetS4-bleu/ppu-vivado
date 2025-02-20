library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Acteur is
    Port ( clk : in std_logic;
           reset : in std_logic;
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
end Acteur;

architecture Behavioral of Acteur is
    constant c_pixel_per_tuile : integer := 8;
    constant c_acteur_tuile_cols : integer := 2;
    constant c_acteur_tuile_rows : integer := 2;
    constant c_acteur_pixel_width : integer := c_acteur_tuile_cols * c_pixel_per_tuile;
    constant c_acteur_pixel_height : integer := c_acteur_tuile_rows * c_pixel_per_tuile;

    type t_tuile_array is array (0 to 3) of std_logic_vector(5 downto 0);
    type t_tuile_flip_array is array (0 to 3) of std_logic_vector(1 downto 0);

    signal r_pos_x : std_logic_vector(9 downto 0) := (others => '0');
    signal r_pos_y : std_logic_vector(9 downto 0) := (others => '0');
    signal r_tuiles : t_tuile_array := (others => (others => '0'));
    signal r_tuile_flips : t_tuile_flip_array := (others => (others => '0'));
    
    -- Input signals converted to unsigned
    signal s_acteur_tuile_index : integer range 0 to 3;
    signal s_global_x : unsigned;
    signal s_global_y : unsigned;
    signal s_pos_x : unsigned;
    signal s_pos_y : unsigned;

    -- Helper signals to output correct pixel's color code
    signal s_acteur_pixel_offset_x : unsigned;
    signal s_acteur_pixel_offset_y : unsigned;
    signal s_tuile_col : unsigned;
    signal s_tuile_row : unsigned;
    signal s_current_tuile_index : integer;
    signal s_tuile_pixel_offset_x : std_logic_vector(2 downto 0);
    signal s_tuile_pixel_offset_y : std_logic_vector(2 downto 0);
    signal s_flipped_tuile_pixel_offset_x : std_logic_vector(2 downto 0);
    signal s_flipped_tuile_pixel_offset_y : std_logic_vector(2 downto 0);
begin
    s_acteur_tuile_index <= to_integer(unsigned(i_acteur_tuile_index));
    s_global_x <= unsigned(i_global_x);
    s_global_y <= unsigned(i_global_y);
    s_pos_x <= unsigned(i_pos_x);
    s_pos_y <= unsigned(i_pos_y);

    s_acteur_pixel_offset_x <= s_global_x - s_pos_x;
    s_acteur_pixel_offset_y <= s_global_y - s_pos_y;
    s_tuile_col <= s_acteur_pixel_offset_x / c_pixel_per_tuile;
    s_tuile_row <= s_acteur_pixel_offset_y / c_pixel_per_tuile;
    s_current_tuile_index <= to_integer(s_tuile_col + (s_tuile_row * c_acteur_tuile_cols));
    s_tuile_pixel_offset_x <= std_logic_vector(s_acteur_pixel_offset_x mod c_pixel_per_tuile);
    s_tuile_pixel_offset_y <= std_logic_vector(s_acteur_pixel_offset_y mod c_pixel_per_tuile);
    s_flipped_tuile_pixel_offset_x <= std_logic_vector((c_acteur_pixel_width - 1) - unsigned(s_tuile_pixel_offset_x));
    s_flipped_tuile_pixel_offset_y <= std_logic_vector((c_acteur_pixel_height - 1) - unsigned(s_tuile_pixel_offset_y));

    UC : process(clk, reset)
    begin
        if reset = '1' then
            r_pos_x <= (others => '0');
            r_pos_y <= (others => '0');
            r_tuiles <= (others => (others => '0'));
            r_tuile_flips <= (others => (others => '0'));
        elsif rising_edge(clk) then
            -- Update sprite position
            if i_we_pos = '1' then
                r_pos_x <= i_pos_x;
                r_pos_y <= i_pos_y;
            end if;

            -- Update sprite tiles
            if i_we_acteur_tuile = '1' then
                r_tuiles(s_acteur_tuile_index) <= i_acteur_new_tuile_id;
            end if;

            -- Update if a tile is flipped horizontally and/or vertically
            if i_we_tuile_flip = '1' then
                r_tuile_flips(s_acteur_tuile_index) <= i_tuile_flip;
            end if;
        end if;
    end process;

    UT : process(r_pos_x, r_pos_y, r_tuiles, r_tuile_flips)
    begin
        -- If current pixel touches sprite
        if s_global_x >= s_pos_x and 
           s_global_x < (s_pos_x + c_acteur_pixel_width) and
           s_global_y >= s_pos_y and
           s_global_y < (s_pos_y + c_acteur_pixel_height)
        then
            o_tuile_id <= r_tuiles(s_current_tuile_index);
            
            -- Check if tile should be flipped horizontally
            if r_tuile_flips(s_current_tuile_index)(0) = '1' then
                o_tuile_pixel_x <= s_flipped_tuile_pixel_offset_x;
            else
                o_tuile_pixel_x <= s_tuile_pixel_offset_x;
            end if;
            
            -- Check if tile should be flipped vertically
            if r_tuile_flips(s_current_tuile_index)(1) = '1' then
                o_tuile_pixel_y <= s_flipped_tuile_pixel_offset_y;
            else
                o_tuile_pixel_y <= s_tuile_pixel_offset_y;
            end if;
        else
            o_tuile_id <= (others => '0');
            o_tuile_pixel_x <= (others => '0');
            o_tuile_pixel_y <= (others => '0');
        end if;
    end process;
end Behavioral;
