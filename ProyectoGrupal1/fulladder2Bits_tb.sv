module fulladder2Bits_tb();
	
	logic [1:0] a, b, s;
	
	logic cout;
	
	subtractor2Bits dut(a, b, s, cout);
	
	initial begin
	
	a=2'b10;
	b=2'b01;
	#40
	
	a=00;
	b=01;
	
	
	end
	
endmodule
