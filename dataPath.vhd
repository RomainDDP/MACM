-------------------------------------------------------

-- Chemin de données

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity dataPath is
  port(
    clk,  init, ALUSrc_EX, MemWr_Mem, MemWr_RE, PCSrc_ER, Bpris_EX, Gel_LI, Gel_DI, RAZ_DI, RegWR, Clr_EX, MemToReg_RE : in std_logic;
    RegSrc, EA_EX, EB_EX, immSrc, ALUCtrl_EX : in std_logic_vector(1 downto 0);
    instr_DE: out std_logic_vector(31 downto 0);
    a1, a2, rs1, rs2, CC, op3_EX_out, op3_ME_out, op3_RE_out: out std_logic_vector(3 downto 0)
);
end entity;

architecture dataPath_arch of dataPath is
  signal Res_RE, npc_fwd_br, pc_plus_4, i_FE, i_DE, Op1_DE, Op2_DE, Op1_EX, Op2_EX, extImm_DE, extImm_EX,
          Res_EX, Res_ME, WD_EX, WD_ME, Res_Mem_ME, Res_Mem_RE, Res_ALU_ME, Res_ALU_RE, Res_fwd_ME, instr_DE_t : std_logic_vector(31 downto 0);
  signal Op3_DE, Op3_EX, a1_DE, a1_EX, a2_DE, a2_EX, Op3_EX_out_t, Op3_ME, Op3_ME_out_t, Op3_RE, Op3_RE_out_t : std_logic_vector(3 downto 0);

  -- variables pour control et cond.
  signal Branch_DE, PCsrc_DE, RegWR_DE, MemWR_DE, MemToReg_DE, CCWr_DE, AluCtrl_DE, AluSrc_DE : std_logic;
  signal Cond_DE : std_logic_vector(3 downto 0);
  begin

  -- FE
  etage_FE : entity work.etageFE(etageFE_arch)
  port map (
    npc => Res_RE,
    npc_fw_br => npc_fwd_br,
    pc_plus_4 => pc_plus_4,
    i_FE => i_FE,
    clk => clk,
    PCSrc_ER => PCSrc_ER,
    Bpris_EX => Bpris_EX,
    Gel_LI => Gel_LI
  );

  reg_i_FE : entity work.reg32sync(arch_reg_sync)
  port map (
    source => i_FE,
    output => instr_DE_t,
    clk => clk,
    wr => Gel_DI,
    raz => RAZ_DI
  );

  -- DE
  etage_DE : entity work.etageDE(etageDE_arch)
  port map (
  i_DE => instr_DE_t,
  pc_plus_4 => pc_plus_4,
  WD_ER => Res_RE,
  Op3_ER => Op3_RE_out_t,
  clk => clk,
  init => init,
  RegSrc => RegSrc,
  immSrc => immSrc,
  RegWR => RegWR,
 
  Reg1 => a1_DE,
  Reg2 => a2_DE,
  Op1 => Op1_DE,
  Op2 => Op2_DE,
  Op3_DE => Op3_DE,
  ExtImm => ExtImm_DE
  );

  reg_a1 : entity work.Reg4(arch_reg)
  port map(
    source => a1_DE,
    output => a1_EX,
    wr => '1',
    raz => Clr_EX,
    clk => clk
  );

  reg_a2 : entity work.Reg4(arch_reg)
  port map(
    source => a2_DE,
    output => a2_EX,
    wr => '1',
    raz => Clr_EX,
    clk => clk
  );

  reg_op3 : entity work.Reg4(arch_reg)
  port map(
    source => Op3_DE,
    output => Op3_EX,
    wr => '1',
    raz => Clr_EX,
    clk => clk
  );

  reg_op1 : entity work.reg32sync(arch_reg_sync)
  port map (
    source => Op1_DE,
    output => Op1_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

  reg_op2 : entity work.reg32sync(arch_reg_sync)
  port map (
    source => Op2_DE,
    output => Op2_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

  reg_extImm : entity work.reg32sync(arch_reg_sync)
  port map (
    source => extImm_DE,
    output => extImm_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

  -- EX
  etage_EX : entity work.etageEX(etageEX_arch)
  port map(
    Op1_EX => Op1_EX,
    Op2_EX => Op2_EX,
    Op3_EX => Op3_EX,
    ExtImm_EX => extImm_EX,
    Res_fwd_ME => Res_fwd_ME,
    Res_fwd_ER => Res_RE,
    EA_EX => EA_EX,
    EB_EX => EB_EX,
    ALUCtrl_EX => ALUCtrl_EX,
    ALUSrc_EX => ALUSrc_EX,
   
    CC => CC,
    Op3_EX_out => Op3_EX_out_t,
    Res_EX => Res_EX,
    WD_EX => WD_EX,
    npc_fw_br => npc_fwd_br
  );

  reg_Res_EX : entity work.Reg32sync(arch_reg_sync)
  port map (
    source => Res_EX,
    output => Res_ME,
    wr => '1',
    raz => '1',
    clk => clk
  );

  reg_WD_EX : entity work.Reg32sync(arch_reg_sync)
  port map (
    source => WD_EX,
    output => WD_ME,
    wr => '1',
    raz => '1',
    clk => clk
  );

  reg_Op3_EX : entity work.Reg4(arch_reg)
  port map (
    source => Op3_EX_out_t,
    output => Op3_ME,
    wr => '1',
    raz => '1',
    clk => clk
  );

  -- ME
  etage_ME : entity work.etageME(etageME_arch)
  port map (
    Res_ME => Res_ME,
    WD_ME => WD_ME ,
    Op3_ME => Op3_ME,
    clk => clk,
    MemWr_Mem => MemWr_Mem,

    Op3_ME_out => Op3_ME_out_t,
    Res_Mem_ME => Res_Mem_ME,
    Res_ALU_ME => Res_ALU_ME,
    Res_fwd_ME => Res_fwd_ME
  );

  reg_Res_Mem : entity work.Reg32sync(arch_reg_sync)
  port map (
    source => Res_Mem_ME,
    output => Res_Mem_RE,
    wr => '1',
    raz => '1',
    clk => clk
  );

  reg_Res_ALU : entity work.Reg32sync(arch_reg_sync)
  port map (
    source => Res_ALU_ME,
    output => Res_ALU_RE,
    wr => '1',
    raz => '1',
    clk => clk
  );

  E_RE_Op3 : entity work.Reg4(arch_reg)
  port map (
    source => Op3_ME_out_t,
    output => Op3_RE,
    wr => '1',
    raz => '1',
    clk => clk
  );

  etage_RE : entity work.etageER(etageER_arch)
  port map (
    Res_Mem_RE => Res_Mem_RE,
    Res_ALU_RE => Res_ALU_RE,
    Op3_RE => Op3_RE,
    MemToReg_RE => MemToReg_RE,

    Op3_RE_out => Op3_RE_out_t,
    Res_RE => Res_RE
  );

  instr_DE <= instr_DE_t;
  a1 <= a1_EX;
  a2 <= a2_EX;
  op3_EX_out <= op3_EX_out_t;
  op3_ME_out <= op3_ME_out_t;
  op3_RE_out <= op3_RE_out_t;

  -- Control Unit
  unit_ctrl : entity work.controUnit(controlUnit_arch)
  port map(
    instr => instr_DE_t,
    Cond => Cond_DE,
    Branch => Branch_DE,
    PCSrc => PCsrc_DE,
    RegWr => RegWr_DE,
    MemWR => MemWR_DE,
    CCWr => CCWr_DE,
    AluCtrl => AluCtrl_DE,
    AluSrc => AluSrc_DE,
    ImmSrc => immSrc,
    RegSrc => RegSrc
  );

  


end architecture;
