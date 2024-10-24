module PG1_FAC_Top (
    input  logic        clock,                     // Reloj del sistema
    input  logic        reset_n,                   // Señal de reset activa en bajo
    input  logic        button,                    // Botón de entrada
    input  logic        i_Rx_Serial,               // Entrada serial para recepción UART
    input  logic [3:0]  entrada_dedos,             // Entrada de 4 bits para el decodificador
    input  logic [1:0]  operation,                 // Selección de la operación de la ALU
    input  logic        confirm_btn,               // Botón para confirmar la operación
    output logic        o_Tx_Serial,               // Salida serial para transmisión UART
    output logic [6:0]  seg_unidades,              // Salida de display de 7 segmentos para unidades
    output logic [6:0]  seg_decenas,               // Salida de display de 7 segmentos para decenas
    output logic [6:0]  seg_handshake,             // Salida de display de 7 segmentos para el handshake
    output logic [6:0]  seg_decodificador_dedos,   // Salida de display de 7 segmentos para la decodificación de entrada
    output logic [6:0]  seg_resultado,             // Salida de display de 7 segmentos para el resultado de la ALU
    output logic        motor_in1,                 // Control del motor (PWM)
    output logic        alu_z,                     // Bandera de zero de la ALU
    output logic        alu_n,                     // Bandera de negativo de la ALU
    output logic        alu_o,                     // Bandera de overflow de la ALU
    output logic        alu_c,                     // Bandera de carry de la ALU
    output logic [1:0]  operands                   // Operandos para la ALU
);

    // Señales internas
    logic [3:0] salida_decodificadaDedos_4bits;    // Señal de salida del decodificador en formato de 4 bits
    logic [7:0] r_data;                            // Datos recibidos desde el UART
    logic handshaking;                             // Señal para indicar el estado de handshake
    logic [1:0] salida_decodificada;               // Salida del decodificador
    logic [1:0] resultado_ALU;                     // Resultado de la ALU en formato de 2 bits
    logic button_sync0, button_sync1, button_prev; // Señales para la sincronización del botón
    logic [3:0] resultado_ALU_4bits;               // Resultado de la ALU convertido a 4 bits

    // Asignación de los primeros dos bits de r_data a operands
    assign operands[0] = r_data[0];
    assign operands[1] = r_data[1];
    
    // Sincronización del botón para evitar rebotes
    D_FF_Manual #(.N(1)) button_sync0_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(confirm_btn),
        .q(button_sync0)
    );

    D_FF_Manual #(.N(1)) button_sync1_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(button_sync0),
        .q(button_sync1)
    );

    D_FF_Manual #(.N(1)) button_prev_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(button_sync1),
        .q(button_prev)
    );

    // Señal para detectar el flanco ascendente del botón (confirm_op)
    assign confirm_op = button_sync1 & ~button_prev;

    // Instancia del módulo Decodificador_Dedos, convierte entrada_dedos a salida_decodificada
    Decodificador_Dedos decodificador (
        .entrada(entrada_dedos),
        .salida(salida_decodificada)
    );

    // Conversión de la salida decodificada de 2 bits a 4 bits para el display
    assign salida_decodificadaDedos_4bits = {2'b00, salida_decodificada};

    // Instancia del módulo BCD_to_7Segment para mostrar el valor decodificado en el display
    BCD_to_7Segment bcd_to_7seg (
        .bcd(salida_decodificadaDedos_4bits),
        .seg(seg_decodificador_dedos)
    );

    // Conversión de resultado de la ALU de 2 bits a 4 bits para el display
    assign resultado_ALU_4bits = {2'b00, resultado_ALU};

    // Instancia del módulo BCD_to_7Segment para mostrar el resultado de la ALU en el display
    BCD_to_7Segment bcd_to_7seg_result (
        .bcd(resultado_ALU_4bits),
        .seg(seg_resultado)
    );

    // Instancia del módulo uart_fpga_top para manejar la comunicación UART
    uart_fpga_top uart_instance (
        .clock(clock),
        .reset_n(reset_n),
        .button(button),
        .i_Rx_Serial(i_Rx_Serial),
        .o_Tx_Serial(o_Tx_Serial),
        .uart_enable(handshaking),
        .leds(r_data),
        .seg_unidades(seg_unidades),
        .seg_decenas(seg_decenas),
        .seg_handshake(seg_handshake)
    );

    // Instancia del módulo FSM_ALU para controlar la operación de la ALU
    FSM_ALU fsm_instance(
        .clk(clock),
        .reset(~reset_n),
        .handshaking(handshaking),
        .confirm_op(confirm_op),
        .switch_op(operation),
        .operand_a(salida_decodificada),
        .operand_b(operands),
        .alu_result(resultado_ALU),
        .z(alu_z),
        .n(alu_n),
        .o(alu_o),
        .c(alu_c)
    );

    // Instancia del módulo PWM_Generator para generar la señal de control del motor
    PWM_Generator pwm_instance(
        .clk(clock),
        .reset(~reset_n),
        .duty_cycle(resultado_ALU),
        .pwm_out(pwm_signal)
    );

    // Asignación de la señal PWM al control del motor
    assign motor_in1 = pwm_signal;

endmodule
