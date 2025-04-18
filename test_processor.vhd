-------------------------------------------------------

-- Fichier de test du processeur.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

-- Definition de l'entite
entity test_processor is
end test_processor;

-- Definition de l'architecture
architecture behavior of test_processor is
	
  constant clkpulse : Time := 5 ns;
	signal E_clk : std_logic;
	signal init : std_logic;

begin

  mon_proc_tout_mignon : entity work.Processor
      port map (
        clk => E_clk,
        init => init
      );

P_TEST: process
begin

	init <= '0';
	E_clk <= '1';

	for i in natural range 0 to 100 loop
		wait for clkpulse;
		E_clk <= '1';
		wait for clkpulse;
		E_clk <= '0';
	end loop;


	wait for clkpulse/2;
	assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST;

end behavior;
