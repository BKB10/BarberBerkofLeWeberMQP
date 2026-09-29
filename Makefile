# ==============================================================================
# Makefile for Post-AGEMA Mixed-Language Simulation (GHDL + Yosys + Icarus)
# Target DUT Wrapper: LUT3_GHPC
# Testbench: tb_chi_postAGEMA.v
# ==============================================================================

# Tool definitions
GHDL     := ghdl
YOSYS    := yosys
IVERILOG := iverilog
VVP      := vvp

# Relative Directory Paths (Project Root: BarberBerkofLeWeberMQP)
GHPC_DIR := ./GHPC_Gadget
TB_DIR   := ./AGEMA_chi/tb
RTL_DIR  := ./AGEMA_chi/rtl

# File Declarations
VHDL_SRCS := $(GHPC_DIR)/GHPC_pkg.vhd \
             $(GHPC_DIR)/GHPC_reg.vhd \
             $(GHPC_DIR)/reg.vhd \
             $(GHPC_DIR)/GHPC_AND_reg.vhd \
             $(GHPC_DIR)/GHPC_Step1.vhd \
             $(GHPC_DIR)/GHPC_Step2.vhd \
             $(GHPC_DIR)/GHPC_Gadget.vhd

WRAPPER_VERILOG := $(RTL_DIR)/LUT3_GHPC.v
NETLIST_VERILOG := $(RTL_DIR)/chi_xilinx_netlist_GHPCLL__d1.v
GOLDEN_VERILOG  := $(RTL_DIR)/chi.v
TB_VERILOG      := $(TB_DIR)/tb_chi_postAGEMA.v

SYNTH_OUT       := LUT3_GHPC_synth.v
SIM_EXEC        := sim.vvp

# Default target
.PHONY: all clean sim

all: sim

# 1. Analyze VHDL sources into GHDL library work
ghdl_analyze: $(VHDL_SRCS)
	@echo "=== [1/4] Analyzing VHDL sources with GHDL ==="
	$(GHDL) -a --std=08 $(VHDL_SRCS)

# 2. Synthesize VHDL + Verilog Wrapper into a unified Verilog module with Yosys
$(SYNTH_OUT): ghdl_analyze $(WRAPPER_VERILOG)
	@echo "=== [2/4] Synthesizing LUT3_GHPC using Yosys + GHDL plugin ==="
	$(YOSYS) -m ghdl -p ' \
	  ghdl --std=08 -e GHPC_Gadget; \
	  read_verilog -defer $(WRAPPER_VERILOG); \
	  hierarchy -check -top LUT3_GHPC; \
	  proc; opt; memory; opt; \
	  write_verilog $(SYNTH_OUT); \
	'

# 3. Compile synthesized netlist, golden model, and testbench with Icarus Verilog
$(SIM_EXEC): $(SYNTH_OUT) $(NETLIST_VERILOG) $(GOLDEN_VERILOG) $(TB_VERILOG)
	@echo "=== [3/4] Compiling Verilog modules with Icarus Verilog ==="
	$(IVERILOG) -g2001 -o $(SIM_EXEC) \
	  $(TB_VERILOG) \
	  $(NETLIST_VERILOG) \
	  $(GOLDEN_VERILOG) \
	  $(SYNTH_OUT)

# 4. Execute simulation via vvp
sim: $(SIM_EXEC)
	@echo "=== [4/4] Executing Simulation ==="
	$(VVP) $(SIM_EXEC)

# Clean build artifacts
clean:
	@echo "=== Cleaning build directory ==="
	rm -f *.cf $(SYNTH_OUT) $(SIM_EXEC)
