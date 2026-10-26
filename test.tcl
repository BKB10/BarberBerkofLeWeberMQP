# 1. Read VHDL library - ORDER MATTERS for VHDL dependencies
read_vhdl -vhdl2008 {
    GHPC_Gadget/GHPC_pkg.vhd
    GHPC_Gadget/reg.vhd
    GHPC_Gadget/GHPC_Step2.vhd
    AGEMA_chi_GHPC_Gadgets/rtl/GHPC_Step1_LUT3.vhd
    AGEMA_chi_GHPC_Gadgets/rtl/GHPC_Gadget_LUT3.vhd
    AGEMA_chi_GHPC_Gadgets/rtl/LUT3_GHPC.vhd
}

# 2. Read the AGEMA output netlist (Verilog top)
read_verilog AGEMA_chi/rtl/chi_xilinx_netlist_GHPCLL__d1.v

# 3. Synthesize
synth_design -top chi_GHPCLL__d1 \
             -part xc7k70tfbv676-1 \
             -mode out_of_context \
             -flatten_hierarchy none

	
# 4. Constraints
# set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports clk]
create_clock -name clk -period 10 [get_ports clk]
set_input_delay -min 1.0 -clock clk [get_ports {Fresh[*]}]
set_input_delay -max 1.0 -clock clk [get_ports {Fresh[*]}]
# set_input_delay  0 -clock clk [get_ports {state_in1_s0[*] state_in1_s1[*] Fresh[*]}]
# set_output_delay 0 -clock clk [get_ports {state_out1_s0[*] state_out1_s1[*]}]
#read_xdc /home/hvle/BarberBerkofLeWeberMQP/MQP_Chi/MQP_Chi.srcs/constrs_1/new/chi.xdc

# 5. Implement
opt_design
place_design
route_design

# 6. Reports
report_timing_summary -file results/timing.rpt
report_utilization    -file results/util.rpt
report_design_analysis -file results/area.rpt
