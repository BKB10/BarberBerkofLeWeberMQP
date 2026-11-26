# run_tb_chi_GHPC.tcl
# Simulation: validates chi_xilinx_netlist_GHPC__d1.v against chi.v

set HOME_DIR $env(HOME)
set REPO     $HOME_DIR/BarberBerkofLeWeberMQP
set GHPC     $REPO/Gadget_chi/GHPC
set RTL      $REPO/AGEMA_chi/rtl

file mkdir $REPO/results/tb_chi_GHPC/sim
file mkdir $REPO/results/tb_chi_GHPC/logs

exec xvlog -sv \
    $GHPC/rtl/Verilog/AGEMA/GHPC_reg.v \
    $GHPC/rtl/Verilog/AGEMA/GHPC_AND_reg.v \
    $GHPC/rtl/Verilog/AGEMA/GHPC_Step2.v \
    $GHPC/rtl/Verilog/AGEMA_FPGA/GHPC_Step1_LUT3.v \
    $GHPC/rtl/Verilog/AGEMA_FPGA/GHPC_Gadget_LUT3.v \
    $GHPC/rtl/Verilog/AGEMA_FPGA/LUT3_GHPC.v \
    $RTL/GHPC/chi_xilinx_netlist_GHPC__d1.v \
    $RTL/chi.v \
    $REPO/AGEMA_chi/tb/GHPC/tb_chi_GHPC.v

exec xelab -top tb_chi_GHPC \
           -snapshot tb_chi_GHPC_snap \
           -L work

set xsim_tcl $REPO/AGEMA_chi/tb/GHPC/results/xsim_cmd.tcl
set f [open $xsim_tcl w]
puts $f "run all"
puts $f "quit"
close $f

set sim_out [exec xsim tb_chi_GHPC_snap \
                  -tclbatch $xsim_tcl \
                  -log $REPO/AGEMA_chi/tb/GHPC/results/sim/sim_chi_GHPC.log]
puts $sim_out

foreach f [glob -nocomplain *.log *.jou *.pb *.str] {
    file rename -force $f $REPO/AGEMA_chi/tb/GHPC/results/logs/$f
}
