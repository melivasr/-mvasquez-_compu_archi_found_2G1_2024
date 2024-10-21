module d_ff (
    input logic clk,
    input logic reset,
    input logic d,
    output logic q
);
    logic q_int;

    // Latch maestro con reset asíncrono
    always @(posedge clk or posedge reset) begin
        if (reset)
            q_int <= 1'b0;
        else
            q_int <= d;
    end

    assign q = q_int;
endmodule
