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
  signal Res_RE, npc_fwd_br, pc_plus_4, i_FE, i_DE, Op1_DE, Op2_DE, Op1_EX, Op2_EX, extImm_DE, extImm_EX, Res_EX, Res_ME, WD_EX, WD_ME, Res_Mem_ME, Res_Mem_RE, Res_ALU_ME, Res_ALU_RE, Res_fwd_ME, instr_DE_t : std_logic_vector(31 downto 0);
  signal Op3_DE, Op3_EX, a1_DE, a1_EX, a2_DE, a2_EX, Op3_EX_out_t, Op3_ME, Op3_ME_out_t, Op3_RE, Op3_RE_out_t : std_logic_vector(3 downto 0);
begin

  -- FE

  E_FE : entity work.etageFE(etageFE_arch) port map (
    npc => Res_RE,
    npc_fw_br => npc_fwd_br,
    PCSrc_ER => PCSrc_ER,
    Bpris_EX => Bpris_EX, 
    GEL_LI => Gel_LI, 
    clk => clk,
    pc_plus_4 => pc_plus_4, 
    i_FE => i_FE -- va dans registre
  );

  E_FE_inst : entity work.Reg32sync(arch_reg_sync) port map (
    source => i_FE,
    output => instr_DE_t,
    wr => Gel_DI,
    raz => RAZ_DI, 
    clk => clk
  );
 
  -- DE

  E_DE : entity work.etageDE(etageDE_arch) port map (
    i_DE => instr_DE_t, 
    WD_ER => Res_RE, 
    pc_plus_4 => pc_plus_4,
    Op3_ER => op3_RE_out_t,
    RegSrc => RegSrc, 
    ImmSrc => ImmSrc,
    RegWr => RegWR, 
    clk => clk, 
    init => init,

    Reg1 => a1_DE, 
    Reg2 => a2_DE, 
    Op3_DE => Op3_DE,
    Op1 => Op1_DE, 
    Op2 => Op2_DE, 
    extImm => extImm_DE
  );

  E_EX_A1 : entity work.Reg4(arch_reg) port map (
    source => a1_DE,
    output => a1_EX,
    wr => '1',
    raz => Clr_EX, 
    clk => clk
  );

  E_EX_A2 : entity work.Reg4(arch_reg) port map (
    source => a2_DE,
    output => a2_EX,
    wr => '1',
    raz => Clr_EX, 
    clk => clk
  );

  E_EX_Op1 : entity work.Reg32sync(arch_reg_sync) port map (
    source => Op1_DE,
    output => Op1_EX,
    wr => '1',
    raz => Clr_EX, 
    clk => clk
  );

  E_EX_Op2 : entity work.Reg32sync(arch_reg_sync) port map (
    source => Op2_DE,
    output => Op2_EX,
    wr => '1',
    raz => Clr_EX, 
    clk => clk
  );

  E_EX_extImm : entity work.Reg32sync(arch_reg_sync) port map (
    source => extImm_DE,
    output => extImm_EX,
    wr => '1',
    raz => Clr_EX, 
    clk => clk
  );

  E_EX_Op3 : entity work.Reg4(arch_reg) port map (
    source => Op3_DE,
    output => Op3_EX,
    wr => '1',
    raz => Clr_EX, 
    clk => clk
  );
  -- EX
  E_EX : entity work.etageEX(etageEX_arch) port map (
    Op1_EX => Op1_EX, 
    Op2_EX => Op2_EX, 
    ExtImm_EX => extImm_EX, 
    Res_fwd_ME => Res_fwd_ME, 
    Res_fwd_ER => Res_RE, 
    Op3_EX => Op3_EX,
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
  -- ME

  E_ME_Res : entity work.Reg32sync(arch_reg_sync) port map (
    source => Res_EX,
    output => Res_ME,
    wr => '1',
    raz => '1', 
    clk => clk
  );

  E_ME_WD : entity work.Reg32sync(arch_reg_sync) port map (
    source => WD_EX,
    output => WD_ME,
    wr => '1',
    raz => '1', 
    clk => clk
  );

  E_ME_Op3 : entity work.Reg4(arch_reg) port map (
    source => Op3_EX_out_t,
    output => Op3_ME,
    wr => '1',
    raz => '1', 
    clk => clk
  );

  E_ME : entity work.etageME(etageME_arch) port map (
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
  -- RE

  E_RE_Res_Mem : entity work.Reg32sync(arch_reg_sync) port map (
    source => Res_Mem_ME,
    output => Res_Mem_RE,
    wr => '1',
    raz => '1', 
    clk => clk
  );

  E_RE_Res_ALU : entity work.Reg32sync(arch_reg_sync) port map (
    source => Res_ALU_ME,
    output => Res_ALU_RE,
    wr => '1',
    raz => '1', 
    clk => clk
  );

  E_RE_Op3 : entity work.Reg4(arch_reg) port map (
    source => Op3_ME_out_t,
    output => Op3_RE,
    wr => '1',
    raz => '1', 
    clk => clk
  );

  E_RE : entity work.etageER(etageER_arch) port map (
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
  
end architecture;


-------------------------------------------------------

-- Unité de contrôle et condition

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity controlUnit is
  port(
  instr : in std_logic_vector(31 downto 0);
  PCsrc, RegWr, MemToReg, MemWr, Branch, CCWr, AluSrc : out std_logic;
  AluCtrl, ImmSrc, RegSrc : out std_logic_vector(1 downto 0);
  Cond : out std_logic_vector(3 downto 0)
);
end entity;

architecture controlUnit_arch of controlUnit is
begin
  -- AluCtrl :
  AluCtrl <= ("00") when instr(27 downto 26) = ("10") else
            ("00") when instr(27 downto 26) = ("00") AND instr(24 downto 21) = ("0100") else
            ("00") when instr(27 downto 26) = ("01") AND instr(23) = '0' else
            ("01") when instr(27 downto 26) = ("00") AND instr(24 downto 21) = ("0010") else
            ("01") when instr(27 downto 26) = ("00") AND instr(24 downto 21) = ("1010") else
            ("01") when instr(27 downto 26) = ("01") AND instr(23) = '1' else
            ("10") when instr(27 downto 26) = ("00") AND instr(24 downto 21) = ("0000") else
            ("11") when instr(27 downto 26) = ("00") AND instr(24 downto 21) = ("1100") else
            ("XX");
  -- Branch :
  Branch <= '1' when instr(27 downto 26) = ("10") else '0';

  -- MemToReg :
  MemToReg <= '1' when instr(27 downto 26) = ("01") else '0';

  -- MemWr :
  MemWr <= '1' when instr(27 downto 26) = ("01") else '0';

  -- AluSrc :
  AluSrc <= '0' when instr(27 downto 26) = ("00") AND instr(25) = '0' else '1';

  -- ImmSrc :
  ImmSrc <= ("00") when instr(27 downto 26) = ("00") else 
            ("10") when instr(27 downto 26) = ("10") else ("01");

  -- RegWr : Check plus loin à cause de COMP et reg/reg.
  RegWr <= '0' when (instr(27 downto 24) = ("0001")) OR 
                    (instr(27 downto 26) = ("01") AND instr(20) = '1') OR 
                    (instr(27 downto 26) = ("10")) else '1';

  -- RegSrc :
end;
