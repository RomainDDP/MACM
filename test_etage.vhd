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

-- etageDE_inst: entity work.etageDE(etageDE_arch)
--   port map(
--
--   );

-- Clock process 
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
P_Test_FE: process
begin

  -- Initialisation des ports
  npc <= (1=>'1', others => '0');
  PCSrc_ER <= '1';
  Bpris_EX <= '0';
  GEL_LI <= '1';
  i_FE <= (others => 'X');
  wait until (CLK = '1');
  
  -- assert (pc_plus_4 = CONV_STD_LOGIC_VECTOR(6, 32) )
  --   report "PC + 4 should be equal 6 !"
  --   severity WARNING;
end process P_Test_FE;

-- P_Test_DE: process
-- begin
--
--   -- Initialisation des ports
--   npc <= (1=>'1', others => '0');
--   PCSrc_ER <= '1';
--   Bpris_EX <= '0';
--   GEL_LI <= '1';
--   i_FE <= (others => 'X');
--   wait until (CLK = '1');
--   
--   assert (pc_plus_4 = CONV_STD_LOGIC_VECTOR(6, 32) )
--     report "PC + 4 should be equal 6 !"
--     severity WARNING;
-- end process P_Test_DE;
end behaviour;

