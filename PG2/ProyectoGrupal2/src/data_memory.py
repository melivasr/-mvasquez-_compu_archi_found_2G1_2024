class DataMemory:
    def __init__(self, size=1050):
        self.memory = [0] * size  # Inicializamos una memoria de 1024 posiciones, con valores en 0.

    def read(self, address):
        """
        Lee un valor de memoria en la dirección especificada.
        Asegúrate de que la dirección sea válida.
        """
        if 0 <= address < len(self.memory):
            return self.memory[address]
        else:
            print(f"Error: Dirección de memoria fuera de rango: {address}")
            return None

    def write(self, address, data):
        """
        Escribe un valor en la memoria en la dirección especificada.
        Asegúrate de que la dirección sea válida.
        """
        if 0 <= address < len(self.memory):
            self.memory[address] = data
        else:
            print(f"Error: Dirección de memoria fuera de rango: {address}")

    def display(self):
        return str(self.memory)
