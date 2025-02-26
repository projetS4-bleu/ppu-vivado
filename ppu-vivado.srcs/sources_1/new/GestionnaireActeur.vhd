library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GestionnaireActeur is
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
end GestionnaireActeur;

architecture Behavioral of GestionnaireActeur is
    constant c_nb_acteurs           : integer := 8;
    
    type t_curr_acteur_array        is array (0 to c_nb_acteurs-1) of std_logic_vector(2 downto 0);
    type t_we_pos_array             is array (0 to c_nb_acteurs-1) of std_logic;
    type t_we_acteur_tuile_array    is array (0 to c_nb_acteurs-1) of std_logic;
    type t_we_tuile_flip_array      is array (0 to c_nb_acteurs-1) of std_logic;
    type t_o_tuile_id_array         is array (0 to c_nb_acteurs-1) of std_logic_vector(5 downto 0);
    type t_o_tuile_pixel_x_array    is array (0 to c_nb_acteurs-1) of std_logic_vector(2 downto 0);
    type t_o_tuile_pixel_y_array    is array (0 to c_nb_acteurs-1) of std_logic_vector(2 downto 0);
    
    signal s_curr_acteur_array      : t_curr_acteur_array       := (others => (others => '0'));
    signal s_we_pos_array           : t_we_pos_array            := (others => '0');
    signal s_we_acteur_tuile_array  : t_we_acteur_tuile_array   := (others => '0');
    signal s_we_tuile_flip_array    : t_we_tuile_flip_array     := (others => '0');
    signal s_o_tuile_id_array       : t_o_tuile_id_array        := (others => (others => '0'));
    signal s_o_tuile_pixel_x_array  : t_o_tuile_pixel_x_array   := (others => (others => '0'));
    signal s_o_tuile_pixel_y_array  : t_o_tuile_pixel_y_array   := (others => (others => '0'));

    component Acteur is
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
    end component;
begin
    GEN_ACTEUR : for i in 0 to c_nb_acteurs - 1 generate
        s_curr_acteur_array(i)      <= std_logic_vector(to_unsigned(i, i_acteur_id'length));
        s_we_pos_array(i)           <= i_we_pos when i_acteur_id = s_curr_acteur_array(i) else '0';
        s_we_acteur_tuile_array(i)  <= i_we_acteur_tuile when i_acteur_id = s_curr_acteur_array(i) else '0';
        s_we_tuile_flip_array(i)    <= i_we_tuile_flip when i_acteur_id = s_curr_acteur_array(i) else '0';
    
        acteur_inst_x : Acteur
        port map (
            clk => clk,
            reset => reset,
            i_global_x => i_global_x,
            i_global_y => i_global_y,
            i_pos_x => i_pos_x,
            i_pos_y => i_pos_y,
            i_we_pos => s_we_pos_array(i),
            i_acteur_tuile_index => i_acteur_tuile_index,
            i_acteur_new_tuile_id => i_acteur_new_tuile_id,
            i_we_acteur_tuile => s_we_acteur_tuile_array(i),
            i_tuile_flip => i_tuile_flip,
            i_we_tuile_flip => s_we_tuile_flip_array(i),
            o_tuile_id => s_o_tuile_id_array(i),
            o_tuile_pixel_x => s_o_tuile_pixel_x_array(i),
            o_tuile_pixel_y => s_o_tuile_pixel_y_array(i)
        );
    end generate GEN_ACTEUR;

    UT : process(s_o_tuile_id_array, s_o_tuile_pixel_x_array, s_o_tuile_pixel_y_array)
    begin
        o_tuile_id <= (others => '0');
        o_tuile_pixel_x <= (others => '0');
        o_tuile_pixel_y <= (others => '0');

        for i in 0 to c_nb_acteurs - 1 loop
            if s_o_tuile_id_array(i) /= "000000" then
                o_tuile_id <= s_o_tuile_id_array(i);
                o_tuile_pixel_x <= s_o_tuile_pixel_x_array(i);
                o_tuile_pixel_y <= s_o_tuile_pixel_y_array(i);
                exit;
            end if;
        end loop;
    end process;
end Behavioral;
