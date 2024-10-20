module mux8a2 (input logic [1:0] s, r, o, a, t, output logic [1:0] y);
	
	logic [3:0] midresult;
	
	
	mux2a1 mux1(s[1], o[1], t[1], midresult[3]);
	mux2a1 mux2(r[1], a[1], t[1], midresult[2]);
	mux2a1 mux3(s[0], o[0], t[1], midresult[1]);
	mux2a1 mux4(r[0], a[0], t[1], midresult[0]);
	
	mux2a1 mux5(midresult[3], midresult[2], t[0], y[1]);
	mux2a1 mux6(midresult[1], midresult[0], t[0], y[0]);
	
endmodule