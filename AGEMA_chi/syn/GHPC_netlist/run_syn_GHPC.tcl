# run_synth_GHPC.tcl
# Baseline synthesis + implementation for chi_GHPC_top
# (chi_xilinx_netlist_GHPC__d1.v + LFSR wrapper)
# using Verilog LUT3_GHPC gadget files.

set HOME_DIR $env(HOME)
set REPO     $HOME_DIR/BarberBerkofLeWeberMQP
set GHPC     $REPO/Gadget_chi/GHPC

#create_project -in_memory -part xc7k480tfbg676-1
create_project -in_memory -part xc7k70tfbv676-1

read_verilog [list \
    $REPO/AGEMA_chi/rtl/LFSR31.v \
    $GHPC/rtl/Verilog/AGEMA/GHPC_reg.v \
    $GHPC/rtl/Verilog/AGEMA/GHPC_AND_reg.v \
    $GHPC/rtl/Verilog/AGEMA/GHPC_Step2.v \
    $GHPC/rtl/Verilog/AGEMA_FPGA/GHPC_Step1_LUT3.v \
    $GHPC/rtl/Verilog/AGEMA_FPGA/GHPC_Gadget_LUT3.v \
    $GHPC/rtl/Verilog/AGEMA_FPGA/LUT3_GHPC.v \
    $REPO/AGEMA_chi/rtl/GHPC/chi_xilinx_netlist_GHPC__d1.v \
    $REPO/AGEMA_chi/rtl/GHPC/chi_xilinx_netlist_GHPC_wrapper.v \
]

synth_design -top chi_xilinx_netlist_GHPC_wrapper \
             -part xc7k70tfbv676-1 \
             -flatten_hierarchy none


create_clock -name clk -period 10 [get_ports clk]
# Exclude LFSR path
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *lfsr*}]
set_false_path -to   [get_cells -hierarchical -filter {NAME =~ *lfsr*}]

opt_design
place_design
route_design

file mkdir $REPO/AGEMA_chi/syn/GHPC_netlist/results
file mkdir $REPO/AGEMA_chi/syn/GHPC_netlist/results/logs

report_timing_summary -file $REPO/AGEMA_chi/syn/GHPC_netlist/results/timing_GHPC.rpt
report_utilization    -file $REPO/AGEMA_chi/syn/GHPC_netlist/results/util_GHPC.rpt

foreach f [glob -nocomplain *.log *.jou *.pb *.str] {
    file rename -force $f $REPO/AGEMA_chi/syn/GHPC_netlist/results/logs/$f
}
