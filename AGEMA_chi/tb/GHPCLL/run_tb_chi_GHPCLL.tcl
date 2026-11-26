# run_tb_chi_GHPC.tcl
# Simulation: validates chi_xilinx_netlist_GHPC__d1.v against chi.v

set HOME_DIR $env(HOME)
set REPO     $HOME_DIR/BarberBerkofLeWeberMQP
set GHPCLL   $REPO/Gadget_chi/GHPCLL
set RTL      $REPO/AGEMA_chi/rtl

file mkdir $REPO/AGEMA_chi/tb/GHPCLL/results
file mkdir $REPO/AGEMA_chi/tb/GHPCLL/results/logs
file mkdir $REPO/AGEMA_chi/tb/GHPCLL/results/sim

exec xvlog -sv \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_reg.v \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_AND_reg.v \
    $GHPCLL/rtl/Verilog/AGEMA/GHPC_Step2.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/GHPC_Step1_LUT3.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/GHPC_Gadget_LUT3.v \
    $GHPCLL/rtl/Verilog/AGEMA_FPGA/LUT3_GHPC.v \
    $RTL/GHPCLL/chi_xilinx_netlist_GHPCLL__d1.v \
    $RTL/chi.v \
    $REPO/AGEMA_chi/tb/GHPCLL/tb_chi_GHPCLL.v

exec xelab -top tb_chi_GHPCLL \
           -snapshot tb_chi_GHPCLL_snap \
           -L work

set xsim_tcl $REPO/AGEMA_chi/tb/GHPCLL/results/xsim_cmd.tcl
set f [open $xsim_tcl w]
puts $f "run all"
puts $f "quit"
close $f

set sim_out [exec xsim tb_chi_GHPCLL_snap \
                  -tclbatch $xsim_tcl \
                  -log $REPO/AGEMA_chi/tb/GHPCLL/results/sim/sim_chi_GHPCLL.log]
puts $sim_out

foreach f [glob -nocomplain *.log *.jou *.pb *.str] {
    file rename -force $f $REPO/AGEMA_chi/tb/GHPCLL/results/logs/$f
}
