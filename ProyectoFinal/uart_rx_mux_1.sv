module uart_rx_mux_1 (
  input  logic       sel,
  input  logic [7:0] data0,
  input  logic [7:0] data1,
  output logic [7:0] data_out
);

    // Implementación estructural del multiplexor de 2 a 1 para cada bit
    assign uart_rx_mux_2 = (~sel) & data0[0] | sel & data1[0];
    assign data_out[0]    = uart_rx_mux_2;

    assign uart_rx_mux_3 = (~sel) & data0[1] | sel & data1[1];
    assign data_out[1]    = uart_rx_mux_3;

    assign uart_rx_mux_4 = (~sel) & data0[2] | sel & data1[2];
    assign data_out[2]    = uart_rx_mux_4;

    assign uart_rx_mux_5 = (~sel) & data0[3] | sel & data1[3];
    assign data_out[3]    = uart_rx_mux_5;

    assign uart_rx_mux_6 = (~sel) & data0[4] | sel & data1[4];
    assign data_out[4]    = uart_rx_mux_6;

    assign uart_rx_mux_7 = (~sel) & data0[5] | sel & data1[5];
    assign data_out[5]    = uart_rx_mux_7;

    assign uart_rx_mux_8 = (~sel) & data0[6] | sel & data1[6];
    assign data_out[6]    = uart_rx_mux_8;

    assign uart_rx_mux_9 = (~sel) & data0[7] | sel & data1[7];
    assign data_out[7]    = uart_rx_mux_9;

endmodule