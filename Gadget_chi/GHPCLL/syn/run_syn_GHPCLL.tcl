# run_synth_GHPCLL.tcl
# Baseline synthesis for chi_xilinx_netlist_GHPCLL__d1.v
# using Verilog LUT3_GHPC gadget files.

set HOME_DIR $env(HOME)
set REPO     $HOME_DIR/BarberBerkofLeWeberMQP
set GHPCLL   $REPO/Gadget_chi/GHPCLL

create_project -in_memory -part xc7k70tfbv676-1

read_verilog [list \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_reg.v \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_Step2.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/GHPC_Step1_LUT3.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/GHPC_Gadget_LUT3.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/LUT3_GHPC.v \
    $REPO/AGEMA_chi/rtl/chi_xilinx_netlist_GHPCLL__d1.v \
]

synth_design -top chi_GHPCLL__d1 \
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

file mkdir $GHPCLL/syn/results
file mkdir $GHPCLL/syn/results/logs

report_timing_summary -file $GHPCLL/syn/results/timing_GHPCLL.rpt
report_utilization    -file $GHPCLL/syn/results/util_GHPCLL.rpt

foreach f [glob -nocomplain *.log *.jou *.pb *.str] {
    file rename -force $f $GHPCLL/syn/results/logs/$f
}
