module fulladder2Bits(input logic [1:0] a , b, output logic [1:0] s, output logic cout);
	
	logic p;
	
	fulladderOP unidades(a[0], b[0], 0, s[0], p);
	
	fulladderOP decenas(a[1], b[1], p, s[1], cout);
	
endmodule
