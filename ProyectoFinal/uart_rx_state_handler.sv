module uart_rx_state_handler(
  input  logic [2:0] r_SM_Main,
  input  logic r_Rx_Data,
  input  logic [15:0] r_Clock_Count,
  input  logic [2:0] r_Bit_Index,
  input  int CLKS_PER_BIT,
  output logic [2:0] next_state
);

  // Señales intermedias para cada condición
  logic half_bit_time;
  logic full_bit_time;
  logic last_data_bit;

  // Cálculo de condiciones
  assign half_bit_time = (r_Clock_Count == (CLKS_PER_BIT-1)/2);
  assign full_bit_time = (r_Clock_Count == CLKS_PER_BIT-1);
  assign last_data_bit = (r_Bit_Index == 3'd7);

  // Lógica para cada estado
  logic [2:0] next_state_000, next_state_001, next_state_010, next_state_011;

  // Estado 000
  uart_rx_mux_6 mux_000 (
    .sel(r_Rx_Data),
    .in0(3'b001),
    .in1(3'b000),
    .out(next_state_000)
  );

  // Estado 001
  uart_rx_mux_6 mux_001 (
    .sel(half_bit_time),
    .in0(3'b001),
    .in1(r_Rx_Data ? 3'b000 : 3'b010),
    .out(next_state_001)
  );

  // Estado 010
  uart_rx_mux_6 mux_010 (
    .sel(full_bit_time & last_data_bit),
    .in0(3'b010),
    .in1(3'b011),
    .out(next_state_010)
  );

  // Estado 011
  uart_rx_mux_6 mux_011 (
    .sel(full_bit_time),
    .in0(3'b011),
    .in1(3'b100),
    .out(next_state_011)
  );

  // Multiplexor final para seleccionar el próximo estado
  uart_rx_mux_7 mux_final (
    .sel(r_SM_Main),
    .in0(next_state_000),
    .in1(next_state_001),
    .in2(next_state_010),
    .in3(next_state_011),
    .in4(3'b000),
    .out(next_state)
  );

endmodule