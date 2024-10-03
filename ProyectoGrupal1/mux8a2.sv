module mux8a2 (input logic [1:0] o, a, f, r, s, output logic [1:0] y);
	
	logic [3:0] midresult;
	
	
	mux2a1 mux1(o[1], a[1], s[1], midresult[3]);
	mux2a1 mux2(f[1], r[1], s[1], midresult[2]);
	mux2a1 mux3(o[0], a[0], s[1], midresult[1]);
	mux2a1 mux4(f[0], r[0], s[1], midresult[0]);
	
	mux2a1 mux5(midresult[3], midresult[2], s[0], y[1]);
	mux2a1 mux6(midresult[1], midresult[0], s[0], y[0]);
	
endmodule