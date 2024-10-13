// uart_tx_mux_4.sv
module uart_tx_mux_4 #(
    parameter int N = 16  // Parameter for number of bits
) (
    input  logic         sel,
    input  logic [N-1:0] a,
    input  logic [N-1:0] b,
    output logic [N-1:0] y
);
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : mux_gen
            assign y[i] = (sel & a[i]) | (~sel & b[i]);
        end
    endgenerate
endmodule