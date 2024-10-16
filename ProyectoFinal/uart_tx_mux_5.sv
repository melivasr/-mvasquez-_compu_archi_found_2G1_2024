// uart_tx_mux_5.sv
module uart_tx_mux_5 (
    input  logic                       sel,
    input  uart_tx_pkg::state_t        a,
    input  uart_tx_pkg::state_t        b,
    output uart_tx_pkg::state_t        y
);
    // 3-bit 2:1 Multiplexer utilizando uart_tx_mux_4
    uart_tx_mux_4 #(.N(3)) mux_inst (
        .sel(sel),
        .a(a),
        .b(b),
        .y(y)
    );
endmodule
