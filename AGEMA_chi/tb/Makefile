# # ==============================================================================
# # Makefile for Post-AGEMA Mixed-Language Simulation (GHDL + Yosys + Icarus)
# # Target DUT Wrapper: LUT3_GHPC
# # Testbench: tb_chi_postAGEMA.v
# # Location: ./AGEMA_chi/tb/
# # ==============================================================================

# # Tool definitions
# GHDL     := ghdl
# YOSYS    := yosys
# IVERILOG := iverilog
# VVP      := vvp

# # Relative Directory Paths relative to AGEMA_chi/tb/
# ROOT_DIR := ../..
# GHPC_DIR := $(ROOT_DIR)/GHPC_Gadget
# RTL_DIR  := ../rtl
# TB_DIR   := .

# # File Declarations
# VHDL_SRCS := $(GHPC_DIR)/GHPC_pkg.vhd \
#              $(GHPC_DIR)/GHPC_reg.vhd \
#              $(GHPC_DIR)/reg.vhd \
#              $(GHPC_DIR)/GHPC_AND_reg.vhd \
#              $(GHPC_DIR)/GHPC_Step1.vhd \
#              $(GHPC_DIR)/GHPC_Step2.vhd \
#              $(GHPC_DIR)/GHPC_Gadget.vhd

# WRAPPER_VERILOG := $(RTL_DIR)/LUT3_GHPC.v
# NETLIST_VERILOG := $(RTL_DIR)/chi_xilinx_netlist_GHPCLL__d1.v
# GOLDEN_VERILOG  := $(RTL_DIR)/chi.v
# TB_VERILOG      := $(TB_DIR)/tb_chi_postAGEMA_v2.v

# SYNTH_OUT       := LUT3_GHPC_synth.v
# SIM_EXEC        := sim.vvp

# # Declare parameters at top of Makefile for clarity
# IN_SIZE     ?= 3
# OUT_SIZE    ?= 1
# LOW_LATENCY ?= 1
# PIPELINE    ?= 1

# # Default target
# .PHONY: all clean sim

# all: sim

# # 1. Analyze VHDL sources into GHDL library work
# ghdl_analyze: $(VHDL_SRCS)
# 	@echo "=== [1/4] Analyzing VHDL sources with GHDL ==="
# 	$(GHDL) -a --std=08 $(VHDL_SRCS)

# # 2. Synthesize VHDL + Verilog Wrapper into a unified Verilog module with Yosys
# $(SYNTH_OUT): ghdl_analyze $(WRAPPER_VERILOG)
# 	@echo "=== [2/4] Synthesizing using Yosys + GHDL plugin ==="
# 	$(YOSYS) -m ghdl -p " \
# 		ghdl --std=08 -gin_size=$(IN_SIZE) -gout_size=$(OUT_SIZE) -glow_latency=$(LOW_LATENCY) -gpipeline=$(PIPELINE) GHPC_Gadget; \
# 		read_verilog -defer $(WRAPPER_VERILOG); \
# 		hierarchy -check -top LUT3_GHPC; \
# 		proc; opt; memory; opt; \
# 		flatten; \
# 		opt_expr; opt_clean; \
# 		rename -hide; \
# 		write_verilog -noattr -noexpr $(SYNTH_OUT); \
# 	"	
# # 3. Compile synthesized netlist, golden model, and testbench with Icarus Verilog
# $(SIM_EXEC): $(SYNTH_OUT) $(NETLIST_VERILOG) $(GOLDEN_VERILOG) $(TB_VERILOG)
# 	@echo "=== [3/4] Compiling Verilog modules with Icarus Verilog ==="
# 	$(IVERILOG) -g2001 -o $(SIM_EXEC) \
# 	  $(TB_VERILOG) \
# 	  $(NETLIST_VERILOG) \
# 	  $(GOLDEN_VERILOG) \
# 	  $(SYNTH_OUT)

# # 4. Execute simulation via vvp
# sim: $(SIM_EXEC)
# 	@echo "=== [4/4] Executing Simulation ==="
# 	$(VVP) $(SIM_EXEC)

# # Clean build artifacts
# clean:
# 	@echo "=== Cleaning build directory ==="
# 	rm -f *.cf $(SYNTH_OUT) $(SIM_EXEC)


# ==============================================================================
# Makefile for Post-AGEMA Functional Verification (Run from tb/ directory)
# ==============================================================================

# Directory Paths
GADGET_DIR = ../../GHPC_Gadget/
RTL_DIR    = ../rtl
TB_DIR     = .

# VHDL Source Files in GHPC_Gadget
VHDL_SRCS = \
	$(GADGET_DIR)/GHPC_pkg.vhd \
	$(GADGET_DIR)/reg.vhd \
	$(GADGET_DIR)/GHPC_AND_reg.vhd \
	$(GADGET_DIR)/GHPC_Step1.vhd \
	$(GADGET_DIR)/GHPC_Step2.vhd \
	$(GADGET_DIR)/GHPC_Gadget.vhd

# Verilog Files for Simulation
VERILOG_SRCS = \
	$(RTL_DIR)/GHPC_Gadget_auto.v \
	$(RTL_DIR)/LUT3_GHPC.v \
	$(RTL_DIR)/chi.v \
	$(RTL_DIR)/chi_xilinx_netlist_GHPCLL__d1.v

# Custom/Primitive Cell Models (if needed by AGEMA netlist)
# CELL_MODELS = $(RTL_DIR)/custom_cells.v

# Testbench
TB_SRCS = $(TB_DIR)/tb_chi_postAGEMA_v2.v

# Parameters for GHDL Conversion
IN_SIZE     ?= 3
OUT_SIZE    ?= 1
LOW_LATENCY ?= 1
PIPELINE    ?= 1

.PHONY: all ghdl_to_verilog sim clean

all: sim

# 1. Analyze VHDL files from GHPC_Gadget and synthesize to Verilog in rtl/
ghdl_to_verilog: $(VHDL_SRCS)
	@echo "=== [1/2] Analyzing VHDL from GHPC_Gadget and Generating Verilog ==="
	ghdl -a --std=08 $(VHDL_SRCS)
	yosys -m ghdl -p " \
		ghdl --std=08 -gin_size=$(IN_SIZE) -gout_size=$(OUT_SIZE) -glow_latency=$(LOW_LATENCY) -gpipeline=$(PIPELINE) GHPC_Gadget; \
		proc; opt; \
		write_verilog -noattr $(RTL_DIR)/GHPC_Gadget_auto.v; \
	"

# 2. Compile simulation using Icarus Verilog
sim.vvp: $(VERILOG_SRCS) $(TB_SRCS)
	@echo "=== [2/2] Compiling Simulation with Icarus Verilog ==="
	iverilog -g2012 -o sim.vvp -I $(RTL_DIR) $(CELL_MODELS) $(VERILOG_SRCS) $(TB_SRCS)

# 3. Run execution driver
sim: sim.vvp
	@echo "=== Executing Testbench ==="
	vvp sim.vvp

clean:
	rm -f sim.vvp *.vcd $(RTL_DIR)/GHPC_Gadget_auto.v work-obj08.cf