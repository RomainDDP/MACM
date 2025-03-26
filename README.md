# TPs MACM

Fichiers de base pour la conception d'un processeur pipeliné sur la base d'une ISA ARM simplifiée. Réalisé pendant les TPs de Micro Architecture et Conception des Microprocesseurs.

# Commandes pour la compilation

```
ghdl -a --ieee=synopsys -fexplicit -Whide reg_bank.vhd mem.vhd combi.vhd etages.vhd test_etage.vhd
ghdl -e --ieee=synopsys -fexplicit -Whide test_etageFE
ghdl -r --ieee=synopsys -fexplicit -Whide test_etageFE --vcd=etageFE.vcd
```
