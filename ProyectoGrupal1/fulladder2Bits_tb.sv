module fulladder2Bits_tb();
	
	logic [1:0] a, b, s, y;
	logic c;
	
	
	ALU dut(a, b, s, y,c);
	
	initial begin
	
	a=11;
	b=10;
	s=00;
	#40
	
	a=11;
	b=10;
	s=01;
	#40
	
	a=11;
	b=10;
	s=10;
	#40
	
	a=11;
	b=10;
	s=11;
	#40
	
	a=11;
	b=10;
	s=11;
	
	
	
	
	end
	
endmodule
