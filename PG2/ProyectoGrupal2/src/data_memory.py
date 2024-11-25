class DataMemory:
    def __init__(self):
        self.memory = [0] * 128  # Cada posición representa 4 bytes, total 512 bytes
        self.update_callback = None  # Callback para notificar cambios

    def set_update_callback(self, callback):
        """Asigna un callback para notificar actualizaciones en la memoria."""
        self.update_callback = callback

    def read(self, address):
        """Lee un bloque de 4 bytes desde la dirección especificada."""
        index = address // 4  # Calcular la posición en el array
        if 0 <= index < len(self.memory):
            return self.memory[index]
        else:
            print(f"Error: Dirección de memoria fuera de rango: {address}")
            return None

    def write(self, address, data):
        """Escribe un bloque de 4 bytes en la dirección especificada."""
        index = address // 4  # Calcular la posición en el array
        if 0 <= index < len(self.memory):
            self.memory[index] = data
            if self.update_callback:
                self.update_callback(address, data)
        else:
            print(f"Error: Dirección de memoria fuera de rango: {address}")

    def dump(self):
        """Devuelve una lista con todas las direcciones y sus valores."""
        result = []
        for i in range(len(self.memory)):
            address = i * 4  # Calcular la dirección real
            result.append((address, self.memory[i]))
        return result

    def resetDM(self):
        """Reinicia toda la memoria de datos a 0."""
        self.memory = [0] * 128
        if self.update_callback:
            for address in range(0, len(self.memory) * 4, 4):
                self.update_callback(address, 0)
