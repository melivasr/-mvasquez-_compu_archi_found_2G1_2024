module uart_rx 
  #(parameter int CLKS_PER_BIT = 5208)
  (
   input  logic       i_Clock,
   input  logic       i_Enable,
   input  logic       i_Rx_Serial,
   output logic       o_Rx_DV,     
   output logic [7:0] o_Rx_Byte
   );

  logic r_Rx_Data_R;
  logic r_Rx_Data;
  logic o_Rx_DV_fsm;
  logic [7:0] r_Rx_Byte_fsm;

  uart_rx_sync uart_rx_sync_inst (
    .i_Clock     (i_Clock),
    .i_Rx_Serial (i_Rx_Serial),
    .r_Rx_Data_R (r_Rx_Data_R),
    .r_Rx_Data   (r_Rx_Data)
  );

  uart_rx_fsm #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
  ) uart_rx_fsm_inst (
    .i_Clock   (i_Clock),
    .i_Enable  (i_Enable),
    .r_Rx_Data (r_Rx_Data),
    .o_Rx_DV   (o_Rx_DV_fsm),
    .r_Rx_Byte (r_Rx_Byte_fsm)
  );

  uart_rx_mux_1 uart_rx_mux_1_inst (
    .sel      (o_Rx_DV_fsm),
    .data0    (8'd0),
    .data1    (r_Rx_Byte_fsm),
    .data_out (o_Rx_Byte)
  );

  assign o_Rx_DV = o_Rx_DV_fsm;

endmodule