RTL_DIR := ../rtl
TB_DIR  := .

SOURCES := $(TB_DIR)/tb_chi_postAGEMA.v \
           $(RTL_DIR)/chi_xilinx_netlist_GHPCLL__d1.v \
           $(RTL_DIR)/chi.v \
           $(RTL_DIR)/LUT3_GHPC.v

OUT := sim.out

.PHONY: all run clean

all: run

$(OUT): $(SOURCES)
	iverilog -o $(OUT) $(SOURCES)

run: $(OUT)
	vvp $(OUT)

clean:
	rm -f $(OUT) *.vcd
