// uart_tx.sv
module uart_tx
  #(parameter int CLKS_PER_BIT = 5208)
  (
    input  logic                       i_Clock,
    input  logic                       i_Enable,
    input  logic                       i_Tx_DV,
    input  logic [7:0]                 i_Tx_Byte,
    output logic                       o_Tx_Active,
    output logic                       o_Tx_Serial,
    output logic                       o_Tx_Done
  );
  import uart_tx_pkg::*;

  // Señales de estado como tipos enumerados
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
    .current_state(current_state),  // Utiliza current_state como tipo enumerado
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

  // Instanciar Mux para seleccionar entre next_state y s_IDLE basado en i_Enable
  uart_tx_pkg::state_t mux_current_state;
  uart_tx_mux_5 mux_current_state_mux (
    .sel(~i_Enable),
    .a(s_IDLE),
    .b(next_state),
    .y(mux_current_state)
  );

  // Instanciar Flip-Flops para current_state usando D_FF_Manual
  D_FF_Manual #(.N(3)) dff_current_state (
    .clk(i_Clock),
    .reset(~i_Enable),
    .d(mux_current_state),
    .q(current_state)
  );

endmodule
