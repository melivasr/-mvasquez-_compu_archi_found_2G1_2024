class ProgramCounter:
    def __init__(self):
        self.value = 0  # Inicializamos el PC en 0

    def increment(self):
        self.value += 4  #Cada instrucción tiene 4 bytes

    def set(self, address):
        self.value = address  # Para saltos o branch

    def reset(self):
        self.value = 0

