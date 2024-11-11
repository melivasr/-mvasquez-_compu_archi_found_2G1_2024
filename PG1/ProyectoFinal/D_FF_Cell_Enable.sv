module D_FF_Cell_Enable (
    input  logic clk,       // Reloj
    input  logic reset,     // Reset
    input  logic enable,    // Habilitación
    input  logic d,         // Entrada de datos
    output logic q          // Salida del flip-flop
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 1'b0;      // Reiniciar el flip-flop a 0
        end else if (enable) begin
            q <= d;         // Actualizar la salida solo si enable está activo
        end
    end
endmodule
