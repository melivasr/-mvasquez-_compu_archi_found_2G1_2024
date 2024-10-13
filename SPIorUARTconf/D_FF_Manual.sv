module D_FF_Manual #(parameter N = 1)(
    input logic clk,
    input logic reset,
    input logic [N-1:0] d,
    output logic [N-1:0] q
);

    // Flip-flops D individuales utilizando el D_FF_Cell estructural
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : DFF_ARRAY
            D_FF_Cell dff_cell (
                .clk(clk),
                .reset(reset),
                .d(d[i]),
                .q(q[i])
            );
        end
    endgenerate

endmodule