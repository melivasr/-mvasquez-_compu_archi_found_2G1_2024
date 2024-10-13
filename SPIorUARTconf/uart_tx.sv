// uart_tx.sv
module uart_tx
  #(parameter int CLKS_PER_BIT = 5208)
  (
    input  logic                i_Clock,
    input  logic                i_Enable,
    input  logic                i_Tx_DV,
    input  logic [7:0]          i_Tx_Byte,
    output logic                o_Tx_Active,
    output logic                o_Tx_Serial,
    output logic                o_Tx_Done
  );
  import uart_tx_pkg::*;

  // Señales de estado
  uart_tx_pkg::state_t current_state;
  uart_tx_pkg::state_t next_state;

  // Señales del contador de reloj
  logic [15:0] clock_count;
  logic        clk_count_enable;

  // Señales del índice de bits
  logic [2:0] bit_index;
  logic        bit_index_enable;

  // Instanciar FSM
  uart_tx_fsm #(.CLKS_PER_BIT(CLKS_PER_BIT)) fsm (
    .i_Clock(i_Clock),
    .i_Enable(i_Enable),
    .i_Tx_DV(i_Tx_DV),
    .current_state(current_state),
    .clock_count(clock_count),
    .bit_index(bit_index),
    .next_state(next_state)
  );

  // Instanciar Contador de Reloj
  uart_tx_clk_counter #(.CLKS_PER_BIT(CLKS_PER_BIT)) clk_counter (
    .i_Clock(i_Clock),
    .i_Enable(i_Enable),
    .next_state(next_state),
    .clock_count(clock_count),
    .clk_count_enable(clk_count_enable)
  );

  // Instanciar Índice de Bits
  uart_tx_bit_index #(.CLKS_PER_BIT(CLKS_PER_BIT)) bit_idx (
    .i_Clock(i_Clock),
    .i_Enable(i_Enable),
    .current_state(current_state),  // Cambiado de next_state a current_state
    .clock_count(clock_count),
    .bit_index(bit_index),
    .bit_index_enable(bit_index_enable)
  );

  // Instanciar Muxes
  uart_tx_mux_1 mux1 (
    .current_state(current_state),
    .i_Tx_Byte(i_Tx_Byte),
    .bit_index(bit_index),
    .o_Tx_Serial(o_Tx_Serial)
  );

  uart_tx_mux_2 mux2 (
    .current_state(current_state),
    .o_Tx_Done(o_Tx_Done)
  );

  uart_tx_mux_3 mux3 (
    .current_state(current_state),
    .o_Tx_Active(o_Tx_Active)
  );

  // Registro de Estado
  always_ff @(posedge i_Clock or negedge i_Enable) begin
    if (!i_Enable) begin
      current_state <= s_IDLE;
    end else begin
      current_state <= next_state;
    end
  end

endmodule

