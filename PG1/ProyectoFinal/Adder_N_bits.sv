module Adder_N_bits #(parameter N = 4)(
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    output logic [N-1:0] sum,
    output logic carry_out
);
    // Implementación estructural del sumador utilizando full adders
    logic [N:0] carry;
    assign carry[0] = 1'b0;  // No hay acarreo de entrada

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : FULL_ADDER_ARRAY
            Full_Adder full_adder_inst (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign carry_out = carry[N];
endmodule

module Full_Adder(
    input logic a,
    input logic b,
    input logic cin,
    output logic sum,
    output logic cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule
