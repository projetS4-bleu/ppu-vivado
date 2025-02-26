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
    -- Constantes
    constant c_int_pixel_per_tuile                  : integer := 8;
    constant c_int_acteur_tuile_cols                : integer := 2;
    constant c_int_acteur_tuile_rows                : integer := 2;
    constant c_int_acteur_pixel_width               : integer := c_int_acteur_tuile_cols * c_int_pixel_per_tuile;
    constant c_int_acteur_pixel_height              : integer := c_int_acteur_tuile_rows * c_int_pixel_per_tuile;

    -- Types
    type t_tuile_array                          is array (0 to 3) of std_logic_vector(5 downto 0);
    type t_tuile_flip_array                     is array (0 to 3) of std_logic_vector(1 downto 0);

    -- Registres
    signal r_pos_x                              : std_logic_vector(9 downto 0) := (others => '0');
    signal r_pos_y                              : std_logic_vector(9 downto 0) := (others => '0');
    signal r_tuiles                             : t_tuile_array := (others => (others => '0'));
    signal r_tuile_flips                        : t_tuile_flip_array := (others => (others => '0'));

    -- Signaux non-signees pour logique
    signal s_us_global_x                        : unsigned(9 downto 0);
    signal s_us_global_y                        : unsigned(9 downto 0);
    signal s_us_pos_x                           : unsigned(9 downto 0);
    signal s_us_pos_y                           : unsigned(9 downto 0);
    signal s_us_acteur_pixel_offset_x           : unsigned(3 downto 0);
    signal s_us_acteur_pixel_offset_y           : unsigned(3 downto 0);
    signal s_us_tuile_col                       : unsigned(0 downto 0);
    signal s_us_tuile_row                       : unsigned(0 downto 0);
    signal s_us_tuile_pixel_offset_x            : unsigned(2 downto 0);
    signal s_us_tuile_pixel_offset_y            : unsigned(2 downto 0);
    signal s_us_flipped_tuile_pixel_offset_x    : unsigned(2 downto 0);
    signal s_us_flipped_tuile_pixel_offset_y    : unsigned(2 downto 0);
    
    -- Indices de tableaux
    signal s_int_acteur_tuile_index             : integer range 0 to 3;
    signal s_int_current_tuile_index            : integer range 0 to 3;

    -- Signaux sortie pour offset pixel
    signal s_slv_tuile_pixel_offset_x           : std_logic_vector(2 downto 0);
    signal s_slv_tuile_pixel_offset_y           : std_logic_vector(2 downto 0);
    signal s_slv_flipped_tuile_pixel_offset_x   : std_logic_vector(2 downto 0);
    signal s_slv_flipped_tuile_pixel_offset_y   : std_logic_vector(2 downto 0);
begin
    s_us_global_x                       <= unsigned(i_global_x);
    s_us_global_y                       <= unsigned(i_global_y);
    s_us_pos_x                          <= unsigned(r_pos_x);
    s_us_pos_y                          <= unsigned(r_pos_y);
    s_us_acteur_pixel_offset_x          <= resize(s_us_global_x - s_us_pos_x, 4);
    s_us_acteur_pixel_offset_y          <= resize(s_us_global_y - s_us_pos_y, 4);
    s_us_tuile_col                      <= s_us_acteur_pixel_offset_x(3 downto 3);
    s_us_tuile_row                      <= s_us_acteur_pixel_offset_y(3 downto 3);
    s_us_tuile_pixel_offset_x           <= s_us_acteur_pixel_offset_x(2 downto 0);
    s_us_tuile_pixel_offset_y           <= s_us_acteur_pixel_offset_y(2 downto 0);
    s_us_flipped_tuile_pixel_offset_x   <= (c_int_acteur_pixel_width - 1) - s_us_tuile_pixel_offset_x;
    s_us_flipped_tuile_pixel_offset_y   <= (c_int_acteur_pixel_height - 1) - s_us_tuile_pixel_offset_y;
    
    s_int_acteur_tuile_index            <= to_integer(unsigned(i_acteur_tuile_index));
    s_int_current_tuile_index           <= to_integer(s_us_tuile_col + (s_us_tuile_row * to_unsigned(c_int_acteur_tuile_cols, 2)));
    
    s_slv_tuile_pixel_offset_x          <= std_logic_vector(s_us_tuile_pixel_offset_x);
    s_slv_tuile_pixel_offset_y          <= std_logic_vector(s_us_tuile_pixel_offset_y);
    s_slv_flipped_tuile_pixel_offset_x  <= std_logic_vector(s_us_flipped_tuile_pixel_offset_x);
    s_slv_flipped_tuile_pixel_offset_y  <= std_logic_vector(s_us_flipped_tuile_pixel_offset_y);

    UC : process(clk, reset)
    begin
        if reset = '1' then
            r_pos_x <= (others => '0');
            r_pos_y <= (others => '0');
            r_tuiles <= (others => (others => '0'));
            r_tuile_flips <= (others => (others => '0'));
        elsif rising_edge(clk) then
            -- Position
            if i_we_pos = '1' then
                r_pos_x <= i_pos_x;
                r_pos_y <= i_pos_y;
            end if;

            -- Tuiles de l'acteur
            if i_we_acteur_tuile = '1' then
                r_tuiles(s_int_acteur_tuile_index) <= i_acteur_new_tuile_id;
            end if;

            -- Flip tuile
            if i_we_tuile_flip = '1' then
                r_tuile_flips(s_int_acteur_tuile_index) <= i_tuile_flip;
            end if;
        end if;
    end process;

    UT : process(s_us_global_x,
                 s_us_global_y,
                 s_us_pos_x,
                 s_us_pos_y,
                 r_tuile_flips,
                 s_int_current_tuile_index,
                 s_slv_flipped_tuile_pixel_offset_x,
                 s_slv_tuile_pixel_offset_x,
                 s_slv_flipped_tuile_pixel_offset_y,
                 s_slv_tuile_pixel_offset_y)
    begin
        o_tuile_id <= (others => '0');
        o_tuile_pixel_x <= (others => '0');
        o_tuile_pixel_y <= (others => '0');

        -- Si acteur touche au pixel
        if s_us_global_x >= s_us_pos_x and 
           s_us_global_x < (resize(s_us_pos_x, 11) + c_int_acteur_pixel_width) and
           s_us_global_y >= s_us_pos_y and
           s_us_global_y < (resize(s_us_pos_y, 11) + c_int_acteur_pixel_height)
        then
            o_tuile_id <= r_tuiles(s_int_current_tuile_index);

            -- Flip horizontal
            if r_tuile_flips(s_int_current_tuile_index)(0) = '1' then
                o_tuile_pixel_x <= s_slv_flipped_tuile_pixel_offset_x;
            else
                o_tuile_pixel_x <= s_slv_tuile_pixel_offset_x;
            end if;
            
            -- Flip vertical
            if r_tuile_flips(s_int_current_tuile_index)(1) = '1' then
                o_tuile_pixel_y <= s_slv_flipped_tuile_pixel_offset_y;
            else
                o_tuile_pixel_y <= s_slv_tuile_pixel_offset_y;
            end if;
        end if;
    end process;
end Behavioral;
