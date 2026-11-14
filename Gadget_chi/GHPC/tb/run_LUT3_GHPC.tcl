set HOME_DIR   $env(HOME)
set REPO       $HOME_DIR/BarberBerkofLeWeberMQP
set GHPC_Gadget $REPO/Gadget_chi/GHPC

# create_project -in_memory -part xc7k70tfbv676-1

# exec read_vhdl -vhdl2008 -library vhdl_golden [list \
    $GHPC_Gadget/rtl/VHDL/AGEMA/GHPC_pkg.vhd \
    $GHPC_Gadget/rtl/VHDL/AGEMA/reg.vhd \
    $GHPC_Gadget/rtl/VHDL/AGEMA/GHPC_AND_reg.vhd \
    $GHPC_Gadget/rtl/VHDL/AGEMA/GHPC_Step2.vhd \
    $GHPC_Gadget/rtl/VHDL/AGEMA_FPGA/GHPC_Step1_LUT3.vhd \
    $GHPC_Gadget/rtl/VHDL/AGEMA_FPGA/GHPC_Gadget_LUT3.vhd \
    $GHPC_Gadget/rtl/VHDL/AGEMA_FPGA/LUT3_GHPC.vhd \
]

# exec read_verilog [list \
    $GHPC_Gadget/rtl/Verilog/AGEMA/GHPC_reg.v \
    $GHPC_Gadget/rtl/Verilog/AGEMA/GHPC_AND_reg.v \
    $GHPC_Gadget/rtl/Verilog/AGEMA/GHPC_Step2.v \
    $GHPC_Gadget/rtl/Verilog/AGEMA_FPGA/GHPC_Step1_LUT3.v \
    $GHPC_Gadget/rtl/Verilog/AGEMA_FPGA/GHPC_Gadget_LUT3.v \
    $GHPC_Gadget/rtl/Verilog/AGEMA_FPGA/LUT3_GHPC.v \
    $GHPC_Gadget/tb/tb_LUT3_GHPC.v \
]


exec xvlog -sv $GHPC_Gadget/rtl/Verilog/AGEMA/GHPC_reg.v \
          $GHPC_Gadget/rtl/Verilog/AGEMA/GHPC_AND_reg.v \
          $GHPC_Gadget/rtl/Verilog/AGEMA/GHPC_Step2.v \
          $GHPC_Gadget/rtl/Verilog/AGEMA_FPGA/GHPC_Step1_LUT3.v \
          $GHPC_Gadget/rtl/Verilog/AGEMA_FPGA/GHPC_Gadget_LUT3.v \
          $GHPC_Gadget/rtl/Verilog/AGEMA_FPGA/LUT3_GHPC.v \
          $GHPC_Gadget/tb/tb_LUT3_GHPC.v

exec xvhdl -2008 -work vhdl_golden \
          $GHPC_Gadget/rtl/VHDL/AGEMA/GHPC_pkg.vhd \
          $GHPC_Gadget/rtl/VHDL/AGEMA/reg.vhd \
          $GHPC_Gadget/rtl/VHDL/AGEMA/GHPC_AND_reg.vhd \
          $GHPC_Gadget/rtl/VHDL/AGEMA/GHPC_Step2.vhd \
          $GHPC_Gadget/rtl/VHDL/AGEMA_FPGA/GHPC_Step1_LUT3.vhd \
          $GHPC_Gadget/rtl/VHDL/AGEMA_FPGA/GHPC_Gadget_LUT3.vhd \
          $GHPC_Gadget/rtl/VHDL/AGEMA_FPGA/LUT3_GHPC.vhd

exec xelab -top tb_LUT3_GHPC \
      -snapshot tb_LUT3_GHPC_snap \
      -lib vhdl_golden \
      -L vhdl_golden \
      -L work

exec xsim tb_LUT3_GHPC_snap -runall \
     -log $GHPC_Gadget/tb/results/sim/sim_LUT3_GHPC.log

foreach f [glob -nocomplain *.log *.jou *.pb *.str] {
    file rename -force $f $GHPC_Gadget/tb/results/logs/$f
}
