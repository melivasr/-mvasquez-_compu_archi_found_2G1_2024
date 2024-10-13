// uart_tx_clk_counter.sv
module uart_tx_clk_counter
  #(parameter int CLKS_PER_BIT = 5208)
  (
    input  logic                i_Clock,
    input  logic                i_Enable,
    input  uart_tx_pkg::state_t next_state,
    output logic [15:0]         clock_count,
    output logic                clk_count_enable
  );
  import uart_tx_pkg::*;

  always_ff @(posedge i_Clock or negedge i_Enable) begin
    if (!i_Enable) begin
      clock_count      <= 16'd0;
      clk_count_enable <= 1'b0;
    end else begin
      case (next_state)
        s_IDLE: begin
          clock_count      <= 16'd0;
          clk_count_enable <= 1'b0;
        end
        s_TX_START_BIT, s_TX_DATA_BITS, s_TX_STOP_BIT: begin
          if (clock_count < CLKS_PER_BIT - 1) begin
            clock_count      <= clock_count + 1;
            clk_count_enable <= 1'b0;
          end else begin
            clock_count      <= 16'd0;
            clk_count_enable <= 1'b1;
          end
        end
        s_CLEANUP: begin
          clock_count      <= 16'd0;
          clk_count_enable <= 1'b1;
        end
        default: begin
          clock_count      <= 16'd0;
          clk_count_enable <= 1'b0;
        end
      endcase
    end
  end
endmodule
