// Definición de pines para los botones
const int botonInfo1Pin = 2;       // GPIO2
const int botonInfo2Pin = 3;       // GPIO3
const int botonConfirmPin = 4;     // GPIO4

// Variables para almacenar el estado actual de los botones de información
bool estadoInfo1 = HIGH;           // Inicialmente no presionado (pull-up)
bool estadoInfo2 = HIGH;

// Variables para el botón de confirmación
bool estadoConfirmAnterior = HIGH;
bool esperandoLiberacionConfirm = false;

// Variable para almacenar el byte recibido
unsigned char byteRecibido = 0;

void setup() {
  // Iniciar la comunicación UART a 9600 baudios
  Serial1.begin(9600);

  // Iniciar la comunicación Serial USB para el monitor serial
  Serial.begin(115200);

  // Esperar a que se inicie el monitor serial (opcional)
  while (!Serial) {
    ; // Esperar a que se conecte el monitor serial
  }

  // Configurar los pines de los botones como entradas con resistencias de pull-up internas
  pinMode(botonInfo1Pin, INPUT_PULLUP);
  pinMode(botonInfo2Pin, INPUT_PULLUP);
  pinMode(botonConfirmPin, INPUT_PULLUP);

  Serial.println("Emisor iniciado. Esperando interacción...");
}

void loop() {
  // Leer el estado actual de los botones de información
  estadoInfo1 = digitalRead(botonInfo1Pin);
  estadoInfo2 = digitalRead(botonInfo2Pin);

  // Actualizar el registro de 8 bits basado en el estado de los botones de información
  unsigned char registro8Bits = 0;  // Resetear a 00000000
  if (estadoInfo1 == LOW) {
    registro8Bits |= (1 << 1);  // Establecer Bit 1
  }
  if (estadoInfo2 == LOW) {
    registro8Bits |= (1 << 0);  // Establecer Bit 0
  }

  // Leer el estado actual del botón de confirmación
  bool estadoConfirmActual = digitalRead(botonConfirmPin);

  // Detectar el flanco de bajada (presión del botón de confirmación)
  if (estadoConfirmAnterior == HIGH && estadoConfirmActual == LOW) {
    esperandoLiberacionConfirm = true;  // Indicar que estamos esperando que se suelte el botón
  }

  // Detectar el flanco de subida (liberación del botón de confirmación)
  if (esperandoLiberacionConfirm && estadoConfirmAnterior == LOW && estadoConfirmActual == HIGH) {
    // Enviar el byte por UART
    Serial1.write(registro8Bits);

    // Imprimir mensaje al monitor serial
    Serial.print("Emisor: Enviando byte ");
    Serial.print(registro8Bits, BIN);
    Serial.println(" al receptor");

    esperandoLiberacionConfirm = false;  // Resetear el estado de espera
  }

  // Actualizar el estado anterior del botón de confirmación
  estadoConfirmAnterior = estadoConfirmActual;

  // Verificar si hay datos disponibles en UART
  if (Serial1.available() > 0) {
    // Leer el byte recibido
    byteRecibido = Serial1.read();

    // Enviar el byte recibido de vuelta al receptor
    Serial1.write(byteRecibido);

    // Imprimir mensaje al monitor serial
    Serial.print("Emisor: Recibido byte ");
    Serial.print(byteRecibido, BIN);
    Serial.println(" del receptor, reenviándolo de vuelta");
  }

  // Pequeño retraso para estabilidad
  delay(10);
}