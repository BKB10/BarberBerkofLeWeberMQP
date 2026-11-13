create_project -in_memory -part xc7k70tfbv676-1

read_vhdl -vhdl2008 {
    GHPC_Gadget/GHPC_pkg.vhd
    GHPC_Gadget/reg.vhd
    GHPC_Gadget/GHPC_AND_reg.vhd
    GHPC_Gadget/GHPC_Step2.vhd
    AGEMA_chi_GHPC_Gadgets/rtl/GHPC_Step1_LUT3.vhd
    AGEMA_chi_GHPC_Gadgets/rtl/GHPC_Gadget_LUT3.vhd
    AGEMA_chi_GHPC_Gadgets/rtl/LUT3_GHPC.vhd
}

### GHPC ###
synth_design -top LUT3_GHPC \
             -part xc7k70tfbv676-1 \
             -mode out_of_context \
             -flatten_hierarchy none \
             -generic {INIT=180 low_latency=0 pipeline=1}

# Constraint
set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports clk]
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

# Implement
opt_design
place_design
route_design


# RPT
report_timing_summary -file results/LUT3_GHPC/timing_LUT3_GHPC.rpt
report_utilization -file results/LUT3_GHPC/util_LUT3_GHPC.rpt
