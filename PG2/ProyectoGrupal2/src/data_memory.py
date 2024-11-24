class DataMemory:
    def __init__(self):
        self.memory = [0] * 512  # Memoria inicializada con 0
        self.update_callback = None  # Callback para notificar cambios

    def set_update_callback(self, callback):
        """Asigna un callback para notificar actualizaciones en la memoria."""
        self.update_callback = callback

    def read(self, address):
        """Lee un valor de memoria en la dirección especificada."""
        if 0 <= address < len(self.memory):
            return self.memory[address]
        else:
            print(f"Error: Dirección de memoria fuera de rango: {address}")
            return None

    def write(self, address, data):
        """Escribe un valor en la memoria en la dirección especificada."""
        if 0 <= address < len(self.memory):
            self.memory[address] = data
            if self.update_callback:
                self.update_callback(address, data)
        else:
            print(f"Error: Dirección de memoria fuera de rango: {address}")
