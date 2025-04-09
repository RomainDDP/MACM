-------------------------------------------------------

-- Unité de contrôle

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity controlUnit is
  port(
  instr : in std_logic_vector(31 downto 0);
  PCsrc, RegWr, MemToReg, MemWr, Branch, CCWr, AluSrc : out std_logic;
  AluCtrlrr, ImmSrc, RegSrc : out std_logic_vector(1 downto 0);
  Cond : out std_logic_vector(3 downto 0)
);
end entity;

architecture controlUnit_arch of controlUnit is
begin

  -- Cond :
  Cond <= instr(31 downto 28);
  
  -- AluCtrl :
  AluCtrl <=  ("00") when instr(27 downto 26) = ("10") else
              ("00") when instr(27 downto 26) = ("00") AND instr(24 downto 21) = ("0100") else
              ("01") when instr(27 downto 26) = ("00") AND instr(24 downto 21) = ("0010") else
              ("10") when instr(27 downto 26) = ("00") AND instr(24 downto 21) = ("0000") else
              ("11") when instr(27 downto 26) = ("00") AND instr(24 downto 21) = ("1100") else
              ("01") when instr(27 downto 26) = ("00") AND instr(24 downto 21) = ("1010") else
              ("00") when instr(27 downto 26) = ("01") AND instr(23) = '0' else
              ("01") when instr(27 downto 26) = ("01") AND instr(23) = '1' else ("XX");
  -- Branch :
  Branch <= '1' when instr(27 downto 26) = ("10") else '0';

  -- MemToReg :
  MemToReg <= '1' when instr(27 downto 26) = ("01") else '0';

  -- MemWr :
  MemWr <= '1' when instr(27 downto 26) = ("01") else '0';

  -- AluSrc :
  AluSrc <= '0' when instr(27 downto 26) = ("00") AND instr(25) = '0' else
            '0' when instr(27 downto 26) = ("00") AND instr(25) = '0' AND instr(20) = '1' else
            '1';

  -- ImmSrc :
  ImmSrc <= ("00") when instr(27 downto 26) = ("00") else 
            ("10") when instr(27 downto 26) = ("10") else 
            ("01");

  -- RegWr : Check plus loin à cause de COMP et reg/reg.
  RegWr <= '0' when instr(27 downto 24) = ("0001") else 
           '0' when instr(27 downto 26) = ("01") AND instr(20) = '1' else 
           '0' when instr(27 downto 26) = ("10") else 
           '1';

  -- RegSrc :
  RegSrc <= ("10") when instr(27 downto 26) = ("01") AND instr(20) = '0' else
            ("01") when instr(27 downto 26) = ("10") else 
            ("00");

  -- PCsrc :
  PCsrc <= '1' when instr(27 downto 26) = ("00") AND instr(25) = '0' AND instr(15 downto 12) = ("1111") else
           '0' when instr(27 downto 26) = ("00") AND instr(25) = '0' AND instr(20) = '1' else
           '1' when instr(27 downto 26) = ("00") AND instr(25) = '1' AND instr(15 downto 12) = ("1111") else
           '0' when instr(27 downto 26) = ("00") AND instr(25) = '1' else
           '1' when instr(27 downto 26) = ("01") AND instr(20) = '1' AND instr(15 downto 12) = ("1111") else
           '0' when instr(27 downto 26) = ("01") AND instr(20) = '1' else
           '0' when instr(27 downto 26) = ("01") AND instr(20) = '0' else
           '0' when instr(27 downto 26) = ("10") else 'X';

  -- CCWr :
  CCWr <= '0' when instr(27 downto 26) = ("00") AND instr(25) = '0' AND instr(20) = '0' else
          '1' when instr(27 downto 26) = ("00") AND instr(25) = '0' AND instr(20) = '1' else
          '0' when instr(27 downto 26) = ("00") AND instr(25) = '1' AND instr(20) = '0' else
          '1' when instr(27 downto 26) = ("00") AND instr(25) = '1' AND instr(20) = '1' else
          '0' when instr(27 downto 26) = ("01") AND instr(20) = '1' else 
          '0' when instr(27 downto 26) = ("01") AND instr(20) = '0' else
          '0' when instr(27 downto 26) = ("10") else 'X';
end;

-------------------------------------------------------

-- Unité de contrôle

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity condUnit is
  port(
  CCWr_EX : in std_logic;
  Cond, CC_EX, CC : in std_logic_vector(3 downto 0);
  CondEx : out std_logic;
  CC_bis : out std_logic_vector(3 downto 0)
);
end entity;

architecture condUnit_arch of condUnit is
  signal tmp_CondEx, N, Z, C, V : std_logic;
begin

  N <= CC(3); Z <= CC(2); C <= CC(1); V <= CC(0);
  tmp_CondEx <= '1' when Cond = ("0000") and Z = '1' else
                '1' when Cond = ("0001") and Z = '0' else
                '1' when Cond = ("0010") and C = '1' else
                '1' when Cond = ("0011") and C = '0' else
                '1' when Cond = ("0100") and N = '1' else
                '1' when Cond = ("0101") and N = '0' else
                '1' when Cond = ("0110") and V = '1' else
                '1' when Cond = ("0111") and V = '0' else
                '1' when Cond = ("1000") and C = '1' and Z = '0' else
                '1' when Cond = ("1001") and (C = '1' OR Z = '1') else
                '1' when Cond = ("1010") and N = V else
                '1' when Cond = ("1011") AND N /= V else
                '1' when Cond = ("1100") AND Z = '0' AND N = V else
                '1' when Cond = ("1101") AND (Z = '1' OR N /= V) else
                '1' when Cond = ("1110") else '0';

  CC_bis <= CC when CCWr_EX = '1' and tmp_CondEx = '1' else
         CC_EX;

  CondEx <= tmp_CondEx;
end;

