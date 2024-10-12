// Receptor: Raspberry Pi Pico H con LEDs y botón

// Definición de pines para los LEDs y botón
const int ledBit1Pin = 2;        // GPIO2
const int ledBit0Pin = 3;        // GPIO3
const int botonEnviarPin = 4;    // GPIO4

// Variables para el botón de envío
bool estadoBotonAnterior = HIGH;
bool esperandoLiberacion = false;

// Variable para almacenar el byte recibido
unsigned char byteAlmacenado = 0b00000000;

// Variable para saber si estamos esperando una respuesta del emisor
bool esperandoRespuesta = false;
// Variable para almacenar el byte enviado
unsigned char byteEnviado = 0b00000000;

void setup() {
  // Iniciar la comunicación UART a 9600 baudios
  Serial1.begin(9600);

  // Iniciar la comunicación Serial USB para el monitor serial
  Serial.begin(115200);

  // Esperar a que se inicie el monitor serial (opcional)
  while (!Serial) {
    ; // Esperar a que se conecte el monitor serial
  }

  // Configurar los pines de los LEDs como salidas
  pinMode(ledBit1Pin, OUTPUT);
  pinMode(ledBit0Pin, OUTPUT);

  // Apagar los LEDs al inicio
  digitalWrite(ledBit1Pin, LOW);
  digitalWrite(ledBit0Pin, LOW);

  // Configurar el pin del botón como entrada con resistencia pull-up
  pinMode(botonEnviarPin, INPUT_PULLUP);

  Serial.println("Receptor iniciado. Esperando datos del emisor...");
}

void loop() {
  // Verificar si hay datos disponibles en UART
  if (Serial1.available() > 0) {
    // Leer el byte recibido
    unsigned char recibido = Serial1.read();

    if (esperandoRespuesta) {
      // Comparar el byte recibido con el byte enviado
      if (recibido == byteEnviado) {
        // Comunicación exitosa: encender ambos LEDs brevemente
        Serial.println("Receptor: Comunicación exitosa, bytes coinciden");
      } else {
        Serial.println("Receptor: Error, el byte recibido no coincide con el enviado");
      }
      esperandoRespuesta = false;  // Resetear el estado de espera
    } else {
      // Almacenar el byte recibido
      byteAlmacenado = recibido;

      // Imprimir el byte recibido
      Serial.print("Receptor: Byte recibido y almacenado: ");
      Serial.println(byteAlmacenado, BIN);

      // Actualizar el estado de los LEDs según los bits 0 y 1 del byte almacenado
      if (byteAlmacenado & (1 << 1)) {
        digitalWrite(ledBit1Pin, HIGH);  // Encender LED Bit 1
      } else {
        digitalWrite(ledBit1Pin, LOW);   // Apagar LED Bit 1
      }

      if (byteAlmacenado & (1 << 0)) {
        digitalWrite(ledBit0Pin, HIGH);  // Encender LED Bit 0
      } else {
        digitalWrite(ledBit0Pin, LOW);   // Apagar LED Bit 0
      }
    }
  }

  // Leer el estado actual del botón de envío
  bool estadoBotonActual = digitalRead(botonEnviarPin);

  // Detectar el flanco de bajada (presión del botón)
  if (estadoBotonAnterior == HIGH && estadoBotonActual == LOW) {
    esperandoLiberacion = true;  // Indicar que estamos esperando que se suelte el botón
  }

  // Detectar el flanco de subida (liberación del botón)
  if (esperandoLiberacion && estadoBotonAnterior == LOW && estadoBotonActual == HIGH) {
    // Preparar el byte a enviar (últimos 6 bits en 0, bits 0 y 1 según byte almacenado)
    byteEnviado = byteAlmacenado & 0b00000011;

    // Enviar el byte al emisor con detalles
    enviarByteConDetalles(byteEnviado);

    esperandoLiberacion = false;  // Resetear el estado de espera
    esperandoRespuesta = true;    // Ahora esperamos la respuesta del emisor
  }

  // Actualizar el estado anterior del botón
  estadoBotonAnterior = estadoBotonActual;
}

// Función para enviar un byte y mostrar los detalles de la trama UART
void enviarByteConDetalles(unsigned char data) {
  // Construir la trama UART manualmente
  unsigned char trama[10];
  trama[0] = 0; // Start bit

  // Bits de datos (LSB primero)
  for (int i = 0; i < 8; i++) {
    trama[i + 1] = (data >> i) & 0x01;
  }

  trama[9] = 1; // Stop bit

  // Imprimir la trama completa
  Serial.print("Receptor: Trama UART enviada: ");
  for (int i = 0; i < 10; i++) {
    Serial.print(trama[i]);
  }
  Serial.println();

  // Imprimir los bits individuales con etiquetas
  Serial.println("Receptor: Detalles de la trama UART:");
  Serial.print("Start bit: ");
  Serial.println(trama[0]);
  for (int i = 1; i <= 8; i++) {
    Serial.print("Data bit D");
    Serial.print(i - 1);
    Serial.print(": ");
    Serial.println(trama[i]);
  }
  Serial.print("Stop bit: ");
  Serial.println(trama[9]);

  // Enviar el byte usando Serial1
  Serial1.write(data);
}