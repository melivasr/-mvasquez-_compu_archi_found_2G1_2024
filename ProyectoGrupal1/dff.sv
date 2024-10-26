module dff(
	input clk, reset,
	output q
);
	logic q_int, d_not, clk_not;
	
	 //Inversores 
	 assign d_not = ~d;
	 assign clk_not = ~clk;
	 
	 //Lógica latch maestro
	 logic s_master, r_master, q_master, q_master_not;
	 nand(s_master, d, clk_not);
	 nand(r_master, d_not, clk_not);
	 nand(q_master, s_master, q_master_not);
	 nand(q_master_not, r_master, q_master);
	 //Lógica esclavo
	 logic s_slave, r_slave;
	 nand (s_slave, q_master, clk);
	 nand (r_slave, q_master_not, clk);
	 nand (q_int, s_slave, q);
	 nand (q, r_slave, q_int);
	 
	 //Reseteo asíncrono
	 assign q = q & ~reset;
	 

endmodule
