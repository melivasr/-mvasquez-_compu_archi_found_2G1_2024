module uart_rx_bit_handler(
  input  logic [2:0] r_SM_Main,
  input  logic [2:0] r_Bit_Index,
  input  logic [15:0] r_Clock_Count,
  input  int CLKS_PER_BIT,
  output logic [2:0] next_index
);
  logic sm_condition;
  logic clock_count_condition;
  logic update_condition;
  logic bit_index_max;
  logic [2:0] incremented_index;
  logic [15:0] clks_per_bit_minus_one;
  logic [2:0] new_index;

  // Calcular CLKS_PER_BIT - 1
  assign clks_per_bit_minus_one = CLKS_PER_BIT - 1;

  // Comparar r_SM_Main con 3'b010
  Comparator_N_bits #(3) sm_comparator (
    .a(r_SM_Main),
    .b(3'b010),
    .equal(sm_condition)
  );

  // Comparar r_Clock_Count con CLKS_PER_BIT-1
  Comparator_N_bits #(16) clock_count_comparator (
    .a(r_Clock_Count),
    .b(clks_per_bit_minus_one),
    .equal(clock_count_condition)
  );

  // Condición de actualización
  assign update_condition = sm_condition & clock_count_condition;

  // Comparar r_Bit_Index con 3'd7
  Comparator_N_bits #(3) bit_index_comparator (
    .a(r_Bit_Index),
    .b(3'd7),
    .equal(bit_index_max)
  );

  // Incrementar r_Bit_Index
  Adder_N_bits #(3) bit_index_incrementer (
    .a(r_Bit_Index),
    .b(3'd1),
    .sum(incremented_index),
    .carry_out()
  );

  // Seleccionar entre 3'd0 e incremented_index
  uart_rx_mux_8 #(3) index_selector (
    .sel(bit_index_max),
    .in0(incremented_index),
    .in1(3'd0),
    .out(new_index)
  );

  // Selección final entre r_Bit_Index y new_index
  uart_rx_mux_8 #(3) final_selector (
    .sel(update_condition),
    .in0(r_Bit_Index),
    .in1(new_index),
    .out(next_index)
  );

endmodule