module lessthan ( input logic [3:0] A,B, output logic OUT);

	logic [2:0] carry_out;
	
	fulladderOP fulladder1(.a(A[0]), .b(~B[0]), .cin(1'h1), .cout(carry_out[0]));
	fulladderOP fulladder2(.a(A[1]), .b(~B[1]), .cin(carry_out[0]), .cout(carry_out[1]));
	fulladderOP fulladder3(.a(A[2]), .b(~B[2]), .cin(carry_out[1]), .cout(carry_out[2]));
	fulladderOP fulladder4(.a(A[3]), .b(~B[3]), .cin(carry_out[2]), .s(OUT));
	
endmodule
	