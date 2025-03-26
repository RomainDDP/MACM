library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- component definition
entity test_etageFE is
end test_etageFE;

-- architecture definition
architecture behaviour of test_etageFE is

    -- constant defintions
	-- constant TIMEOUT 	: time := 10000 ms; -- simulation timeout
 --  constant clkpulse   : Time := 500 ns; -- 1/2 periode horloge

    -- types/subtypes definitions

    -- signal definitions
    signal T_npc, T_npc_fw_br : std_logic_vector(31 downto 0);
    signal T_PCSrc_ER, T_Bpris_EX, T_GEL_LI, T_clk : std_logic;
    signal T_pc_plus_4, T_i_FE : std_logic_vector(31 downto 0);

begin

-- instantiation et mapping du composant registres
etageFE_inst: entity work.etageFE(etageFE_arch)
  port map(
     npc => T_npc,
     npc_fw_br => T_npc_fw_br,
     PCSrc_ER => T_PCSrc_ER,
     Bpris_EX => T_Bpris_EX,
     GEL_LI => T_GEL_LI,
     clk => T_clk,
     pc_plus_4 => T_pc_plus_4,
     i_FE => T_i_FE
  );
-----------------------------
-- Test process
P_TEST: process
begin

  -- Initialisation des ports
  T_clk <= '0';
  T_npc <= (1=>'1', others => '0');
  
  T_PCSrc_ER <= '1';
  T_Bpris_EX <= '0';
  T_GEL_LI <= '1';
  
  T_i_FE <= (others => 'X');
  wait for 5 ns;

  T_npc_fw_br <= (3 => '1', others => '0'); 
  T_Bpris_EX <= '1';
  T_clk <= '1';
  wait for 5 ns;

  --T_npc <= (2=>'1', others => '0');

  T_clk <= '0';
  wait for 5 ns;
  T_clk <= '1';
  wait for 5 ns;
  T_clk <= '0';

  assert (T_pc_plus_4 = CONV_STD_LOGIC_VECTOR(8, 32) )
    report "PC + 4 should be equal 8 !"
    severity WARNING;
  

    assert FALSE report "FIN DE SIMULATION" severity FAILURE;
end process P_TEST;

end behaviour;

