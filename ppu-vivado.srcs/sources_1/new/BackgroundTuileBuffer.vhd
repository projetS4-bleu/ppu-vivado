----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/05/2025 09:05:14 AM
-- Design Name: 
-- Module Name: BackgroundTuileBuffer - Behavioral
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

entity BackgroundTuileBuffer is
    Port ( 
        clk                 : in std_logic;
        reset               : in std_logic;
        i_we                : in std_logic;
        i_write_color_code  : in std_logic_vector(3 downto 0);
        i_tuile_id          : in std_logic_vector  (5 downto 0);
        i_pixel_offset_x    : in std_logic_vector (2 downto 0);
        i_pixel_offset_y    : in std_logic_vector (2 downto 0);
        o_color_code        : out std_logic_vector   (3 downto 0)
    );
end BackgroundTuileBuffer;

architecture Behavioral of BackgroundTuileBuffer is
    constant pixel_cols : integer := 64;
    constant pixel_rows : integer := 64;
    constant nb_pixels  : integer := pixel_cols * pixel_rows;
    
    type t_vram_buffer_type is array (0 to (nb_pixels)-1) of std_logic_vector(3 downto 0);
    signal r_tuile_buffer : t_vram_buffer_type := (others => (others => '0'));
    
    signal s_width          : std_logic_vector(3 downto 0) := "1000";
    signal s_pixel_col      : unsigned(2 downto 0);
    signal s_pixel_row      : unsigned(2 downto 0);
    signal s_tuile_id       : unsigned(11 downto 0);
    signal s_pixel_index    : integer range 0 to (nb_pixels)-1;
begin
    s_tuile_id      <= shift_left(unsigned(i_tuile_id), 6);
    s_pixel_col     <= unsigned(i_pixel_offset_x);
    s_pixel_row     <= unsigned(i_pixel_offset_y);
    s_pixel_index   <= to_integer(s_tuile_id) + (to_integer(s_pixel_col) + to_integer(s_pixel_row) * to_integer(unsigned(s_width)));
    
    process(clk, reset)
    begin
        if reset = '1' then
            r_tuile_buffer <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if i_we = '1' then
                r_tuile_buffer(s_pixel_index) <= i_write_color_code;
            end if;
            o_color_code <= r_tuile_buffer(s_pixel_index);
        end if;
    end process;
end Behavioral;
