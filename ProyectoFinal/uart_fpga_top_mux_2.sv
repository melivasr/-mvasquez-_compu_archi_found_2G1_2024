module uart_fpga_top_mux_2 (
    input  logic        sel,    // Selection signal
    input  logic        in0,    // Input when sel is 0 (0)
    input  logic        in1,    // Input when sel is 1 (1)
    output logic        out     // Output (tx_start_next)
);
    assign out = (sel & in1) | (~sel & in0);
endmodule