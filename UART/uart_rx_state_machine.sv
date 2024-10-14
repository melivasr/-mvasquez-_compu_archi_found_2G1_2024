module uart_rx_state_machine #(
  parameter int CLKS_PER_BIT = 5208
)(
  input  logic       i_Clock,
  input  logic       i_Enable,
  input  logic       r_Rx_Data,
  input  logic [2:0] r_SM_Main,
  input  logic [15:0] r_Clock_Count,
  input  logic [2:0]  r_Bit_Index,
  input  logic [7:0]  r_Rx_Byte,
  output logic [2:0]  next_r_SM_Main,
  output logic [15:0] next_r_Clock_Count,
  output logic [2:0]  next_r_Bit_Index,
  output logic [7:0]  next_r_Rx_Byte,
  output logic        o_Rx_DV
);

  // Señales intermedias
  logic [2:0] next_state;
  logic [15:0] next_count;
  logic [2:0] next_index;
  logic [7:0] next_byte;
  logic rx_dv;
  
  logic is_idle, is_start_bit, is_data_bits, is_stop_bit, is_cleanup;
  logic half_bit_time, full_bit_time;
  logic start_bit_valid, stop_bit_valid;
  
  // Decodificador de estados
  assign is_idle = (r_SM_Main == 3'b000);
  assign is_start_bit = (r_SM_Main == 3'b001);
  assign is_data_bits = (r_SM_Main == 3'b010);
  assign is_stop_bit = (r_SM_Main == 3'b011);
  assign is_cleanup = (r_SM_Main == 3'b100);

  // Condiciones de tiempo
  Comparator_N_bits #(16) half_bit_comparator (
    .a(r_Clock_Count),
    .b((CLKS_PER_BIT-1)/2),
    .equal(half_bit_time)
  );

  Comparator_N_bits #(16) full_bit_comparator (
    .a(r_Clock_Count),
    .b(CLKS_PER_BIT-1),
    .equal(full_bit_time)
  );

  // Condiciones específicas
  assign start_bit_valid = half_bit_time & ~r_Rx_Data;
  assign stop_bit_valid = full_bit_time & r_Rx_Data;

  // Instancias de submódulos
  uart_rx_state_handler state_handler(
    .r_SM_Main(r_SM_Main),
    .r_Rx_Data(r_Rx_Data),
    .r_Clock_Count(r_Clock_Count),
    .r_Bit_Index(r_Bit_Index),
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .next_state(next_state)
  );

  uart_rx_counter counter(
    .r_SM_Main(r_SM_Main),
    .r_Clock_Count(r_Clock_Count),
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .next_count(next_count)
  );

  uart_rx_bit_handler bit_handler(
    .r_SM_Main(r_SM_Main),
    .r_Bit_Index(r_Bit_Index),
    .r_Clock_Count(r_Clock_Count),
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .next_index(next_index)
  );

  uart_rx_byte_handler byte_handler(
    .r_SM_Main(r_SM_Main),
    .r_Rx_Data(r_Rx_Data),
    .r_Rx_Byte(r_Rx_Byte),
    .r_Bit_Index(r_Bit_Index),
    .r_Clock_Count(r_Clock_Count),
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .next_byte(next_byte)
  );

  uart_rx_dv_handler dv_handler(
    .r_SM_Main(r_SM_Main),
    .r_Rx_Data(r_Rx_Data),
    .r_Clock_Count(r_Clock_Count),
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .rx_dv(rx_dv)
  );

  // Lógica para next_r_SM_Main
  uart_rx_mux_9 #(3) sm_main_mux (
    .sel(r_SM_Main),
    .in0(next_state),
    .in1(next_state),
    .in2(next_state),
    .in3(next_state),
    .in4(next_state),
    .in5(3'b000),
    .in6(3'b000),
    .in7(3'b000),
    .out(next_r_SM_Main)
  );

  // Lógica para next_r_Clock_Count
  logic [15:0] idle_count, start_bit_count, data_bits_count, stop_bit_count, cleanup_count;
  assign idle_count = 16'd0;
  assign start_bit_count = start_bit_valid ? 16'd0 : next_count;
  assign data_bits_count = full_bit_time ? 16'd0 : next_count;
  assign stop_bit_count = full_bit_time ? 16'd0 : next_count;
  assign cleanup_count = next_count;

  uart_rx_mux_9 #(16) clock_count_mux (
    .sel(r_SM_Main),
    .in0(idle_count),
    .in1(start_bit_count),
    .in2(data_bits_count),
    .in3(stop_bit_count),
    .in4(cleanup_count),
    .in5(16'd0),
    .in6(16'd0),
    .in7(16'd0),
    .out(next_r_Clock_Count)
  );

  // Lógica para next_r_Bit_Index
  logic [2:0] idle_index, start_bit_index, data_bits_index, stop_bit_index, cleanup_index;
  assign idle_index = 3'd0;
  assign start_bit_index = r_Bit_Index;
  assign data_bits_index = full_bit_time ? next_index : r_Bit_Index;
  assign stop_bit_index = r_Bit_Index;
  assign cleanup_index = r_Bit_Index;

  uart_rx_mux_9 #(3) bit_index_mux (
    .sel(r_SM_Main),
    .in0(idle_index),
    .in1(start_bit_index),
    .in2(data_bits_index),
    .in3(stop_bit_index),
    .in4(cleanup_index),
    .in5(3'd0),
    .in6(3'd0),
    .in7(3'd0),
    .out(next_r_Bit_Index)
  );

  // Lógica para next_r_Rx_Byte
  logic [7:0] idle_byte, start_bit_byte, data_bits_byte, stop_bit_byte, cleanup_byte;
  assign idle_byte = 8'd0;
  assign start_bit_byte = r_Rx_Byte;
  assign data_bits_byte = full_bit_time ? next_byte : r_Rx_Byte;
  assign stop_bit_byte = r_Rx_Byte;
  assign cleanup_byte = r_Rx_Byte;

  uart_rx_mux_9 #(8) rx_byte_mux (
    .sel(r_SM_Main),
    .in0(idle_byte),
    .in1(start_bit_byte),
    .in2(data_bits_byte),
    .in3(stop_bit_byte),
    .in4(cleanup_byte),
    .in5(8'd0),
    .in6(8'd0),
    .in7(8'd0),
    .out(next_r_Rx_Byte)
  );

  // Lógica para o_Rx_DV
  logic idle_dv, start_bit_dv, data_bits_dv, stop_bit_dv, cleanup_dv;
  assign idle_dv = 1'b0;
  assign start_bit_dv = 1'b0;
  assign data_bits_dv = 1'b0;
  assign stop_bit_dv = stop_bit_valid;
  assign cleanup_dv = 1'b0;

  uart_rx_mux_9 #(1) rx_dv_mux (
    .sel(r_SM_Main),
    .in0(idle_dv),
    .in1(start_bit_dv),
    .in2(data_bits_dv),
    .in3(stop_bit_dv),
    .in4(cleanup_dv),
    .in5(1'b0),
    .in6(1'b0),
    .in7(1'b0),
    .out(o_Rx_DV)
  );

endmodule