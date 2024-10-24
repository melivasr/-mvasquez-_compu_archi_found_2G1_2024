module uart_fpga_top_mux_3 (
    input  logic        sel,         // Selection signal
    input  logic [7:0]  in0,         // Input when sel is 0 (current tx_data)
    input  logic [7:0]  in1,         // Input when sel is 1 (switches)
    output logic [7:0]  out          // Output (tx_data_next)
);
    assign out[0] = (sel & in1[0]) | (~sel & in0[0]);
    assign out[1] = (sel & in1[1]) | (~sel & in0[1]);
    assign out[2] = (sel & in1[2]) | (~sel & in0[2]);
    assign out[3] = (sel & in1[3]) | (~sel & in0[3]);
    assign out[4] = (sel & in1[4]) | (~sel & in0[4]);
    assign out[5] = (sel & in1[5]) | (~sel & in0[5]);
    assign out[6] = (sel & in1[6]) | (~sel & in0[6]);
    assign out[7] = (sel & in1[7]) | (~sel & in0[7]);
endmodule