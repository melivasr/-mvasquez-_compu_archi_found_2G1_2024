// uart_tx_fsm.sv
module uart_tx_fsm
  #(parameter int CLKS_PER_BIT = 5208)
  (
    input  logic                   i_Clock,
    input  logic                   i_Enable,
    input  logic                   i_Tx_DV,
    input  uart_tx_pkg::state_t    current_state,
    input  logic [15:0]            clock_count,
    input  logic [2:0]             bit_index,
    output uart_tx_pkg::state_t    next_state
  );
  import uart_tx_pkg::*;

  always_comb begin
    case (current_state)
      s_IDLE: begin
        if (i_Tx_DV)
          next_state = s_TX_START_BIT;
        else
          next_state = s_IDLE;
      end

      s_TX_START_BIT: begin
        if (clock_count < CLKS_PER_BIT - 1)
          next_state = s_TX_START_BIT;
        else
          next_state = s_TX_DATA_BITS;
      end

      s_TX_DATA_BITS: begin
        if (clock_count < CLKS_PER_BIT - 1)
          next_state = s_TX_DATA_BITS;
        else if (bit_index < 7)
          next_state = s_TX_DATA_BITS;
        else
          next_state = s_TX_STOP_BIT;
      end

      s_TX_STOP_BIT: begin
        if (clock_count < CLKS_PER_BIT - 1)
          next_state = s_TX_STOP_BIT;
        else
          next_state = s_CLEANUP;
      end

      s_CLEANUP: begin
        next_state = s_IDLE;
      end

      default: begin
        next_state = s_IDLE;
      end
    endcase
  end
endmodule
