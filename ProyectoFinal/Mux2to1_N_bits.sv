module Mux2to1_N_bits #(parameter N = 4)(
    input logic [N-1:0] in0,
    input logic [N-1:0] in1,
    input logic sel,
    output logic [N-1:0] out
);
    // Implementación estructural del multiplexor
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : MUX_ARRAY
            assign out[i] = (~sel & in0[i]) | (sel & in1[i]);
        end
    endgenerate
endmodule
