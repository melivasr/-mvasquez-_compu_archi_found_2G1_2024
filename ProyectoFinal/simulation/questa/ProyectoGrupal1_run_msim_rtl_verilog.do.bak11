transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1 {C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1/fulladderOP.sv}
vlog -sv -work work +incdir+C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1 {C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1/mux2a1.sv}
vlog -sv -work work +incdir+C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1 {C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1/PWM_Generator.sv}
vlog -sv -work work +incdir+C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1 {C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1/register.sv}
vlog -sv -work work +incdir+C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1 {C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1/lessthan.sv}

vlog -sv -work work +incdir+C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1 {C:/FUNDA/-mvasquez-_compu_archi_found_2G1_2024/ProyectoGrupal1/PWM_Generator_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  PWM_Generator_tb

add wave *
view structure
view signals
run -all
