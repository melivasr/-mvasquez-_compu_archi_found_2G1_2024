module PWM_Generator(
    input  logic clk,
    input  logic reset,
    input  logic [1:0] duty_cycle,
    output logic pwm_out
);

    parameter N = 256; // Período PWM de 256 ciclos de reloj
    localparam COUNTER_WIDTH = $clog2(N);
    logic [COUNTER_WIDTH-1:0] counter;
    logic [COUNTER_WIDTH-1:0] pwm_threshold;
    logic [COUNTER_WIDTH-1:0] counter_next;
    logic counter_reset;

    // Instancia del contador que cuenta de 0 a N-1
    assign counter_reset = (counter == N-1);
    assign counter_next = counter_reset ? {COUNTER_WIDTH{1'b0}} : counter + 1;

    D_FF_Manual #(.N(COUNTER_WIDTH)) counter_ff (
        .clk(clk),
        .reset(reset),
        .d(counter_next),
        .q(counter)
    );

    // Generación del valor de pwm_threshold basado en duty_cycle
    logic [COUNTER_WIDTH-1:0] duty_75, duty_875, duty_99;
    
    assign duty_75  = (N * 75) / 100;
    assign duty_875 = (N * 875) / 1000;
    assign duty_99  = (N * 99) / 100;

    assign pwm_threshold = (duty_cycle == 2'd0) ? 0 :
                           (duty_cycle == 2'd1) ? duty_75 :
                           (duty_cycle == 2'd2) ? duty_875 :
                           duty_99;

    // Generación de la señal PWM
    assign pwm_out = (counter < pwm_threshold) ? 1'b1 : 1'b0;

endmodule