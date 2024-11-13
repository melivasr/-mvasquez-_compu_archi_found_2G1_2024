# Clase que representa la memoria de instrucciones

class InstructionMemory:
    def __init__(self):
        self.instructions = []

    def load_instructions(self, instructions):
        self.instructions = instructions

    def fetch(self, pc):
        if pc % 4 != 0:
            return None  # Error: PC is not aligned to 4 bytes
        index = pc // 4
        if index < len(self.instructions):
            return self.instructions[index]
        else:
            return None

