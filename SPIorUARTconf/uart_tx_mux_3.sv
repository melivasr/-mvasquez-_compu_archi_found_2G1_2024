// uart_tx_mux_3.sv
module uart_tx_mux_3
  (
    input  uart_tx_pkg::state_t current_state,
    output logic                   o_Tx_Active
  );
  import uart_tx_pkg::*;

  always_comb begin
    case (current_state)
      s_IDLE: begin
        o_Tx_Active = 1'b0;
      end
      s_TX_START_BIT,
      s_TX_DATA_BITS,
      s_TX_STOP_BIT: begin
        o_Tx_Active = 1'b1;
      end
      s_CLEANUP: begin
        o_Tx_Active = 1'b0;
      end
      default: begin
        o_Tx_Active = 1'b0;
      end
    endcase
  end
endmodule
