# run_synth_GHPC.tcl
# Baseline synthesis + implementation for chi_xilinx_netlist_GHPC__d1.v
# using Verilog LUT3_GHPC gadget files.

set HOME_DIR $env(HOME)
set REPO     $HOME_DIR/BarberBerkofLeWeberMQP
set GHPC     $REPO/Gadget_chi/GHPC

create_project -in_memory -part xc7k70tfbv676-1

read_verilog [list \
    $GHPC/rtl/Verilog/AGEMA/GHPC_reg.v \
    $GHPC/rtl/Verilog/AGEMA/GHPC_AND_reg.v \
    $GHPC/rtl/Verilog/AGEMA/GHPC_Step2.v \
    $GHPC/rtl/Verilog/AGEMA_FPGA/GHPC_Step1_LUT3.v \
    $GHPC/rtl/Verilog/AGEMA_FPGA/GHPC_Gadget_LUT3.v \
    $GHPC/rtl/Verilog/AGEMA_FPGA/LUT3_GHPC.v \
    $REPO/AGEMA_chi/rtl/chi_xilinx_netlist_GHPC__d1.v \
]

synth_design -top chi_GHPC__d1 \
             -part xc7k70tfbv676-1 \
             -mode out_of_context \
             -flatten_hierarchy none

set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports clk]
create_clock -name clk -period 10 [get_ports clk]
set_input_delay -min 1.0 -clock clk [get_ports Fresh*]
set_input_delay -max 1.0 -clock clk [get_ports Fresh*]
set_input_delay -min 1.0 -clock clk [get_ports state_in1_s0*]
set_input_delay -max 1.0 -clock clk [get_ports state_in1_s0*]
set_input_delay -min 1.0 -clock clk [get_ports state_in1_s1*]
set_input_delay -max 1.0 -clock clk [get_ports state_in1_s1*]
set_output_delay -min 0.0 -clock clk [get_ports state_out1_s0*]
set_output_delay -max 0.0 -clock clk [get_ports state_out1_s0*]
set_output_delay -min 0.0 -clock clk [get_ports state_out1_s1*]
set_output_delay -max 0.0 -clock clk [get_ports state_out1_s1*]

opt_design
place_design
route_design

file mkdir $GHPC/syn/results
file mkdir $GHPC/syn/results/logs

report_timing_summary -file $GHPC/syn/results/timing_GHPC.rpt
report_utilization    -file $GHPC/syn/results/util_GHPC.rpt
i
foreach f [glob -nocomplain *.log *.jou *.pb *.str] {
    file rename -force $f $GHPC/syn/results/logs/$f
}
