module PWM_Generator_tb();

    // Declarar las señales de entrada y salida
    logic clk, rst, pwm_out;
    logic [1:0] duty_cycle;

    // Instanciar el módulo bajo prueba
    PWM_Generator dut (
        .clk(clk),
		  .reset(rst),
        .duty_cycle(duty_cycle),
        .pwm_out(pwm_out)
    );

    // Generar el reloj
    always begin
        clk = 0;
        #5 clk = 1;
        #5 clk = 0;
    end

    // Probar diferentes valores de duty_cycle
    initial begin
        
		  rst=1;
		  #20
		  rst=0;
		  #20
		  
		  duty_cycle = 0;
        #100;
        duty_cycle = 1;
        #100;
        duty_cycle = 2;
        #100;
        duty_cycle = 3;
        #100;
        $finish;
    end
	 

    
endmodule