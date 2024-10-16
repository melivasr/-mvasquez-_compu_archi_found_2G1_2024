module BCD_Counter(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic load,
    input logic [3:0] load_value,
    output logic [3:0] count_q,
    output logic [3:0] count_d,
    output logic borrow_out
);
    // Flip-flops D para el registro del contador
    D_FF_Manual #(.N(4)) contador_reg (
        .clk(clk),
        .reset(reset),
        .d(count_d),
        .q(count_q)
    );

    // Comparador para borrow_out
    Comparator_N_bits #(.N(4)) borrow_comparator (
        .a(count_q),
        .b(4'd0),
        .equal(borrow_out)
    );

    // Sumador para decrementar el contador
    logic [3:0] decremented_count;
    Adder_N_bits #(.N(4)) decrementer (
        .a(count_q),
        .b(4'b1111), // -1 en complemento a 2
        .sum(decremented_count),
        .carry_out()
    );

    // Multiplexor para seleccionar entre decremented_count y 9
    logic [3:0] next_count;
    Mux2to1_N_bits #(.N(4)) borrow_mux (
        .in0(decremented_count),
        .in1(4'd9),
        .sel(borrow_out),
        .out(next_count)
    );

    // Multiplexor para seleccionar entre count_q y next_count
    logic [3:0] enable_mux_out;
    Mux2to1_N_bits #(.N(4)) enable_mux (
        .in0(count_q),
        .in1(next_count),
        .sel(enable),
        .out(enable_mux_out)
    );

    // Multiplexor para seleccionar entre enable_mux_out y load_value
    Mux2to1_N_bits #(.N(4)) load_mux (
        .in0(enable_mux_out),
        .in1(load_value),
        .sel(load),
        .out(count_d)
    );
endmodule