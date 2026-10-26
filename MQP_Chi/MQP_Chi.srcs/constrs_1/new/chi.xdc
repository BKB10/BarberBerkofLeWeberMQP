create_clock -period 10.000 -name clk [get_ports clk]

# In chi.xdc - must have -min AND -max
set_input_delay -min 1.0 -clock clk [get_ports {Fresh[*]}]
set_input_delay -max 1.0 -clock clk [get_ports {Fresh[*]}]
set_input_delay -min 1.0 -clock clk [get_ports {state_in1_s0[*] state_in1_s1[*]}]
set_input_delay -max 1.0 -clock clk [get_ports {state_in1_s0[*] state_in1_s1[*]}]
set_output_delay -min 0.0 -clock clk [get_ports {state_out1_s0[*] state_out1_s1[*]}]
set_output_delay -max 0.0 -clock clk [get_ports {state_out1_s0[*] state_out1_s1[*]}]
