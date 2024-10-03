module ALU(input [1:0] a,b, s, output [1:0] y, output logic c);
	
	logic [1:0] res_suma, res_resta, res_or, res_and;
	logic carrysuma, carryresta;
	
	andOP and_inst(a, b, res_and);
	orOP or_inst(a, b, res_or);
	fulladder2Bits fulladder_inst(a, b, res_suma, carrysuma);
	subtractor2Bits subtractor_inst(a, b, res_resta, carryresta);
	
	mux8a2 mux_inst(res_and, res_or, res_suma, res_resta, s, y);
	
	muxcarry muxcarry_inst(carrysuma, carryresta, s[0], c);
	//and,suma,or,resta
	
endmodule