-------------------------------------------------------

-- Processeur complet. 

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;



entity Processor is
  port(
    clk,  init, Gel_LI, Gel_DI, RAZ_DI, Clr_EX : in std_logic;
    EA_EX, EB_EX : out std_logic_vector(1 downto 0);
    instr_DE: out std_logic_vector(31 downto 0);
    a1, a2, rs1, rs2, CC, op3_EX_out, op3_ME_out, op3_RE_out: out std_logic_vector(3 downto 0)
);
end entity;

