// Módulo Decodificador_Dedos
module Decodificador_Dedos (
    input  logic [3:0] entrada,
    output logic [1:0] salida
);

    // Asignación de nombres a los bits de entrada para mayor claridad
    wire A = entrada[0];
    wire B = entrada[1];
    wire C = entrada[2];
    wire D = entrada[3];

    // Implementación estructural de la lógica de decodificación
    assign salida[0] = (A & B) & ((~C & ~D) | (C & D));
    assign salida[1] = A & B & C;

endmodule