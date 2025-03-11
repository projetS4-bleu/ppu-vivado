library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BackgroundBuffer is
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
end BackgroundBuffer;

architecture Behavioral of BackgroundBuffer is
    constant c_tuile_nb_cols : integer := 128;
    constant c_tuile_nb_rows : integer := 128;
    constant c_nb_tuiles : integer := c_tuile_nb_cols * c_tuile_nb_rows;

    type t_vram_buffer_type is array (0 to (c_nb_tuiles)-1) of std_logic_vector(5 downto 0);
    signal r_tuile_buffer : t_vram_buffer_type := (others => (others => '0'));

    signal s_read_tuile_col : unsigned(6 downto 0);
    signal s_read_tuile_row : unsigned(6 downto 0);
    signal s_read_tuile_index : integer range 0 to (c_nb_tuiles)-1;

    signal s_write_tuile_col : unsigned(6 downto 0);
    signal s_write_tuile_row : unsigned(6 downto 0);
    signal s_write_tuile_index : integer range 0 to (c_nb_tuiles)-1;
begin
    s_read_tuile_col <= unsigned(i_global_x(9 downto 3));
    s_read_tuile_row <= unsigned(i_global_y(9 downto 3));
    s_read_tuile_index <= to_integer(s_read_tuile_col + s_read_tuile_row * c_tuile_nb_cols);

    s_write_tuile_col <= unsigned(i_write_tuile_col);
    s_write_tuile_row <= unsigned(i_write_tuile_row);
    s_write_tuile_index <= to_integer(s_write_tuile_col + s_write_tuile_row * c_tuile_nb_cols);

    process(clk, reset)
    begin
        if reset = '1' then
            r_tuile_buffer <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if i_we = '1' and s_write_tuile_index < (c_nb_tuiles) then
                r_tuile_buffer(s_write_tuile_index) <= i_write_tuile_id;
            end if;
            o_tuile_id <= r_tuile_buffer(s_read_tuile_index);
        end if;
    end process;
    
    o_pixel_offset_x <= i_global_x(2 downto 0);
    o_pixel_offset_y <= i_global_y(2 downto 0);
end Behavioral;
