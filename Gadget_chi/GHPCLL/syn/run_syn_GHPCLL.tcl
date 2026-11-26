# run_synth_LUT3_GHPC.tcl
# Baseline synthesis + implementation for LUT3_GHPC gadget (GHPC variant).

set HOME_DIR $env(HOME)
set REPO     $HOME_DIR/BarberBerkofLeWeberMQP
set GHPCLL     $REPO/Gadget_chi/GHPCLL

create_project -in_memory -part xc7k70tfbv676-1

read_verilog [list \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_reg.v \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_AND_reg.v \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_Step2.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/GHPC_Step1_LUT3.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/GHPC_Gadget_LUT3.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/LUT3_GHPC.v \
]

synth_design -top LUT3_GHPC \
             -part xc7k70tfbv676-1 \
             -flatten_hierarchy none \
             -generic {INIT=180 low_latency=1 pipeline=1}

create_clock -name clk -period 10 [get_ports clk]
set_input_delay -min 1.0 -clock clk [get_ports I0*]
set_input_delay -max 1.0 -clock clk [get_ports I0*]
set_input_delay -min 1.0 -clock clk [get_ports I1*]
set_input_delay -max 1.0 -clock clk [get_ports I1*]
set_input_delay -min 1.0 -clock clk [get_ports I2*]
set_input_delay -max 1.0 -clock clk [get_ports I2*]
set_input_delay -min 1.0 -clock clk [get_ports r*]
set_input_delay -max 1.0 -clock clk [get_ports r*]
set_output_delay -min 0.0 -clock clk [get_ports O*]
set_output_delay -max 0.0 -clock clk [get_ports O*]

opt_design
place_design
route_design

file mkdir $GHPCLL/syn/results
file mkdir $GHPCLL/syn/results/logs

report_timing_summary -file $GHPCLL/syn/results/timing_GHPCLL.rpt
report_utilization    -file $GHPCLL/syn/results/util_GHPCLL.rpt

foreach f [glob -nocomplain *.log *.jou *.pb *.str] {
    file rename -force $f $GHPCLL/syn/results/logs/$f
}

