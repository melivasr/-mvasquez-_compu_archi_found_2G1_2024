class Pipeline:
    def __init__(self, pc, instruction_memory, register_file, data_memory, alu, decoder, extend, control_unit):
        self.pc = pc
        self.instruction_memory = instruction_memory
        self.register_file = register_file
        self.data_memory = data_memory
        self.alu = alu
        self.decoder = decoder
        self.extend = extend
        self.control_unit = control_unit

        # Inicializar las etapas del pipeline como vacías
        self.fetch_stage = None
        self.decode_stage = None
        self.execute_stage = None
        self.memory_stage = None
        self.writeback_stage = None

        self.clock_cycle = 0
        self.if_id = {}
        self.id_ex = {}
        self.ex_mem = {}
        self.mem_wb = {}

        self.execute_busy = False
        self.mode = "hazard_unit"  # Modos posibles: no_hazard, hazard_unit, branch_prediction, full_hazard

    def set_mode(self, mode):
        """
        Configura el modo de operación del pipeline.
        """
        valid_modes = ["no_hazard", "hazard_unit", "branch_prediction", "full_hazard"]
        if mode in valid_modes:
            self.mode = mode
        else:
            raise ValueError(f"Modo inválido: {mode}. Opciones válidas: {valid_modes}")

    def step(self):
        """
        Avanza el pipeline un ciclo de reloj.
        """
        print(f"\nClock Cycle: {self.clock_cycle + 1}")
        # Ejecutar las etapas en orden inverso para evitar sobrescribir datos
        self.writeback()
        self.memory()
        self.execute()
        self.decode()
        self.fetch()

        # Incrementar el ciclo de reloj
        self.clock_cycle += 1

    def fetch(self):
        """
        Etapa de Fetch: Obtiene la instrucción desde la memoria de instrucciones.
        """
        if self.fetch_stage is None:
            instruction = self.instruction_memory.fetch(self.pc.value)
            if instruction is not None:
                print(f"Fetch: Instrucción {instruction:032b} en PC={self.pc.value}")
                self.fetch_stage = {"instruction": instruction, "pc": self.pc.value}
                self.pc.increment()

    def decode(self):
        """
        Etapa de Decode: Decodifica la instrucción y genera señales de control.
        """
        if self.mode in ["hazard_unit", "full_hazard"] and self.execute_busy:
            print("Stalling decode: Waiting for execute to finish processing")
            return

        if self.fetch_stage and self.decode_stage is None:
            instruction = self.fetch_stage["instruction"]
            decoded = self.decoder.decode(instruction)
            if 'error' in decoded:
                print(f"Decode Error: {decoded['error']}")
                self.decode_stage = None
                self.fetch_stage = None
                return

            # Asegúrate de incluir siempre la instrucción original
            decoded["instruction"] = instruction

            self.control_unit.generate_signals(decoded["opcode"], decoded["funct3"], decoded["funct7"])
            print(f"Decode: PC={self.fetch_stage['pc']}: Instrucción={instruction:032b} -> Decodificación={decoded}")
            self.if_id = self.control_unit
            print(f"Control signals en decode: RegWrite: {self.if_id.RegWrite}, MemRead: {self.if_id.MemRead}, "
                  f"MemWrite: {self.if_id.MemWrite}, ALUOp: {self.if_id.ALUOp}, Branch: {self.if_id.Branch}, "
                  f"Jump: {self.if_id.Jump}, MemToReg: {self.if_id.MemToReg}, ALUSrc: {self.if_id.ALUSrc}, "
                  f"PCSrc: {self.if_id.PCSrc}")
            self.decode_stage = {"decoded": decoded, "control_signals": self.control_unit}
            self.fetch_stage = None

    def execute(self):
        """
        Etapa de Execute: Realiza operaciones de la ALU.
        """
        if self.decode_stage and self.execute_stage is None:
            if self.mode in ["hazard_unit", "full_hazard"]:
                self.execute_busy = True

            decoded = self.decode_stage["decoded"]
            self.id_ex = self.decode_stage["control_signals"]
            print(f"Control Signals en execute {self.id_ex}")
            alu_result = 0

            if decoded["type"] == "R":
                input1 = self.register_file.read(decoded["rs1"])
                input2 = self.register_file.read(decoded["rs2"])
                alu_result = self.alu.operate(input1, input2, self.id_ex.ALUOp)
            elif decoded["type"] == "I":
                input1 = self.register_file.read(decoded["rs1"])
                extended_imm = self.extend.execute(decoded["instruction"], decoded["type"])
                alu_result = self.alu.operate(input1, extended_imm, self.id_ex.ALUOp)
            elif decoded["type"] == "S":
                input1 = self.register_file.read(decoded["rs1"])
                extended_imm = self.extend.execute(decoded["instruction"], decoded["type"])
                alu_result = input1 + extended_imm
            elif decoded["type"] == "B":
                input1 = self.register_file.read(decoded["rs1"])
                input2 = self.register_file.read(decoded["rs2"])
                alu_result = self.alu.operate(input1, input2, self.id_ex.ALUOp)
                if alu_result == 0:  # Branch
                    self.pc.set(self.pc.value + decoded["imm"])

            print(f"ALU Result: {alu_result}")

            # Escribir en ex_mem
            self.ex_mem = {"alu_result": alu_result, "control_signals": self.id_ex, "decoded": decoded}
            self.decode_stage = None

    def memory(self):
        """
        Etapa de Memory: Acceso a memoria para lectura/escritura.
        """
        if self.ex_mem and self.memory_stage is None:
            control_signals = self.ex_mem["control_signals"]
            if self.mode in ["hazard_unit", "full_hazard"]:
                self.execute_busy = False  # Liberar execute_busy
            print(f"Control Signals en memory {control_signals}")
            decoded = self.ex_mem["decoded"]
            alu_result = self.ex_mem["alu_result"]

            if control_signals.MemRead:  # LW (Load Word)
                memory_data = self.data_memory.read(alu_result)
                print(f"Memory read: Dirección={alu_result}, Valor={memory_data}")
                self.memory_stage = {"memory_data": memory_data, "decoded": decoded}
            elif control_signals.MemWrite:  # SW (Store Word)
                if "rs2" in decoded:
                    data_to_write = self.register_file.read(decoded["rs2"])
                    self.data_memory.write(alu_result, data_to_write)
                    print(f"Memory write: escritura en dirección={alu_result}, valor={data_to_write}")
            else:
                self.memory_stage = {"alu_result": alu_result, "decoded": decoded}

            self.ex_mem = None

    def writeback(self):
        """
        Etapa de Write-back: Escribe los resultados en los registros.
        """
        if self.memory_stage:
            decoded = self.memory_stage["decoded"]
            if "rd" in decoded and decoded["rd"] is not None:
                if "memory_data" in self.memory_stage:
                    self.register_file.write(decoded["rd"], self.memory_stage["memory_data"])
                    print(f"WriteBack: Escrito {self.memory_stage['memory_data']} en R{decoded['rd']}")
                elif "alu_result" in self.memory_stage:
                    self.register_file.write(decoded["rd"], self.memory_stage["alu_result"])
                    print(f"WriteBack: Escrito {self.memory_stage['alu_result']} en R{decoded['rd']}")
            else:
                print("WriteBack: No se realizó escritura (instrucción sin registro destino).")
            self.memory_stage = None
