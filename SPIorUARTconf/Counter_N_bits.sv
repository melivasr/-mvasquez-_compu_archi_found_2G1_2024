module Counter_N_bits #(parameter N = 26, parameter MAX_COUNT = 49_999_999)(
    input logic clk,
    input logic reset,
    input logic enable,
    output logic [N-1:0] count_q,
    output logic [N-1:0] count_d,
    output logic terminal_count
);
    // Flip-flops D para el registro del contador
    D_FF_Manual #(.N(N)) contador_reg (
        .clk(clk),
        .reset(reset),
        .d(count_d),
        .q(count_q)
    );

    // Comparador para terminal_count
    Comparator_N_bits #(.N(N)) terminal_count_comparator (
        .a(count_q),
        .b(MAX_COUNT[N-1:0]),
        .equal(terminal_count)
    );

    // Sumador para incrementar el contador
    logic [N-1:0] incremented_count;
    Adder_N_bits #(.N(N)) incrementer (
        .a(count_q),
        .b({{N-1{1'b0}}, 1'b1}), // Sumar 1
        .sum(incremented_count),
        .carry_out()
    );

    // Multiplexor para seleccionar entre count_q y incremented_count
    logic [N-1:0] enable_mux_out;
    Mux2to1_N_bits #(.N(N)) enable_mux (
        .in0(count_q),
        .in1(incremented_count),
        .sel(enable),
        .out(enable_mux_out)
    );

    // Multiplexor para seleccionar entre enable_mux_out y cero
    Mux2to1_N_bits #(.N(N)) terminal_count_mux (
        .in0(enable_mux_out),
        .in1({N{1'b0}}),
        .sel(terminal_count),
        .out(count_d)
    );
endmodule