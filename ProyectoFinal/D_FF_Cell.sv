module D_FF_Cell(
    input logic clk,
    input logic reset,
    input logic d,
    output logic q
);
    // Implementación del flip-flop D con reset asíncrono
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule