module PG1_FAC_Top (
    input  logic        clock,
    input  logic        reset_n,
    input  logic        button,
    input  logic [7:0]  switches,
    input  logic        i_Rx_Serial,
    output logic        o_Tx_Serial,
	 input  logic [3:0]  entrada_dedos,
    output logic [7:0]  leds,
    output logic [6:0]  seg_unidades,
    output logic [6:0]  seg_decenas,
    output logic [6:0]  seg_handshake,
	 output logic [6:0]  seg_decodificador_dedos,
	 output logic [6:0]  currentMemori
);
	
	// Señal interna para la salida del decodificador de dedos
    logic [1:0] salida_decodificada;
	 
	 // Nueva señal para la salida del decodificador en formato de 4 bits
    logic [3:0] salida_decodificadaDedos_4bits;
	 
	 // Instancia del módulo Decodificador_Dedos
    Decodificador_Dedos decodificador (
        .entrada(entrada_dedos),
        .salida(salida_decodificada)
    );
	 
	 // Conversión de la salida decodificada de 2 bits a 4 bits
    assign salida_decodificadaDedos_4bits = {2'b00, salida_decodificada};
	 
	 // Asignación de currentMemori como copia de seg_decodificador_dedos
    assign currentMemori = seg_decodificador_dedos;
	 
	 // Instancia del módulo BCD_to_7Segment
    BCD_to_7Segment bcd_to_7seg (
        .bcd(salida_decodificadaDedos_4bits),
        .seg(seg_decodificador_dedos)
    );

    // Instancia única del módulo uart_fpga_top
    uart_fpga_top uart_instance (
        .clock(clock),
        .reset_n(reset_n),
        .button(button),
        .switches(switches),
        .i_Rx_Serial(i_Rx_Serial),
        .o_Tx_Serial(o_Tx_Serial),
        .leds(leds),
        .seg_unidades(seg_unidades),
        .seg_decenas(seg_decenas),
        .seg_handshake(seg_handshake)
    );

endmodule