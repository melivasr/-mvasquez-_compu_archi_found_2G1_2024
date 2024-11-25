class RegisterFile:
    def __init__(self):
        self.registers = [0] * 32  # Inicializamos 32 registros en 0, el registro 0 no puede escribirse.

        # Inicializar algunos registros con valores no cero
        self.registers[1] = 10  # R1 con valor 10
        self.registers[2] = 5   # R2 con valor 5
        self.registers[3] = 0   # R3 con valor 0

    def read(self, reg_num):
        """
        Lee el valor de un registro especificado por el número de registro.
        """
        if reg_num == 0:
            return 0  # El registro 0 es siempre 0
        return self.registers[reg_num]

    def write(self, reg_num, value):
        """
        Escribe un valor en un registro, excepto en el registro 0 que es de solo lectura.
        """
        if reg_num != 0:  # El registro 0 no se puede escribir
            self.registers[reg_num] = value

    def resetRegisters(self):
        """Reinicia todos los registros a 0, excepto los valores iniciales que se quieran mantener."""
        self.registers = [0] * 32
        # Si deseas reiniciar con valores iniciales específicos:
        self.registers[1] = 10
        self.registers[2] = 5
        self.registers[3] = 0

    def __str__(self):
        """
        Para visualizar los valores de todos los registros.
        """
        return str(self.registers)
