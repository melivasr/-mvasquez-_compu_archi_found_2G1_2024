module muxcarry(input logic c1,c2,s, output logic y);
	
	assign y=s & (c1 | c2);
	
endmodule