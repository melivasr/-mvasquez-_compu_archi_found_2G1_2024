// uart_tx_bit_index_structural.sv
module uart_tx_bit_index
  #(parameter int CLKS_PER_BIT = 5208)
  (
    input  logic                i_Clock,          // Clock
    input  logic                i_Enable,         // Enable (active low)
    input  uart_tx_pkg::state_t current_state,    // Current state
    input  logic [15:0]         clock_count,      // Clock counter
    output logic [2:0]          bit_index,        // Bit index
    output logic                bit_index_enable  // Bit index enable
  );
  import uart_tx_pkg::*;

  // State comparison signals
  wire is_IDLE;
  wire is_TX_DATA_BITS;
  wire is_CLEANUP;

  // Instantiate comparators for state detection
  Comparator_N_bits #(.N(3)) cmp_IDLE (
    .a(current_state),
    .b(s_IDLE),
    .equal(is_IDLE)
  );

  Comparator_N_bits #(.N(3)) cmp_TX_DATA_BITS (
    .a(current_state),
    .b(s_TX_DATA_BITS),
    .equal(is_TX_DATA_BITS)
  );

  Comparator_N_bits #(.N(3)) cmp_CLEANUP (
    .a(current_state),
    .b(s_CLEANUP),
    .equal(is_CLEANUP)
  );

  // Comparator for clock_count == CLKS_PER_BIT - 1
  wire [15:0] CLKS_PER_BIT_minus1 = CLKS_PER_BIT - 16'd1;
  wire is_clock_count_eq_CLKS;

  Comparator_N_bits #(.N(16)) cmp_clock_count_eq (
    .a(clock_count),
    .b(CLKS_PER_BIT_minus1),
    .equal(is_clock_count_eq_CLKS)
  );

  // Comparator for bit_index < 7
  wire is_bit_index_lt_7;
  assign is_bit_index_lt_7 = ~(&bit_index); // True if bit_index < 7

  // Adder to compute bit_index + 1
  wire [2:0] bit_index_plus1;
  wire carry_out_add;

  Adder_N_bits #(.N(3)) adder_bit_index (
    .a(bit_index),
    .b(3'd1),
    .sum(bit_index_plus1),
    .carry_out(carry_out_add)
  );

  // Mux1: Select bit_index + 1 or 0 based on is_bit_index_lt_7
  wire [2:0] mux1_out;
  uart_tx_mux_4 #(.N(3)) mux_bit_inc (
    .sel(is_bit_index_lt_7),
    .a(bit_index_plus1),
    .b(3'd0),
    .y(mux1_out)
  );

  // Mux2: Select mux1_out or bit_index based on is_clock_count_eq_CLKS
  wire [2:0] mux2_out;
  uart_tx_mux_4 #(.N(3)) mux_bit_next_mux2 (
    .sel(is_clock_count_eq_CLKS),
    .a(mux1_out),
    .b(bit_index),
    .y(mux2_out)
  );

  // Mux3: Select mux2_out or 0 based on is_TX_DATA_BITS
  wire [2:0] bit_index_next;
  uart_tx_mux_4 #(.N(3)) mux_bit_next_mux3 (
    .sel(is_TX_DATA_BITS),
    .a(mux2_out),
    .b(3'd0),
    .y(bit_index_next)
  );

  // Generate bit_index_enable signal
  wire bit_index_enable_internal;
  assign bit_index_enable_internal = is_TX_DATA_BITS & is_clock_count_eq_CLKS;

  // Mux for bit_index_enable: 1 if bit_index_enable_internal, else 0
  wire bit_index_enable_out;
  uart_tx_mux_4 #(.N(1)) mux_bit_enable (
    .sel(bit_index_enable_internal),
    .a(1'b1),
    .b(1'b0),
    .y(bit_index_enable_out)
  );

  // Asynchronous reset signal
  wire reset = ~i_Enable;

  // Instantiate D flip-flops for bit_index and bit_index_enable
  D_FF_Manual #(.N(3)) dff_bit_index (
    .clk(i_Clock),
    .reset(reset),
    .d(bit_index_next),
    .q(bit_index)
  );

  D_FF_Manual #(.N(1)) dff_bit_index_enable (
    .clk(i_Clock),
    .reset(reset),
    .d(bit_index_enable_out),
    .q(bit_index_enable)
  );

endmodule
