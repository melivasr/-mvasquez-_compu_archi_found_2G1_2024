module uart_rx_counter(
  input  logic [2:0] r_SM_Main,
  input  logic [15:0] r_Clock_Count,
  input  int CLKS_PER_BIT,
  output logic [15:0] next_count
);

  // Señales intermedias
  logic reset_condition;
  logic [15:0] incremented_count;
  logic [15:0] clks_per_bit_minus_one;

  // Calcular CLKS_PER_BIT - 1
  assign clks_per_bit_minus_one = CLKS_PER_BIT - 1;

  // Condición de reset
  assign reset_condition = (r_SM_Main == 3'b000) | ((r_Clock_Count == clks_per_bit_minus_one) & (r_SM_Main != 3'b000));

  // Incrementar el contador
  Adder_N_bits #(16) increment_adder (
    .a(r_Clock_Count),
    .b(16'd1),
    .sum(incremented_count),
    .carry_out()  // No necesitamos el carry out
  );

  // Multiplexor para seleccionar entre 0 y el contador incrementado
  uart_rx_mux_8 #(16) next_count_mux (
    .sel(reset_condition),
    .in0(incremented_count),
    .in1(16'd0),
    .out(next_count)
  );

endmodule