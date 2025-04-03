# Variables
SRC = reg_bank.vhd mem.vhd combi.vhd etages.vhd units.vhd proc.vhd
TOP_ENTITY = controlUnit
EXEC = sim

# Compiler
GHDL = ghdl
GHDLFLAGS = --ieee=synopsys -fexplicit -Whide
# Default target
all: analyze elaborate run

# Analyze (compile) all VHDL source files
analyze:
	$(GHDL) -a $(GHDLFLAGS) $(SRC)

# Elaborate the design
elaborate: analyze
	$(GHDL) -e $(GHDLFLAGS) $(TOP_ENTITY)

# Run the simulation
run: elaborate
	$(GHDL) -r $(GHDLFLAGS) $(TOP_ENTITY) --wave=$(EXEC).ghw

# View the waveform (requires GTKWave)
view:
	gtkwave $(EXEC).ghw &

# Clean generated files
clean:
	rm -f *.o *.cf $(EXEC).ghw $(TOP_ENTITY) work-obj93.cf

.PHONY: all analyze elaborate run view clean

