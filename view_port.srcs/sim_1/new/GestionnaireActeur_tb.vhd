library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GestionnaireActeur_tb is
end GestionnaireActeur_tb;

architecture Behavioral of GestionnaireActeur_tb is
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
    
    constant clk_cycle : time := 10 ns;
    signal clk : std_logic;
    signal reset : std_logic;
    
    signal s_i_acteur_id : std_logic_vector(2 downto 0);
    signal s_i_global_x : std_logic_vector(9 downto 0);
    signal s_i_global_y : std_logic_vector(9 downto 0);
    signal s_i_pos_x : std_logic_vector(9 downto 0);
    signal s_i_pos_y : std_logic_vector(9 downto 0);
    signal s_i_we_pos : std_logic;
    signal s_i_acteur_tuile_index : std_logic_vector(1 downto 0);
    signal s_i_acteur_new_tuile_id : std_logic_vector(5 downto 0);
    signal s_i_we_acteur_tuile : std_logic;
    signal s_i_tuile_flip : std_logic_vector(1 downto 0);
    signal s_i_we_tuile_flip : std_logic;
    signal s_o_tuile_id : std_logic_vector(5 downto 0);
    signal s_o_tuile_pixel_x : std_logic_vector(2 downto 0);
    signal s_o_tuile_pixel_y : std_logic_vector(2 downto 0);
    
    procedure assert_pixel (
        tuile_id : in integer;
        pixel_offset_x, pixel_offset_y : in integer;
        err_msg : in string
    ) is
    begin
        assert(s_o_tuile_id         = std_logic_vector(to_unsigned(tuile_id, s_o_tuile_id'length)) and
               s_o_tuile_pixel_x    = std_logic_vector(to_unsigned(pixel_offset_x, s_o_tuile_pixel_x'length)) and
               s_o_tuile_pixel_y    = std_logic_vector(to_unsigned(pixel_offset_y, s_o_tuile_pixel_y'length)))
        report err_msg
        severity failure;
    end assert_pixel;
    
    procedure assert_no_pixel (
        err_msg : in string
    ) is
    begin
        assert(s_o_tuile_id = "000000")
        report err_msg
        severity failure;
    end assert_no_pixel;
begin
    dut : GestionnaireActeur
    port map (
        clk => clk,
        reset => reset,
        i_acteur_id => s_i_acteur_id,
        i_global_x => s_i_global_x,
        i_global_y => s_i_global_y,
        i_pos_x => s_i_pos_x,
        i_pos_y => s_i_pos_y,
        i_we_pos => s_i_we_pos,
        i_acteur_tuile_index => s_i_acteur_tuile_index,
        i_acteur_new_tuile_id => s_i_acteur_new_tuile_id,
        i_we_acteur_tuile => s_i_we_acteur_tuile,
        i_tuile_flip => s_i_tuile_flip,
        i_we_tuile_flip => s_i_we_tuile_flip,
        o_tuile_id => s_o_tuile_id,
        o_tuile_pixel_x => s_o_tuile_pixel_x,
        o_tuile_pixel_y => s_o_tuile_pixel_y
    );

    horloge : process
    begin
        clk <= '1';
        loop
            wait for clk_cycle/2;
            clk <= not clk;
        end loop;
    end process;

    test : process
    begin
        reset <= '1';
        wait for clk_cycle;
        wait for clk_cycle / 5; -- optionnel: relacher le reset juste apres le front d'horloge
        reset <= '0';
        
        ------------------------------------------------
        -- Creation acteur 1
        -- Index : 0
        -- Global pos : 100, 100
        -- Tuiles : 0, 1, 2, 3
        -- Tuile flips : Aucun, X, Y, XY
        ------------------------------------------------
        s_i_acteur_id <= "000";
        s_i_pos_x <= std_logic_vector(to_unsigned(100, 10));
        s_i_pos_y <= std_logic_vector(to_unsigned(100, 10));
        s_i_we_pos <= '1';
        s_i_acteur_tuile_index <= "00";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(0, 6));
        s_i_we_acteur_tuile <= '1';
        s_i_tuile_flip <= "00";
        s_i_we_tuile_flip <= '1'; wait for clk_cycle;
        
        s_i_we_pos <= '0';
        s_i_acteur_tuile_index <= "01";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(1, 6));
        s_i_tuile_flip <= "01"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "10";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(2, 6));
        s_i_tuile_flip <= "10"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "11";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(3, 6));
        s_i_tuile_flip <= "11"; wait for clk_cycle;

        ------------------------------------------------
        -- Creation acteur 2 (superpose partiellement l'acteur 1, pour tester l'ordre de priorite des acteurs)
        -- Index : 1
        -- Global pos : 110, 110
        -- Tuiles : 4, 5, 6, 7
        -- Tuile flips : X, Aucun, XY, Y
        ------------------------------------------------
        s_i_acteur_id <= "001";
        s_i_pos_x <= std_logic_vector(to_unsigned(110, 10));
        s_i_pos_y <= std_logic_vector(to_unsigned(110, 10));
        s_i_we_pos <= '1';
        s_i_acteur_tuile_index <= "00";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(4, 6));
        s_i_tuile_flip <= "01"; wait for clk_cycle;
        
        s_i_we_pos <= '0';
        s_i_acteur_tuile_index <= "01";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(5, 6));
        s_i_tuile_flip <= "00"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "10";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(6, 6));
        s_i_tuile_flip <= "11"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "11";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(7, 6));
        s_i_tuile_flip <= "10"; wait for clk_cycle;
        
        ------------------------------------------------
        -- Creation acteur 3 (superpose aucun autre acteur)
        -- Index : 2
        -- Global pos : 200, 200
        -- Tuiles : 8, 9, 10, 11
        -- Tuile flips : Aucun, Y, X, Aucun
        ------------------------------------------------
        s_i_acteur_id <= "010";
        s_i_pos_x <= std_logic_vector(to_unsigned(200, 10));
        s_i_pos_y <= std_logic_vector(to_unsigned(200, 10));
        s_i_we_pos <= '1';
        s_i_acteur_tuile_index <= "00";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(8, 6));
        s_i_tuile_flip <= "00"; wait for clk_cycle;
        
        s_i_we_pos <= '0';
        s_i_acteur_tuile_index <= "01";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(9, 6));
        s_i_tuile_flip <= "10"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "10";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(10, 6));
        s_i_tuile_flip <= "01"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "11";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(11, 6));
        s_i_tuile_flip <= "00"; wait for clk_cycle;
        
        ------------------------------------------------
        -- Creation acteur 4 (dernier index)
        -- Index : 7
        -- Global pos : 0, 0
        -- Tuiles : 12, 13, 14, 15
        -- Tuile flips : Aucun, Aucun, X, X
        ------------------------------------------------
        s_i_acteur_id <= "111";
        s_i_pos_x <= std_logic_vector(to_unsigned(0, 10));
        s_i_pos_y <= std_logic_vector(to_unsigned(0, 10));
        s_i_we_pos <= '1';
        s_i_acteur_tuile_index <= "00";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(12, 6));
        s_i_tuile_flip <= "00"; wait for clk_cycle;
        
        s_i_we_pos <= '0';
        s_i_acteur_tuile_index <= "01";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(13, 6));
        s_i_tuile_flip <= "00"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "10";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(14, 6));
        s_i_tuile_flip <= "01"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "11";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(15, 6));
        s_i_tuile_flip <= "01"; wait for clk_cycle;
        
        ------------------------------------------------
        -- Creation acteur 5 (overflow en X et en Y, devrait etre affiche partiellement)
        -- Index : 6
        -- Global pos : 1016, 1016
        -- Tuiles : 16, 17, 18, 19
        -- Tuile flips : Y, X, XY, Aucun
        ------------------------------------------------
        s_i_acteur_id <= "110";
        s_i_pos_x <= std_logic_vector(to_unsigned(1016, 10));
        s_i_pos_y <= std_logic_vector(to_unsigned(1016, 10));
        s_i_we_pos <= '1';
        s_i_acteur_tuile_index <= "00";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(16, 6));
        s_i_tuile_flip <= "10"; wait for clk_cycle;
        
        s_i_we_pos <= '0';
        s_i_acteur_tuile_index <= "01";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(17, 6));
        s_i_tuile_flip <= "01"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "10";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(18, 6));
        s_i_tuile_flip <= "11"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "11";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(19, 6));
        s_i_tuile_flip <= "00"; wait for clk_cycle;

        ------------------------------------------------
        -- Creation acteur 6 (X et Y differents)
        -- Index : 5
        -- Global pos : 300, 600
        -- Tuiles : 20, 21, 22, 23
        -- Tuile flips : Aucun, XY, XY, Aucun
        ------------------------------------------------
        s_i_acteur_id <= "101";
        s_i_pos_x <= std_logic_vector(to_unsigned(300, 10));
        s_i_pos_y <= std_logic_vector(to_unsigned(600, 10));
        s_i_we_pos <= '1';
        s_i_acteur_tuile_index <= "00";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(20, 6));
        s_i_tuile_flip <= "00"; wait for clk_cycle;
        
        s_i_we_pos <= '0';
        s_i_acteur_tuile_index <= "01";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(21, 6));
        s_i_tuile_flip <= "11"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "10";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(22, 6));
        s_i_tuile_flip <= "11"; wait for clk_cycle;
        
        s_i_acteur_tuile_index <= "11";
        s_i_acteur_new_tuile_id <= std_logic_vector(to_unsigned(23, 6));
        s_i_tuile_flip <= "00"; wait for clk_cycle;

        ------------------------------------------------
        -- Test : Chercher des pixels auxquels ne touchent pas les acteurs
        ------------------------------------------------
        s_i_we_acteur_tuile <= '0';
        s_i_we_tuile_flip <= '0';
        s_i_global_x <= std_logic_vector(to_unsigned(300, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(300, 10));
        wait for clk_cycle;
        assert_no_pixel("GestionnaireActeur: Il ne devrait pas avoir de pixel a la position x:300, y:300");
        
        s_i_global_x <= std_logic_vector(to_unsigned(99, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(100, 10));
        wait for clk_cycle;
        assert_no_pixel("GestionnaireActeur: Il ne devrait pas avoir de pixel a la position x:99, y:100");
        
        s_i_global_x <= std_logic_vector(to_unsigned(106, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(117, 10));
        wait for clk_cycle;
        assert_no_pixel("GestionnaireActeur: Il ne devrait pas avoir de pixel a la position x:106, y:117");
        
        s_i_global_x <= std_logic_vector(to_unsigned(216, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(208, 10));
        wait for clk_cycle;
        assert_no_pixel("GestionnaireActeur: Il ne devrait pas avoir de pixel a la position x:216, y:208");
        
        s_i_global_x <= std_logic_vector(to_unsigned(0, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(1020, 10));
        wait for clk_cycle;
        assert_no_pixel("GestionnaireActeur: Il ne devrait pas avoir de pixel a la position x:0, y:1020");
        
        s_i_global_x <= std_logic_vector(to_unsigned(1020, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(0, 10));
        wait for clk_cycle;
        assert_no_pixel("GestionnaireActeur: Il ne devrait pas avoir de pixel a la position x:1020, y:0");

        ------------------------------------------------
        -- Test : Chercher les pixels d'acteurs qui superposent pas d'autres acteurs
        ------------------------------------------------
        s_i_global_x <= std_logic_vector(to_unsigned(204, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(204, 10));
        wait for clk_cycle;
        assert_pixel(8, 4, 4, "GestionnaireActeur : Le pixel devrait correspondre a la tuile 8 avec le pixel offset x:4, y:4");

        s_i_global_x <= std_logic_vector(to_unsigned(0, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(10, 10));
        wait for clk_cycle;
        assert_pixel(14, 7, 2, "GestionnaireActeur : Le pixel devrait correspondre a la tuile 14 avec le pixel offset x:7, y:2");
        
        s_i_global_x <= std_logic_vector(to_unsigned(1020, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(1020, 10));
        wait for clk_cycle;
        assert_pixel(16, 4, 3, "GestionnaireActeur : Le pixel devrait correspondre a la tuile 16 avec le pixel offset x:4, y:3");

        s_i_global_x <= std_logic_vector(to_unsigned(315, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(615, 10));
        wait for clk_cycle;
        assert_pixel(23, 7, 7, "GestionnaireActeur : Le pixel devrait correspondre a la tuile 23 avec le pixel offset x:7, y:7");

        s_i_global_x <= std_logic_vector(to_unsigned(310, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(601, 10));
        wait for clk_cycle;
        assert_pixel(21, 5, 6, "GestionnaireActeur : Le pixel devrait correspondre a la tuile 21 avec le pixel offset x:5, y:6");

        ------------------------------------------------
        -- Test : Chercher les pixels d'acteurs qui se superposent
        ------------------------------------------------
        s_i_global_x <= std_logic_vector(to_unsigned(110, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(110, 10));
        wait for clk_cycle;
        assert_pixel(3, 5, 5, "GestionnaireActeur : Le pixel devrait correspondre a la tuile 3 avec le pixel offset x:5, y:5");

        s_i_global_x <= std_logic_vector(to_unsigned(113, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(115, 10));
        wait for clk_cycle;
        assert_pixel(3, 2, 0, "GestionnaireActeur : Le pixel devrait correspondre a la tuile 3 avec le pixel offset x:2, y:0");
        
        s_i_global_x <= std_logic_vector(to_unsigned(114, 10));
        s_i_global_y <= std_logic_vector(to_unsigned(112, 10));
        wait for clk_cycle;
        assert_pixel(3, 1, 3, "GestionnaireActeur : Le pixel devrait correspondre a la tuile 3 avec le pixel offset x:1, y:3");

        wait;
    end process;
end Behavioral;
