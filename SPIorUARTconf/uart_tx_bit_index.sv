// uart_tx_bit_index.sv
module uart_tx_bit_index
  #(parameter int CLKS_PER_BIT = 5208)  // Añadido el parámetro CLKS_PER_BIT
  (
    input  logic                i_Clock,
    input  logic                i_Enable,
    input  uart_tx_pkg::state_t current_state,  // Cambiado de next_state a current_state
    input  logic [15:0]         clock_count,
    output logic [2:0]          bit_index,
    output logic                bit_index_enable
  );
  import uart_tx_pkg::*;

  always_ff @(posedge i_Clock or negedge i_Enable) begin
    if (!i_Enable) begin
      bit_index        <= 3'd0;
      bit_index_enable <= 1'b0;
    end else begin
      case (current_state)  // Cambiado de next_state a current_state
        s_IDLE: begin
          bit_index        <= 3'd0;
          bit_index_enable <= 1'b0;
        end
        s_TX_DATA_BITS: begin
          if (clock_count == CLKS_PER_BIT - 1) begin
            if (bit_index < 7)
              bit_index        <= bit_index + 1;
            else
              bit_index        <= 3'd0;
            bit_index_enable <= 1'b1;
          end else begin
            bit_index_enable <= 1'b0;
          end
        end
        s_CLEANUP: begin
          bit_index_enable <= 1'b0;
        end
        default: begin
          bit_index_enable <= 1'b0;
        end
      endcase
    end
  end
endmodule
