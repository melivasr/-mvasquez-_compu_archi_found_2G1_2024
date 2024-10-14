module uart_rx_dv_handler(
  input  logic [2:0] r_SM_Main,
  input  logic r_Rx_Data,
  input  logic [15:0] r_Clock_Count,
  input  int CLKS_PER_BIT,
  output logic rx_dv
);
  logic sm_main_condition;
  logic clock_count_condition;
  logic [15:0] clks_per_bit_minus_one;

  // Calcular CLKS_PER_BIT - 1
  assign clks_per_bit_minus_one = CLKS_PER_BIT - 1;

  // Comparar r_SM_Main con 3'b011
  Comparator_N_bits #(3) sm_main_comparator (
    .a(r_SM_Main),
    .b(3'b011),
    .equal(sm_main_condition)
  );

  // Comparar r_Clock_Count con CLKS_PER_BIT-1
  Comparator_N_bits #(16) clock_count_comparator (
    .a(r_Clock_Count),
    .b(clks_per_bit_minus_one),
    .equal(clock_count_condition)
  );

  // Combinar todas las condiciones
  assign rx_dv = sm_main_condition & clock_count_condition & r_Rx_Data;

endmodule