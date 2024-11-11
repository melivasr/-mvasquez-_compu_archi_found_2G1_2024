module uart_handshake_mux_0 (
    input  logic sel,
    input  logic [2:0] in0,
    input  logic [2:0] in1,
    output logic [2:0] out
);
	 assign out[0] = (sel & in1[0]) | (~sel & in0[0]);
    assign out[1] = (sel & in1[1]) | (~sel & in0[1]);
    assign out[2] = (sel & in1[2]) | (~sel & in0[2]);
endmodule