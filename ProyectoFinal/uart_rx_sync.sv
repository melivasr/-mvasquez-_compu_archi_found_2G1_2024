module uart_rx_sync (
  input  logic i_Clock,
  input  logic i_Rx_Serial,
  output logic r_Rx_Data_R,
  output logic r_Rx_Data
);

    // Implementación estructural de uart_rx_sync reemplazando el bloque always_ff por flip-flops D
    D_FF_Cell dff1 (
        .clk(i_Clock),
        .reset(1'b0),
        .d(i_Rx_Serial),
        .q(r_Rx_Data_R)
    );

    D_FF_Cell dff2 (
        .clk(i_Clock),
        .reset(1'b0),
        .d(r_Rx_Data_R),
        .q(r_Rx_Data)
    );

endmodule