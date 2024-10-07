`timescale 1ns / 1ps

module uart_tx_tb;

  // Parámetros
  localparam CLKS_PER_BIT = 5208;  // Ajusta este parámetro según tu frecuencia de reloj y baud rate

  // Señales
  logic        tb_Clock = 0;
  logic        tb_Tx_DV = 0;
  logic        tb_Tx_Active;
  logic        tb_Tx_Serial;
  logic        tb_Tx_Done;

  // Instancia del DUT (Device Under Test)
  uart_tx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
  ) dut (
    .i_Clock(tb_Clock),
    .i_Tx_DV(tb_Tx_DV),
    .o_Tx_Active(tb_Tx_Active),
    .o_Tx_Serial(tb_Tx_Serial),
    .o_Tx_Done(tb_Tx_Done)
  );

  // Generador de reloj (frecuencia de 96 MHz para este ejemplo)
  always #5.208 tb_Clock = ~tb_Clock;  // Periodo de ~10.416 ns -> 96 MHz

  // Proceso de prueba
  initial begin
    // Inicialización
    tb_Tx_DV = 0;
    #100;  // Esperar 100 ns

    // Iniciar la transmisión
    tb_Tx_DV = 1;
    #10;    // Mantener i_Tx_DV alto por un ciclo de reloj
    tb_Tx_DV = 0;

    // Esperar a que la transmisión termine
    wait(tb_Tx_Done == 1);

    // Esperar un poco más y finalizar la simulación
    #100;
    $finish;
  end

  // Monitorizar las señales
  initial begin
    $dumpfile("uart_tx_tb.vcd");
    $dumpvars(0, uart_tx_tb);
    $monitor("Tiempo: %0t | Tx_Serial: %b | Tx_Active: %b | Tx_Done: %b",
             $time, tb_Tx_Serial, tb_Tx_Active, tb_Tx_Done);
  end

endmodule