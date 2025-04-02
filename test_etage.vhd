library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- component definition
entity test_etage is
end test_etage;

-- architecture definition
architecture behaviour of test_etage is

  constant clkpulse   : Time := 500 ns; -- 1/2 periode horloge
	constant TIMEOUT 	: Time := clkpulse*20; -- simulation timeout
  signal CLK : std_logic;

  -- signal definitions for FE.
  signal npc, npc_fw_br : std_logic_vector(31 downto 0);
  signal PCSrc_ER, Bpris_EX, GEL_LI : std_logic; -- CLK
  signal pc_plus_4, i_FE : std_logic_vector(31 downto 0);

  -- signal defintions for DE
  signal i_DE, WD_ER : std_logic_vector(31 downto 0);
  signal Op3_ER : std_logic_vector(3 downto 0);
  signal RegSrc, immSrc: std_logic_vector(1 downto 0);
  signal RegWr, Init: std_logic; -- CLK
  signal Op1, Op2, extImm : std_logic_vector(31 downto 0); -- pc_plus_4
  signal Reg1, Reg2, Op3_DE : std_logic_vector(3 downto 0); 

  -- signal definitions for EX
  signal Op1_EX, Op2_EX, ExtImm_EX, Res_fwd_ME, Res_fwd_ER : std_logic_vector(31 downto 0);
  signal Op3_EX : std_logic_vector(3 downto 0);
  signal EA_EX, EB_EX, ALUCtrl_EX : std_logic_vector(1 downto 0);
  signal ALUSrc_EX : std_logic;
  signal Res_EX, WD_EX : std_logic_vector(31 downto 0); -- npc_fw_br
  signal CC, Op3_EX_out : std_logic_vector(3 downto 0);

  -- signal definitions for ME
  signal Res_ME, WD_ME : std_logic_vector(31 downto 0);
  signal Op3_ME : std_logic_vector(3 downto 0);
  signal MemWR_Mem : std_logic; -- CLK
  signal Res_Mem_ME, Res_ALU_ME : std_logic_vector(31 downto 0); -- Res_fwd_ME
  signal Op3_ME_out : std_logic_vector(3 downto 0);

  -- signal definitions for ER
  signal Res_Mem_RE, Res_ALU_RE : std_logic_vector(31 downto 0);
  signal Op3_RE : std_logic_vector(3 downto 0);
  signal MemToReg_RE : std_logic;
  signal Res_RE : std_logic_vector(31 downto 0);
  signal Op3_RE_out : std_logic_vector(3 downto 0);

begin

-- instantiation et mapping du composant registres
etageFE_inst: entity work.etageFE(etageFE_arch)
  port map(
     npc => npc,
     npc_fw_br => npc_fw_br,
     PCSrc_ER => PCSrc_ER,
     Bpris_EX => Bpris_EX,
     GEL_LI => GEL_LI,
     clk => CLK,
     pc_plus_4 => pc_plus_4,
     i_FE => i_FE
  );

etageDE_inst: entity work.etageDE(etageDE_arch)
  port map(
    pc_plus_4 => pc_plus_4,
    i_DE => i_DE, WD_ER => WD_ER,
    Op3_ER => Op3_ER, RegSrc => RegSrc,
    immSrc => immSrc, RegWr => RegWr,
    clk => CLK, Init => Init, 
    Op1 => Op1, Op2 => Op2, 
    extImm => extImm, Op3_DE => Op3_DE,
    Reg1 => Reg1, Reg2 => Reg2
  );

etageEX_inst: entity work.etageEX(etageEX_arch)
  port map(
    Op1_EX => Op1_EX, Op2_EX => Op2_EX,
    ExtImm_EX => ExtImm_EX,
    Res_fwd_ME => Res_fwd_ME,
    Res_fwd_ER => Res_fwd_ER,
    Op3_EX => Op3_EX, EA_EX => EA_EX, 
    EB_EX => EB_EX, ALUCtrl_EX => ALUCtrl_EX,
    ALUSrc_EX => ALUSrc_EX, Res_EX => Res_EX,
    WD_EX => WD_EX, npc_fw_br => npc_fw_br,
    CC => CC, Op3_EX_out => Op3_EX_out
  );

etageME_inst: entity work.etageME(etageME_arch)
  port map(
    Res_ME => Res_ME, WD_ME => WD_ME,
    Op3_ME => Op3_ME, clk => CLK,
    MemWR_Mem => MemWR_Mem, 
    Res_Mem_ME => Res_Mem_ME,
    Res_ALU_ME => Res_ALU_ME,
    Res_fwd_ME => Res_fwd_ME,
    Op3_ME_out => Op3_ME_out
  );

etageER_inst: entity work.etageER(etageER_arch)
  port map(
    Res_Mem_RE => Res_Mem_RE,
    Res_ALU_RE => Res_ALU_RE,
    MemToReg_RE => MemToReg_RE,
    Op3_RE => Op3_RE, Res_RE => Res_RE
  );-- Clock process 

  P_E_CLK: process
begin
	CLK <= '1';
	wait for clkpulse;
	CLK <= '0';
	wait for clkpulse;
end process P_E_CLK;

-- Timeout process
P_TIMEOUT: process
begin
	wait for TIMEOUT;
	assert FALSE report "TIMEOUT SIMULATION !!!" severity FAILURE;
end process P_TIMEOUT;
-----------------------------
-- Test process
P_Test: process
begin

  -- Test étage FE.
  npc <= (1=>'1', others => '0');
  PCSrc_ER <= '1';
  Bpris_EX <= '0';
  GEL_LI <= '1';
  i_FE <= (others => 'X');
  wait until (CLK = '1');
  -- Résultat : le signal pc_plus_4 devrait prendre
  -- la valeur 6 au deuxième front montant d'horloge.
  wait until (CLK = '0');

  -- Test étage DE.
  i_DE <= (0 => '1', 1 => '1', 14 => '1', 15 => '1', 16 => '1', others => '0');
  RegSrc <= ('1', '1'); -- Modifier RegSrc pour voir des changements sur Reg1 et Reg2
  wait until (CLK = '1');
  -- Résultat : suivant les valuers de Reg1 et Reg2, vérifier qu'elles soient correctes.
  wait until (CLK = '0');

  -- Test étage EX pas vrm possible pour l'instant.

  -- Test étage ME.
  Res_ME <= (0 => '1', others => '0');
  MemWR_Mem <= '1';
  WD_ME <= (1 => '1', others => '0');
  wait until (CLK = '1');
  -- Résultat : Vérifier que Res_Mem_ME est égal à WD_Me. 
  wait until (CLK = '0');

  -- Test étage RE y'a vraiment rien à faire là.


end process P_Test;

end;
