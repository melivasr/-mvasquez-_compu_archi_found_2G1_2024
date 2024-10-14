module uart_rx_byte_handler(
  input  logic [2:0] r_SM_Main,
  input  logic r_Rx_Data,
  input  logic [7:0] r_Rx_Byte,
  input  logic [2:0] r_Bit_Index,
  input  logic [15:0] r_Clock_Count,
  input  int CLKS_PER_BIT,
  output logic [7:0] next_byte
);
  logic sm_main_condition;
  logic clock_count_condition;
  logic update_condition;
  logic [7:0] bit_mask;
  logic [7:0] updated_byte;
  logic [15:0] clks_per_bit_minus_one;

  // Calcular CLKS_PER_BIT - 1
  assign clks_per_bit_minus_one = CLKS_PER_BIT - 1;

  // Comparar r_SM_Main con 3'b010
  Comparator_N_bits #(3) sm_main_comparator (
    .a(r_SM_Main),
    .b(3'b010),
    .equal(sm_main_condition)
  );

  // Comparar r_Clock_Count con CLKS_PER_BIT-1
  Comparator_N_bits #(16) clock_count_comparator (
    .a(r_Clock_Count),
    .b(clks_per_bit_minus_one),
    .equal(clock_count_condition)
  );

  // Condición de actualización
  assign update_condition = sm_main_condition & clock_count_condition;

  // Generar máscara de bit basada en r_Bit_Index
  uart_rx_bit_decoder bit_decoder (
    .index(r_Bit_Index),
    .mask(bit_mask)
  );

  // Actualizar el byte
  assign updated_byte = (r_Rx_Byte & ~bit_mask) | ({8{r_Rx_Data}} & bit_mask);

  // Seleccionar entre r_Rx_Byte y updated_byte
  uart_rx_mux_8 #(8) byte_selector (
    .sel(update_condition),
    .in0(r_Rx_Byte),
    .in1(updated_byte),
    .out(next_byte)
  );
endmodule