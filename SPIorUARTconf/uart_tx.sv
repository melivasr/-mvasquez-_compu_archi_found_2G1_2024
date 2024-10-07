module uart_tx 
  #(parameter int CLKS_PER_BIT = 5208)  // Parámetro de tasa de baudios (ajustable)
  (
    input  logic       i_Clock,
    input  logic       i_Tx_DV,          // Señal para iniciar la transmisión
    output logic       o_Tx_Active,      // Salida activa durante la transmisión
	 input  logic [7:0]  i_Tx_Byte,
    output logic       o_Tx_Serial = 1'b1,  // Inicializar a 1
    output logic       o_Tx_Done   = 1'b0   // Indicar que la transmisión ha finalizado
   );
   
   typedef enum logic [2:0] {
     s_IDLE         = 3'b000, 
     s_TX_START_BIT = 3'b001, 
     s_TX_DATA_BITS = 3'b010, 
     s_TX_STOP_BIT  = 3'b011, 
     s_CLEANUP      = 3'b100
   } state_t;

   state_t r_SM_Main = s_IDLE;

   logic [15:0] r_Clock_Count = 16'd0;     // Contador para medir CLKS_PER_BIT
   logic [2:0]  r_Bit_Index   = 3'd0;      // Índice de bit (0-5)
   logic        r_Tx_Done     = 1'b0;      // Indicar que la transmisión ha finalizado
   logic        r_Tx_Active   = 1'b0;      // Indicar que la transmisión está activa

   // Máquina de estados para la transmisión UART
   always_ff @(posedge i_Clock) begin
     case (r_SM_Main)
       // Estado IDLE: Espera a que se active la señal i_Tx_DV
       s_IDLE: begin
         o_Tx_Serial   <= 1'b1;  // Línea en HIGH para IDLE
         o_Tx_Done     <= 1'b0;
         r_Clock_Count <= 16'd0;
         r_Bit_Index   <= 3'd0;

         if (i_Tx_DV == 1'b1) begin
           o_Tx_Active <= 1'b1;
           r_SM_Main   <= s_TX_START_BIT;  // Pasar al estado de start bit
         end else begin
           r_SM_Main <= s_IDLE;
         end
       end

       // Estado TX_START_BIT: Enviar el start bit (0)
       s_TX_START_BIT: begin
         o_Tx_Serial <= 1'b0;  // Start bit en LOW

         if (r_Clock_Count < CLKS_PER_BIT-1) begin
           r_Clock_Count <= r_Clock_Count + 1;  // Incrementar el contador
           r_SM_Main     <= s_TX_START_BIT;
         end else begin
           r_Clock_Count <= 16'd0;
           r_SM_Main     <= s_TX_DATA_BITS;  // Pasar al estado de envío de datos
         end
       end

       // Estado TX_DATA_BITS: Enviar los 6 bits de datos (LSB primero)
       s_TX_DATA_BITS: begin
         o_Tx_Serial <= i_Tx_Byte[r_Bit_Index];  // Enviar el bit correspondiente (LSB primero)

         if (r_Clock_Count < CLKS_PER_BIT-1) begin
           r_Clock_Count <= r_Clock_Count + 1;
           r_SM_Main     <= s_TX_DATA_BITS;
         end else begin
           r_Clock_Count <= 16'd0;

           // Verificar si se han enviado los 6 bits
           if (r_Bit_Index < 7) begin
             r_Bit_Index <= r_Bit_Index + 1;  // Incrementar el índice para el siguiente bit
             r_SM_Main   <= s_TX_DATA_BITS;
           end else begin
             r_Bit_Index <= 3'd0;
             r_SM_Main   <= s_TX_STOP_BIT;  // Pasar al estado de stop bit
           end
         end
       end

       // Estado TX_STOP_BIT: Enviar el stop bit (1)
       s_TX_STOP_BIT: begin
         o_Tx_Serial <= 1'b1;  // El stop bit es HIGH

         if (r_Clock_Count < CLKS_PER_BIT-1) begin
           r_Clock_Count <= r_Clock_Count + 1;  // Incrementar el contador
           r_SM_Main     <= s_TX_STOP_BIT;
         end else begin
           o_Tx_Done     <= 1'b1;  // Indicar que la transmisión ha finalizado
           r_Clock_Count <= 16'd0;
           r_SM_Main     <= s_CLEANUP;
           o_Tx_Active   <= 1'b0;  // Finalizar la transmisión
         end
       end

       // Estado CLEANUP: Volver al estado IDLE
       s_CLEANUP: begin
         o_Tx_Done <= 1'b1;
         r_SM_Main <= s_IDLE;
       end

       // Estado por defecto
       default: begin
         r_SM_Main <= s_IDLE;
       end
     endcase
   end

endmodule