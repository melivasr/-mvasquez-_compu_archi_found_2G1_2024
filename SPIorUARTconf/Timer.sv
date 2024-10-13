module Timer(
    input logic clk,              // Reloj del sistema
    input logic reset,            // Reset
    input logic enable,           // Enable para el contador
    output logic [6:0] seg_unidades, // Salida para el display de unidades
    output logic [6:0] seg_decenas,  // Salida para el display de decenas
    output logic t0               // Salida que se activa cuando el contador llega a 0
);
    // Señales internas
    logic [25:0] contador_1hz_q;
    logic [25:0] contador_1hz_d;
    logic pulso_1hz;
    logic [3:0] unidades_q;
    logic [3:0] unidades_d;
    logic [3:0] decenas_q;
    logic [3:0] decenas_d;
    logic unidades_zero, decenas_zero, zero_detected;

    // Generador de pulso de 1 Hz
    Counter_N_bits #(26, 49_999_999) contador_1hz (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .count_q(contador_1hz_q),
        .count_d(contador_1hz_d),
        .terminal_count(pulso_1hz)
    );

    // Comparadores para detectar cero en unidades y decenas
    Comparator_N_bits #(.N(4)) unidades_zero_comparator (
        .a(unidades_q),
        .b(4'd0),
        .equal(unidades_zero)
    );

    Comparator_N_bits #(.N(4)) decenas_zero_comparator (
        .a(decenas_q),
        .b(4'd0),
        .equal(decenas_zero)
    );

    assign zero_detected = unidades_zero & decenas_zero;

    // Contador de unidades
    BCD_Counter unidades_counter (
        .clk(clk),
        .reset(reset),
        .enable(pulso_1hz & enable),
        .load(zero_detected),
        .load_value(4'd3),
        .count_q(unidades_q),
        .count_d(unidades_d),
        .borrow_out(unidades_borrow)
    );

    // Contador de decenas
    BCD_Counter decenas_counter (
        .clk(clk),
        .reset(reset),
        .enable(pulso_1hz & enable & unidades_borrow),
        .load(zero_detected),
        .load_value(4'd0),
        .count_q(decenas_q),
        .count_d(decenas_d),
        .borrow_out(decenas_borrow)
    );

    // Señal t0 (contador llega a cero)
    assign t0 = zero_detected;

    // Conversión BCD a 7 segmentos
    BCD_to_7Segment bcd_unidades (
        .bcd(unidades_q),
        .seg(seg_unidades)
    );

    BCD_to_7Segment bcd_decenas (
        .bcd(decenas_q),
        .seg(seg_decenas)
    );
endmodule