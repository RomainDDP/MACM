-------------------------------------------------------

-- Chemin de données

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity unitsPath is
  port(
    clk, Clr_EX : in std_logic;
    instr_DE : in std_logic_vector(31 downto 0);
    CC : in std_logic_vector(3 downto 0);

    Bpris_EX, PCsrc_ER, RegWr, MemWR_Mem, AluSrc_EX, RegWr_ME, MemToReg_RE : out std_logic;
    RegSrc, ImmSrc, AluCtrl_EX : out std_logic_vector(1 downto 0)
  );
end entity;

architecture unitsPath_arch of unitsPath is

  signal Branch_DE, PCsrc_DE, RegWR_DE, MemWR_DE, MemToReg_DE, CCWr_DE, AluSrc_DE,
  Branch_EX, PCsrc_EX, tmp_PCsrc_EX, RegWR_EX, tmp_RegWR_EX, MemWR_EX, MemToReg_EX, CCWr_EX, Cond_EX,
  PCsrc_ME, RegWr_ME_t: std_logic;
  signal Cond_DE, Cond, CC_EX, CC_DE: std_logic_vector(3 downto 0);
  signal AluCtrl_DE : std_logic_vector(1 downto 0); 

begin

-- Control Unit

  unit_ctrl : entity work.controlUnit
  port map(
    instr => instr_DE,
    Cond => Cond_DE,
    Branch => Branch_DE,
    PCSrc => PCsrc_DE,
    RegWr => RegWr_DE,
    MemWR => MemWR_DE,
    MemToReg => MemToReg_DE,
    CCWr => CCWr_DE,
    AluCtrl => AluCtrl_DE,
    AluSrc => AluSrc_DE,
    ImmSrc => ImmSrc,
    RegSrc => RegSrc
  );

-- Condition Unit

  unit_cond : entity work.condUnit
  port map(
    CCwr_EX => CCWr_EX,
    Cond => Cond,
    CC => CC,
    CC_EX => CC_EX,
    
    CondEX => Cond_EX,
    CC_bis => CC_DE
  );
  
-- Branch signal

  reg_branch_de : entity work.reg1
  port map (
    source => Branch_DE,
    output => Branch_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

  Bpris_EX <= Branch_EX and Cond_EX; 

-- PCsrc signal

  reg_pcsrc_de : entity work.reg1
  port map (
    source => PCsrc_DE,
    output => PCsrc_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

  tmp_PCsrc_EX <= PCsrc_EX AND Cond_EX;
  reg_pcsrc_ex : entity work.reg1
  port map (
    source => tmp_PCsrc_EX,
    output => PCsrc_ME,
    clk => clk,
    wr => '1',
    raz => '1'
  );
 
  reg_pcsrc_me : entity work.reg1
  port map (
    source => PCsrc_ME,
    output => PCsrc_ER,
    clk => clk,
    wr => '1',
    raz => '1'
  );

-- RegWr signal

  reg_regwr_de : entity work.reg1
  port map (
    source => RegWr_DE,
    output => RegWr_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

  tmp_RegWR_EX <= RegWr_EX AND Cond_EX;
  reg_regwr_ex : entity work.reg1
  port map (
    source => tmp_RegWR_EX,
    output => RegWr_ME_t,
    clk => clk,
    wr => '1',
    raz => '1' 
  );

  reg_regwr_me : entity work.reg1
  port map (
    source => RegWr_ME_t,
    output => RegWr,
    clk => clk,
    wr => '1',
    raz => '1' 
  );

  RegWr_ME <= RegWr_ME_t;
-- MemWr signal

  reg_memwr_de : entity work.reg1
  port map (
    source => MemWR_DE,
    output => MemWR_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );
 
  reg_memwr_ex : entity work.reg1
  port map (
    source => MemWR_EX,
    output => MemWR_Mem,
    clk => clk,
    wr => '1',
    raz => '1'
  );

-- MemToReg signal

  reg_memtoreg_de : entity work.reg1
  port map (
    source => MemToReg_DE,
    output => MemToReg_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );
  
  reg_memtoreg_ex : entity work.reg1
  port map (
    source => MemToReg_EX,
    output => MemToReg_ME,
    clk => clk,
    wr => '1',
    raz => '1'
  );

  reg_memtoreg_me : entity work.reg1
  port map (
    source => MemToReg_ME,
    output => MemToReg_RE,
    clk => clk,
    wr => '1',
    raz => '1' 
  );

-- CCWR signal.

  reg_ccwr : entity work.reg1
  port map (
    source => CCWr_DE,
    output => CCWr_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

-- AluCtrl signal.

  reg_aluctrl : entity work.reg2
  port map (
    source => AluCtrl_DE,
    output => AluCtrl_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

-- AluSrc signal.

  reg_alusrc : entity work.reg1
  port map (
    source => AluSrc_DE,
    output => AluSrc_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

-- Cond signal.

  reg_cond : entity work.reg4
  port map (
    source => Cond_DE,
    output => Cond,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

-- CC signal.

  reg_cc : entity work.reg4
  port map (
    source => CC_DE,
    output => CC_EX,
    clk => clk,
    wr => '1',
    raz => Clr_EX
  );

end architecture;
