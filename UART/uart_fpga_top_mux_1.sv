module uart_fpga_top_mux_1 (
    input  logic sel,
    input  logic in0,
    input  logic in1,
    output logic out
);
    assign out = (sel & in1) | (~sel & in0);
endmodule