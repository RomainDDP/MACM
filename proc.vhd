-------------------------------------------------------

-- Processeur complet (sans doute pas fonctionnel).

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;



entity Processor is
  port(
    clk, init : in std_logic
);
end entity;

architecture processor_arch of Processor is

  signal ALUSrc_EX, MemWr_Mem, PCsrc_DE, PCsrc_EX, PCsrc_ME, PCSrc_ER, Bpris_EX, 
    Gel_LI, Gel_DI, RAZ_DI, RegWR, Clr_EX, MemToReg_RE, MemToReg_EX : std_logic;

  signal RegSrc, EA_EX, EB_EX, immSrc, ALUCtrl_EX : std_logic_vector(1 downto 0);
  signal a1, a2, CC, op3_EX_out, op3_ME_out, op3_RE_out, Reg1, Reg2: std_logic_vector(3 downto 0);

  signal instr_DE : std_logic_vector(31 downto 0);
  signal RegWr_ME : std_logic;

  signal LDR_Stall : std_logic;

begin

 dataPath : entity work.dataPath
 port map(
  --in
  clk => clk,
  init => init,
  ALUSrc_EX => ALUSrc_EX,
  MemWr_Mem => MemWr_Mem,
  PCSrc_ER => PCSrc_ER,
  Bpris_EX => Bpris_EX,
  Gel_LI => Gel_LI,
  Gel_DI => Gel_DI,
  RAZ_DI => RAZ_DI,
  RegWr => RegWr,
  Clr_EX => Clr_EX,
  MemToReg_RE => MemToReg_RE,

  RegSrc => RegSrc,
  EA_EX => EA_EX,
  EB_EX => EB_EX,
  immSrc => immSrc,
  ALUCtrl_EX => ALUCtrl_EX,

  --out
  instr_DE => instr_DE,
  a1 => a1,
  a2 => a2,
  CC => CC,
  op3_EX_out => op3_EX_out,
  op3_RE_out => op3_RE_out,
  op3_ME_out => op3_ME_out,
  Reg1 => Reg1,
  Reg2 => Reg2
  );

  unitsPath : entity work.unitsPath
  port map(
  --in
  clk => clk,
  Clr_EX => Clr_EX,
  instr_DE => instr_DE,
  CC => CC,

  --out
  Bpris_EX => Bpris_EX,
  PCsrc_ER => PCsrc_ER,
  RegWr => RegWr,
  MemWR_Mem => MemWR_Mem,
  ALUSrc_EX => ALUSrc_EX,
  RegWr_ME => RegWr_ME,
  MemToReg_RE => MemToReg_RE,
  RegSrc => RegSrc,
  immSrc => immSrc,
  ALUCtrl_EX => ALUCtrl_EX,
  MemToReg_EX => MemToReg_EX,

  PCsrc_DE_out => PCsrc_DE,
  PCsrc_EX_out => PCsrc_EX,
  PCsrc_ME_out => PCsrc_ME
  );

 EA_EX <= "10" when a1 = op3_ME_out AND RegWr_ME = '1' else
          "01" when a1 /= op3_ME_out AND a1 = op3_RE_out AND RegWr = '1' else
          "00";
 EB_EX <= "10" when a2 = op3_ME_out AND RegWr_ME = '1' else
          "01" when a2 /= op3_ME_out AND a2 = op3_RE_out AND RegWr = '1' else
          "00";

 LDR_Stall <= '1' when (Reg1 = op3_EX_out OR Reg2 = op3_EX_out) AND MemToReg_EX = '1';
 Clr_EX <= not (LDR_Stall OR Bpris_EX);
 Gel_LI <= not (LDR_Stall OR PCsrc_DE OR PCsrc_EX OR PCsrc_ME);
 Gel_DI <= not (PCsrc_DE OR PCsrc_EX OR PCsrc_ME OR PCsrc_ER OR Bpris_EX);
end;

