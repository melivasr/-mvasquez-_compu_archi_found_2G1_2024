module Comparator_N_bits #(parameter N = 4)(
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    output logic equal
);
    // Implementación estructural del comparador de igualdad
    logic [N-1:0] xnor_result;
    assign xnor_result = ~(a ^ b);  // XNOR bit a bit
    assign equal = &xnor_result;    // AND de todos los bits
endmodule
