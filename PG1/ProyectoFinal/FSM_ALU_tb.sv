module FSM_ALU_tb;
    reg clk;
    reg reset;
    reg handshaking;
    reg confirm_op;
    reg [1:0] switch_op;
    reg [1:0] operand_a;
    reg [1:0] operand_b;
    wire [1:0] alu_result;

    // Instanciación del módulo FSM_ALU
    FSM_ALU uut (
        .clk(clk),
        .reset(reset),
        .handshaking(handshaking),
        .confirm_op(confirm_op),
        .switch_op(switch_op),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_result(alu_result)
    );

    // Generación del reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Periodo de 10 unidades de tiempo
    end

    // Generación de estímulos
    initial begin
        // Inicialización de señales
        reset = 1;
        handshaking = 1;
        confirm_op = 0;
        operand_a = 2'b00;
        operand_b = 2'b00;

        // Liberar reset
        #10;
        reset = 0;

        // Esperar a que el sistema se estabilice
        #10;

        // Prueba 1: Suma (switch_op = 00)
        operand_a = 2'b11;
        operand_b = 2'b11;
        switch_op = 2'b00; // Operación de suma
        realizar_operacion();

        // Verificar resultado de la suma
        if (alu_result == 2'b10)
            $display("Test Suma PASSED: %b + %b = %b", operand_a, operand_b, alu_result);
        else
            $display("Test Suma FAILED: %b + %b = %b", operand_a, operand_b, alu_result);

        // Prueba 2: Resta (switch_op = 01)
        operand_a = 2'b11;
        operand_b = 2'b01;
        switch_op = 2'b01; // Operación de resta
        realizar_operacion();

        // Verificar resultado de la resta
        if (alu_result == 2'b10)
            $display("Test Resta PASSED: %b - %b = %b", operand_a, operand_b, alu_result);
        else
            $display("Test Resta FAILED: %b - %b = %b", operand_a, operand_b, alu_result);

        // Prueba 3: OR (switch_op = 10)
        operand_a = 2'b01;
        operand_b = 2'b10;
        switch_op = 2'b10; // Operación OR
        realizar_operacion();

        // Verificar resultado del OR
        if (alu_result == 2'b11)
            $display("Test OR PASSED: %b | %b = %b", operand_a, operand_b, alu_result);
        else
            $display("Test OR FAILED: %b | %b = %b", operand_a, operand_b, alu_result);

        // Prueba 4: AND (switch_op = 11)
        operand_a = 2'b11;
        operand_b = 2'b10;
        switch_op = 2'b11; // Operación AND
        realizar_operacion();

        // Verificar resultado del AND
        if (alu_result == 2'b10)
            $display("Test AND PASSED: %b & %b = %b", operand_a, operand_b, alu_result);
        else
            $display("Test AND FAILED: %b & %b = %b", operand_a, operand_b, alu_result);

        // Finalizar simulación
        $stop;
    end

    // Tarea para realizar la operación
    task realizar_operacion();
        begin
        

            // Activar confirm_op para pasar a EXECUTE
            #10; // Esperar un ciclo de reloj
            confirm_op = 1;
            #10; // Mantener confirm_op activo durante un ciclo
            confirm_op = 0;

            // Esperar para que el resultado se estabilice
            #10;
        end
    endtask

endmodule
