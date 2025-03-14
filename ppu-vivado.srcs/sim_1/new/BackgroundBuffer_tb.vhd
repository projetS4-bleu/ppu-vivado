library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BackgroundBuffer_tb is
end BackgroundBuffer_tb;

architecture Behavioral of BackgroundBuffer_tb is
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
           o_pixel_offset_y : out std_logic_vector (2 downto 0)
    );
    end component;

    constant clk_cycle : time := 10 ns;
    signal clk : std_logic;
    signal reset : std_logic;
    
    signal s_we : std_logic;
    signal s_global_x : std_logic_vector (9 downto 0);
    signal s_global_y : std_logic_vector (9 downto 0);
    signal s_write_tuile_id : std_logic_vector(5 downto 0);
    signal s_write_tuile_col : std_logic_vector(6 downto 0);
    signal s_write_tuile_row : std_logic_vector(6 downto 0);
    signal s_tuile_id : std_logic_vector (5 downto 0);
    signal s_pixel_offset_x : std_logic_vector (2 downto 0);
    signal s_pixel_offset_y : std_logic_vector (2 downto 0);
    
    procedure assert_tuile (
        tuile_id : in std_logic_vector(5 downto 0);
        pixel_offset_x, pixel_offset_y : in std_logic_vector(2 downto 0);
        err_msg : in string
    ) is
    begin
        assert(s_tuile_id = tuile_id and s_pixel_offset_x = pixel_offset_x and s_pixel_offset_y = pixel_offset_y)
        report err_msg
        severity failure;
    end assert_tuile;
begin
    dut : BackgroundBuffer
    port map (
        clk => clk,
        reset => reset,
        i_we => s_we,
        i_global_x => s_global_x,
        i_global_y => s_global_y,
        i_write_tuile_id => s_write_tuile_id,
        i_write_tuile_col => s_write_tuile_col,
        i_write_tuile_row => s_write_tuile_row,
        o_tuile_id => s_tuile_id,
        o_pixel_offset_x => s_pixel_offset_x,
        o_pixel_offset_y => s_pixel_offset_y
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
        variable v_tuile_col : std_logic_vector (6 downto 0);
        variable v_tuile_row : std_logic_vector (6 downto 0);
    begin
        s_we <= '0';
        s_write_tuile_id <= "000000";
        s_global_x <= "0000000000";
        s_global_y <= "0000000000";
    
        reset <= '1';
        wait for clk_cycle;
        wait for clk_cycle / 5; -- optionnel: relacher le reset juste apres le front d'horloge
        reset <= '0';
        
        ------------------------------------------------
        -- Test : Utilisation normale de la VRAM
        ------------------------------------------------
        
        -- write tuile 10 => index 15
        s_we <= '1';
        s_write_tuile_id <= "001010";
        s_write_tuile_col <= "0001111";
        s_write_tuile_row <= "0000000"; wait for clk_cycle;
        
        -- write tuile 20 => index 200
        s_write_tuile_id <= "010100";
        s_write_tuile_col <= "1001000";
        s_write_tuile_row <= "0000001"; wait for clk_cycle;
        
        -- read index 15 => expect tuile 10
        s_we <= '0';
        s_global_x <= "0001111001";
        s_global_y <= "0000000100"; wait for clk_cycle;
        assert_tuile("001010", "001", "100", "BackgroundBuffer: Le tuile id a l'index 15 devrait etre 10 avec l'offset pixel x:1 and y:4");
        
        -- write tuile 30 => index 1000
        s_we <= '1';
        s_write_tuile_id <= "011110";
        s_write_tuile_col <= "0101100";
        s_write_tuile_row <= "0000010"; wait for clk_cycle;
        
        -- read index 200 => expect tuile 20
        s_we <= '0';
        s_global_x <= "1001000000";
        s_global_y <= "0000001000"; wait for clk_cycle;
        assert_tuile("010100", "000", "000", "BackgroundBuffer: Le tuile id a l'index 200 devrait etre 20 avec l'offset pixel x:0 and y:0");
        
        -- read index 1000 => expect tuile 30
        s_global_x <= "0101100010";
        s_global_y <= "0000010101"; wait for clk_cycle;
        assert_tuile("011110", "010", "101", "BackgroundBuffer: Le tuile id a l'index 1000 devrait etre 30 avec l'offset pixel x:2 and y:5");
        
        ------------------------------------------------
        -- Test : Cas limites
        ------------------------------------------------
        
        -- write tuile 0 => index 0
        s_we <= '1';
        s_write_tuile_id <= "000000";
        s_write_tuile_col <= "0000000";
        s_write_tuile_row <= "0000000"; wait for clk_cycle;
        
        -- write tuile 64 => index 16383
        s_write_tuile_id <= "111111";
        s_write_tuile_col <= "1111111";
        s_write_tuile_row <= "1111111"; wait for clk_cycle;
        
        -- read index 0 => expect tuile 0
        s_we <= '0';
        s_global_x <= "0000000000";
        s_global_y <= "0000000000"; wait for clk_cycle;
        assert_tuile("000000", "000", "000", "BackgroundBuffer: Le tuile id a l'index 0 devrait etre 0 avec l'offset pixel x:0 and y:0");
        
        -- read index 16383 => expect tuile 63
        s_global_x <= "1111111111";
        s_global_y <= "1111111111"; wait for clk_cycle;
        assert_tuile("111111", "111", "111", "BackgroundBuffer: Le tuile id a l'index 16383 devrait etre 67 avec l'offset pixel x:7 and y:7");
        
        ------------------------------------------------
        -- Test : Reset
        ------------------------------------------------
        s_global_x <= "0000000000";
        s_global_y <= "0000000000";
        
        reset <= '1';
        wait for clk_cycle;
        wait for clk_cycle / 5;
        reset <= '0';
        
        -- Make sure all values are 0 after reset
        for row in 0 to 127 loop
            v_tuile_row := std_logic_vector(to_unsigned(row, 7));
            s_global_y <= v_tuile_row & "000";
            for col in 0 to 127 loop
                v_tuile_col := std_logic_vector(to_unsigned(col, 7));
                s_global_x <= v_tuile_col & "000"; wait for clk_cycle;
                assert_tuile("000000", "000", "000", "BackgroundBuffer: Un id de tuile different de 0 a ete trouve apres un reset");
            end loop;
        end loop;
        
        wait;
    end process;
end Behavioral;
