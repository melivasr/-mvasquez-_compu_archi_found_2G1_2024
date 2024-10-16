module uart_rx_fsm #(
  parameter int CLKS_PER_BIT = 5208
)(
  input  logic       i_Clock,
  input  logic       i_Enable,
  input  logic       r_Rx_Data,
  output logic       o_Rx_DV,
  output logic [7:0] r_Rx_Byte
);

  logic [2:0] r_SM_Main;
  logic [15:0] r_Clock_Count;
  logic [2:0] r_Bit_Index;

  wire [2:0] next_state;
  wire [15:0] next_clock_count;
  wire [2:0] next_bit_index;
  wire [7:0] next_rx_byte;
  wire       next_o_Rx_DV;

  // Instantiate the state machine module
  uart_rx_state_machine #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
  ) state_machine_inst (
    .i_Clock(i_Clock),
    .i_Enable(i_Enable),
    .r_Rx_Data(r_Rx_Data),
    .r_SM_Main(r_SM_Main),
    .r_Clock_Count(r_Clock_Count),
    .r_Bit_Index(r_Bit_Index),
    .r_Rx_Byte(r_Rx_Byte),
    .next_r_SM_Main(next_state),
    .next_r_Clock_Count(next_clock_count),
    .next_r_Bit_Index(next_bit_index),
    .next_r_Rx_Byte(next_rx_byte),
    .o_Rx_DV(next_o_Rx_DV)
  );

  // Reset values
  logic [2:0] reset_state = 3'd0;
  logic [15:0] reset_clock_count = 16'd0;
  logic [2:0] reset_bit_index = 3'd0;
  logic [7:0] reset_rx_byte = 8'd0;
  logic reset_rx_dv = 1'b0;

  // Multiplexers for reset logic
  wire [2:0] state_input;
  wire [15:0] clock_count_input;
  wire [2:0] bit_index_input;
  wire [7:0] rx_byte_input;
  wire rx_dv_input;

  uart_rx_mux_8 #(3) state_reset_mux (
    .sel(i_Enable),
    .in0(reset_state),
    .in1(next_state),
    .out(state_input)
  );

  uart_rx_mux_8 #(16) clock_count_reset_mux (
    .sel(i_Enable),
    .in0(reset_clock_count),
    .in1(next_clock_count),
    .out(clock_count_input)
  );

  uart_rx_mux_8 #(3) bit_index_reset_mux (
    .sel(i_Enable),
    .in0(reset_bit_index),
    .in1(next_bit_index),
    .out(bit_index_input)
  );

  uart_rx_mux_8 #(8) rx_byte_reset_mux (
    .sel(i_Enable),
    .in0(reset_rx_byte),
    .in1(next_rx_byte),
    .out(rx_byte_input)
  );

  uart_rx_mux_8 #(1) rx_dv_reset_mux (
    .sel(i_Enable),
    .in0(reset_rx_dv),
    .in1(next_o_Rx_DV),
    .out(rx_dv_input)
  );

  // Flip-flops for sequential logic
  D_FF_Manual #(3) state_ff (
    .clk(i_Clock),
    .reset(1'b0),  // No reset input for D_FF_Manual
    .d(state_input),
    .q(r_SM_Main)
  );

  D_FF_Manual #(16) clock_count_ff (
    .clk(i_Clock),
    .reset(1'b0),
    .d(clock_count_input),
    .q(r_Clock_Count)
  );

  D_FF_Manual #(3) bit_index_ff (
    .clk(i_Clock),
    .reset(1'b0),
    .d(bit_index_input),
    .q(r_Bit_Index)
  );

  D_FF_Manual #(8) rx_byte_ff (
    .clk(i_Clock),
    .reset(1'b0),
    .d(rx_byte_input),
    .q(r_Rx_Byte)
  );

  D_FF_Manual #(1) rx_dv_ff (
    .clk(i_Clock),
    .reset(1'b0),
    .d(rx_dv_input),
    .q(o_Rx_DV)
  );

endmodule