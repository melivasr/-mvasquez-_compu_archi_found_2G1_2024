module ALU_testbench();
	
	logic [1:0] a, b, s, y;
	logic c,z,n,o;
	
	
	ALU dut(a, b, s, y, c, z, n,o);
	
	
	
	initial begin
	
	
	a=00;
	b=00;
	s=01;
	#40
	
	a=00;
	b=01;
	s=01;
	#40
	
	a=00;
	b=10;
	s=01;
	#40
	
	a=00;
	b=11;
	s=01;
	#40
	//---------------------------
	a=01;
	b=00;
	s=01;
	#40
	
	a=01;
	b=01;
	s=01;
	#40
	
	a=01;
	b=10;
	s=01;
	#40
	
	a=01;
	b=11;
	s=01;
	#40
	//---------------------------
	a=10;
	b=00;
	s=01;
	#40
	
	a=10;
	b=01;
	s=01;
	#40
	
	a=10;
	b=10;
	s=01;
	#40
	
	a=10;
	b=11;
	s=01;
	#40
	//---------------------------
	a=11;
	b=00;
	s=01;
	#40
	
	a=11;
	b=01;
	s=01;
	#40
	
	a=11;
	b=10;
	s=01;
	#40
	
	a=11;
	b=11;
	s=01;
	#40
	
	a=11;
	b=11;
	s=01;
	
	
	
	
	end
	
endmodule
