// uart_tx_mux_1.sv
module uart_tx_mux_1
  (
    input  uart_tx_pkg::state_t current_state,
    input  logic [7:0]             i_Tx_Byte,
    input  logic [2:0]             bit_index,
    output logic                   o_Tx_Serial
  );
  import uart_tx_pkg::*;

  always_comb begin
    case (current_state)
      s_IDLE:         o_Tx_Serial = 1'b1;
      s_TX_START_BIT: o_Tx_Serial = 1'b0;
      s_TX_DATA_BITS: o_Tx_Serial = i_Tx_Byte[bit_index];
      s_TX_STOP_BIT:  o_Tx_Serial = 1'b1;
      s_CLEANUP:      o_Tx_Serial = 1'b1;
      default:        o_Tx_Serial = 1'b1;
    endcase
  end
endmodule
