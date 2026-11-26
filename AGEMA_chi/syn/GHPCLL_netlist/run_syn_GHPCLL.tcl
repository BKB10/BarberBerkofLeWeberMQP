# run_synth_GHPCLL_netlist.tcl
# Baseline synthesis + implementation for chi_GHPCLL_top
# (chi_xilinx_netlist_GHPCLL__d1.v + LFSR wrapper)

set HOME_DIR $env(HOME)
set REPO     $HOME_DIR/BarberBerkofLeWeberMQP
set GHPCLL   $REPO/Gadget_chi/GHPCLL

create_project -in_memory -part xc7k70tfbv676-1

read_verilog [list \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_reg.v \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_AND_reg.v \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_Step2.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/GHPC_Step1_LUT3.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/GHPC_Gadget_LUT3.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/LUT3_GHPC.v \
    $REPO/AGEMA_chi/rtl/GHPCLL/chi_xilinx_netlist_GHPCLL__d1.v \
    $REPO/AGEMA_chi/rtl/LFSR31.v \
    $REPO/AGEMA_chi/rtl/GHPCLL/chi_xilinx_netlist_GHPCLL_wrapper.v \
]

synth_design -top chi_xilinx_netlist_GHPCLL_wrapper \
             -part xc7k70tfbv676-1 \
             -flatten_hierarchy none

# Debug: log cell names after synthesis
puts "=== LFSR CELLS ==="
foreach c [get_cells -hierarchical -filter {NAME =~ *lfsr*}] {
    puts $c
}

puts "=== CHI CELLS ==="
foreach c [get_cells -hierarchical -filter {NAME =~ *chi_inst*}] {
    puts $c
}

create_clock -name clk -period 10 [get_ports clk]

# False path from LFSR registers to chi registers
set_false_path \
    -from [get_pins -hierarchical -filter {NAME =~ *lfsr*/state_reg*/C}] \
    -to   [get_pins -hierarchical -filter {NAME =~ *chi_inst*/D}]

# False path LFSR internal paths
set_false_path \
    -from [get_pins -hierarchical -filter {NAME =~ *lfsr*/state_reg*/C}] \
    -to   [get_pins -hierarchical -filter {NAME =~ *lfsr*/state_reg*/D}]i

opt_design
place_design
route_design

file mkdir $REPO/AGEMA_chi/syn/GHPCLL_netlist/results
file mkdir $REPO/AGEMA_chi/syn/GHPCLL_netlist/results/logs

report_timing_summary -file $REPO/AGEMA_chi/syn/GHPCLL_netlist/results/timing_GHPCLL_netlist.rpt
report_utilization    -file $REPO/AGEMA_chi/syn/GHPCLL_netlist/results/util_GHPCLL_netlist.rpt

foreach f [glob -nocomplain *.log *.jou *.pb *.str] {
    file rename -force $f $REPO/AGEMA_chi/syn/results/logs/$f
}
