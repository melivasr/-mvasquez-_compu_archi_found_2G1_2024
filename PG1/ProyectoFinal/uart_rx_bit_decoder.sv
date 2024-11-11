module uart_rx_bit_decoder(
  input  logic [2:0] index,
  output logic [7:0] mask
);
  logic [7:0] mask_0, mask_1, mask_2, mask_3, mask_4, mask_5, mask_6, mask_7;
  
  // Definir las máscaras posibles
  assign mask_0 = 8'b00000001;
  assign mask_1 = 8'b00000010;
  assign mask_2 = 8'b00000100;
  assign mask_3 = 8'b00001000;
  assign mask_4 = 8'b00010000;
  assign mask_5 = 8'b00100000;
  assign mask_6 = 8'b01000000;
  assign mask_7 = 8'b10000000;

  // Usar multiplexores para seleccionar la máscara correcta
  uart_rx_mux_9 #(8) mask_selector (
    .sel(index),
    .in0(mask_0),
    .in1(mask_1),
    .in2(mask_2),
    .in3(mask_3),
    .in4(mask_4),
    .in5(mask_5),
    .in6(mask_6),
    .in7(mask_7),
    .out(mask)
  );
endmodule