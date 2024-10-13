// uart_tx_mux_2.sv
module uart_tx_mux_2
  (
    input  uart_tx_pkg::state_t current_state,
    output logic                   o_Tx_Done
  );
  import uart_tx_pkg::*;

  always_comb begin
    case (current_state)
      s_CLEANUP: o_Tx_Done = 1'b1;
      default:   o_Tx_Done = 1'b0;
    endcase
  end
endmodule
