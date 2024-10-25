transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/cyclonev_ver
vmap cyclonev_ver ./verilog_libs/cyclonev_ver
vlog -vlog01compat -work cyclonev_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/mentor/cyclonev_atoms_ncrypt.v}
vlog -vlog01compat -work cyclonev_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/mentor/cyclonev_hmi_atoms_ncrypt.v}
vlog -vlog01compat -work cyclonev_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/cyclonev_atoms.v}

vlib verilog_libs/cyclonev_hssi_ver
vmap cyclonev_hssi_ver ./verilog_libs/cyclonev_hssi_ver
vlog -vlog01compat -work cyclonev_hssi_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/mentor/cyclonev_hssi_atoms_ncrypt.v}
vlog -vlog01compat -work cyclonev_hssi_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/cyclonev_hssi_atoms.v}

vlib verilog_libs/cyclonev_pcie_hip_ver
vmap cyclonev_pcie_hip_ver ./verilog_libs/cyclonev_pcie_hip_ver
vlog -vlog01compat -work cyclonev_pcie_hip_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/mentor/cyclonev_pcie_hip_atoms_ncrypt.v}
vlog -vlog01compat -work cyclonev_pcie_hip_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/cyclonev_pcie_hip_atoms.v}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_fpga_top.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/BCD_to_7Segment.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_handshake.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/Timer.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/Counter_N_bits.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/BCD_Counter.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/D_FF_Cell.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/D_FF_Manual.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/Comparator_N_bits.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/Adder_N_bits.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/Mux2to1_N_bits.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_tx_pkg.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_tx_mux_4.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_fsm.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_sync.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_mux_1.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_state_machine.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_mux_2.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_state_handler.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_counter.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_bit_handler.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_byte_handler.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_dv_handler.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_mux_6.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_mux_7.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_mux_8.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_bit_decoder.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_mux_9.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_rx_mux_10.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_handshake_mux_0.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_fpga_top_mux_0.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_fpga_top_mux_4.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/PG1_FAC_Top.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/Decodificador_Dedos.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/FSM_ALU.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/PWM_Generator.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/ALU.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/andop.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/orop.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/mux2a1.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/fulladder2bits.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/fulladderop.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/mux8a2.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_tx.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_tx_mux_1.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_tx_mux_2.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_tx_mux_3.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_tx_fsm.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_tx_clk_counter.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_tx_bit_index.sv}
vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/uart_tx_mux_5.sv}

vlog -sv -work work +incdir+C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal {C:/Users/ASUS/source/repos/-mvasquez-_compu_archi_found_2G1_2024/ProyectoFinal/ALU_testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  ALU_testbench

add wave *
view structure
view signals
run -all
