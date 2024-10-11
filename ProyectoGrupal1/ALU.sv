module ALU(input [1:0] a,b, s, output [1:0] y, output logic c,z,n,o);
	
	logic [1:0] res_sumaresta, res_or, res_and, new_b;
	logic carry_out;
	
	andOP and_inst(a, b, res_and); //Op AND
	
	orOP or_inst(a, b, res_or); //OP OR
	
	mux2a1 mux2_inst_1(b[1], ~b[1], s[0], new_b[1]); 
	mux2a1 mux2_inst_0(b[0], ~b[0], s[0], new_b[0]); //Multiplexores para el caso de suma o resta
	
	fulladder2Bits fulladder_inst(a, new_b, s[0], res_sumaresta, carry_out); //sumador de 2 bits
	
	mux8a2 mux8_inst(res_sumaresta, res_sumaresta, res_or , res_and, s, y); //Mux para elegir operacion
	//suma 00, resta 01, or 10, and 11
	
	//banderas
	assign o = ~s[1] & (res_sumaresta[1] ^ a[1]) & ~(a[1] ^ b[1] ^ s[0]);
	assign c = carry_out & ~s[1];
	assign z = ~(y[1] | y[0]);
	assign n = y[1];
	
endmodule