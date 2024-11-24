from src.hazard_unit import HazardUnit
import time
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
        self.if_id = None
        self.id_ex = None
        self.ex_mem = None
        self.mem_wb = None
        self.hazard_unit = HazardUnit()
        self.mode = "full_hazard_unit"  # Modos posibles: no_hazard, hazard_unit, branch_prediction, full_hazard

        # Temporizador
        self.start_time = None
        self.end_time = None

        # Inicializar contador de instrucciones completadas
        self.instrucciones_completadas = 0

    def start_timer(self):
        """Inicia el temporizador."""
        self.start_time = time.time()
        print("Ejecución iniciada.")

    def stop_timer(self):
        """Detiene el temporizador y muestra el tiempo de ejecución total."""
        self.end_time = time.time()
        elapsed_time = self.end_time - self.start_time
        print(f"Ejecución completada en {elapsed_time:.6f} segundos.")
        return elapsed_time

    def get_elapsed_time(self):
        """Devuelve el tiempo transcurrido desde el inicio del pipeline."""
        if self.start_time is not None:
            return time.time() - self.start_time
        return 0.0

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
        if self.start_time is None:  # Iniciar temporizador al primer paso
            self.start_timer()

        print(f"\nClock Cycle: {self.clock_cycle + 1}")
        # Ejecutar las etapas en orden inverso para evitar sobrescribir datos
        self.writeback()
        self.memory()
        self.execute()
        self.decode()
        self.fetch()

        # Incrementar el ciclo de reloj
        self.clock_cycle += 1

        # Verificar si el pipeline está vacío y detener el temporizador
        if all(stage is None for stage in [self.if_id, self.id_ex, self.ex_mem, self.mem_wb]):
            self.stop_timer()

    def fetch(self):
        
        """
        Etapa de Fetch: Obtiene la instrucción desde la memoria de instrucciones.
        """
        if self.if_id is None:
            instruction = self.instruction_memory.fetch(self.pc.value)
            if instruction is not None:
                print(f"Fetch: Instrucción {instruction:032b} en PC={self.pc.value}")
                self.if_id = {"instruction": instruction, "pc": self.pc.value, "instruction_pipeline": instruction}
                self.pc.increment()

    def decode(self):
        if self.if_id and self.id_ex is None:
            instruction = self.if_id["instruction"]
            decoded = self.decoder.decode(instruction)

            if 'error' in decoded:
                print(f"Decode Error: {decoded['error']}")
                self.if_id = None
                return

            # Incluir la instrucción original en el diccionario decodificado
            decoded['instruction'] = instruction

            # Detectar riesgos de datos
            stall_needed, forwarding_signals, branch_prediction = self.hazard_unit.detect_hazards(
                decode_stage={"decoded": decoded},
                execute_stage=self.id_ex,
                memory_stage=self.ex_mem,
                mode=self.mode
            )

            if stall_needed:
                print("Stalling decode: Hazard Unit detectó riesgo")
                # Inserta un NOP en la etapa de ejecución
                self.id_ex = {"decoded": self.no_op_instruction(), "control_signals": self.default_control_signals(), "instruction_pipeline": "NOP"}
                # Mantén la instrucción actual en if_id para volver a decodificarla en el próximo ciclo
                return

            if branch_prediction is not None:
                print(f"Branch Prediction: {'Taken' if branch_prediction else 'Not Taken'}")

            # Agregar señales de forwarding
            decoded["forwarding"] = forwarding_signals

            # Generar señales de control
            self.control_unit.generate_signals(decoded["opcode"], decoded.get("funct3"), decoded.get("funct7"))
            
            # Extraer señales de control como diccionario
            control_signals = self.extract_control_signals()

            print(f"Decode: PC={self.if_id['pc']}: Instrucción={instruction:032b} -> Decodificación={decoded}")

            # Actualizar el registro del pipeline para la etapa id_ex
            self.id_ex = {"decoded": decoded, "control_signals": control_signals,"instruction_pipeline": decoded["instruction_pipeline"]}
            self.if_id = None

    def execute(self):
        if self.id_ex and self.ex_mem is None:
            decoded = self.id_ex["decoded"]
            control_signals = self.id_ex["control_signals"]
            instruction_pipeline  = self.id_ex["instruction_pipeline"]
            print(f"Control Signals en execute {control_signals}")
            forwarding = decoded.get("forwarding", {})
            if decoded.get("rs2") is not None:
                print(f"Decoded rs1: {decoded.get('rs1')}, Decoded rs2: {decoded.get('rs2')}")
                print(f"Register R{decoded.get('rs1')} Value: {self.register_file.read(decoded.get('rs1'))}")
                print(f"Register R{decoded.get('rs2')} Value: {self.register_file.read(decoded.get('rs2'))}")

            # Manejo de rs1 y rs2 con validación
            input1 = (
            self.ex_mem["alu_result"] if forwarding.get("rs1") == "execute" and self.ex_mem else
            self.mem_wb["alu_result"] if forwarding.get("rs1") == "memory" and self.mem_wb else
            self.register_file.read(decoded["rs1"]) if "rs1" in decoded and isinstance(decoded["rs1"], int) else 0
            )

            input2 = (
                self.ex_mem["alu_result"] if forwarding.get("rs2") == "execute" and self.ex_mem else
                self.mem_wb["alu_result"] if forwarding.get("rs2") == "memory" and self.mem_wb else
                self.register_file.read(decoded["rs2"]) if "rs2" in decoded and isinstance(decoded["rs2"], int) else 0
            )


            alu_result = 0
            if decoded["type"] == "R":
                alu_result = self.alu.operate(input1, input2, control_signals['ALUOp'])
            elif decoded["type"] == "I":
                extended_imm = self.extend.execute(decoded["instruction"], decoded["type"])
                alu_result = self.alu.operate(input1, extended_imm, control_signals['ALUOp'])
            elif decoded["type"] == "S":
                extended_imm = self.extend.execute(decoded["instruction"], decoded["type"])
                alu_result = input1 + extended_imm
            elif decoded["type"] == "B":
                 # Obtener el inmediato extendido
                extended_imm = self.extend.execute(decoded["instruction"], decoded["type"])
                alu_result = self.alu.operate(input1, input2, control_signals['ALUOp'])
                if alu_result == 0:  # Branch Taken
                    if self.mode in ["branch_prediction", "full_hazard_unit"]:
                        print("Branch Taken: Incorrect prediction, performing flush")
                        # Realizar el flush del pipeline
                        self.if_id = None
                        self.id_ex = None
                        # Ajustar el PC al destino correcto
                        old_pc = self.pc.value
                        self.pc.set(self.pc.value + extended_imm)
                        print(f"BEQ Branch Taken: Imm={extended_imm}, PC Before={old_pc}, PC After={self.pc.value}")
                else:
                    if self.mode in ["branch_prediction", "full_hazard_unit"]:
                        print("Branch Not Taken: Prediction was correct.")      

            print(f"ALU Result: {alu_result}")

            print(f"[Execute] ALU Result: {alu_result}, Control Signals: {control_signals}")


            # Escribir en ex_mem
            self.ex_mem = {"alu_result": alu_result, "control_signals": control_signals, "decoded": decoded, "instruction_pipeline":instruction_pipeline}
            self.id_ex = None



    def memory(self):
        if self.ex_mem and self.mem_wb is None:
            decoded = self.ex_mem["decoded"]
            control_signals = self.ex_mem["control_signals"]
            alu_result = self.ex_mem["alu_result"]
            instruction_pipeline = self.ex_mem["instruction_pipeline"]

            if control_signals['MemRead']:
                memory_data = self.data_memory.read(alu_result)
                print(f"Memory read: Dirección={alu_result}, Valor={memory_data}")
                self.mem_wb = {"memory_data": memory_data, "decoded": decoded,"instruction_pipeline": instruction_pipeline}
            elif control_signals['MemWrite']:
                if "rs2" in decoded:
                    data_to_write = self.register_file.read(decoded["rs2"])
                    self.data_memory.write(alu_result, data_to_write)
                    print(f"Memory write: Escritura en dirección={alu_result}, valor={data_to_write}")
                # Actualizar mem_wb después de una escritura
                self.mem_wb = {"decoded": decoded, "instruction_pipeline":instruction_pipeline}
            else:
                self.mem_wb = {"alu_result": alu_result, "decoded": decoded, "instruction_pipeline":instruction_pipeline }

            self.ex_mem = None


    def writeback(self):
        if self.mem_wb:
            decoded = self.mem_wb["decoded"]
            instruction_pipeline = self.mem_wb.get("instruction_pipeline")

            if "rd" in decoded and decoded["rd"] is not None:
                if "memory_data" in self.mem_wb:
                    self.register_file.write(decoded["rd"], self.mem_wb["memory_data"])
                    print(f"WriteBack: Escrito {self.mem_wb['memory_data']} en R{decoded['rd']}")
                elif "alu_result" in self.mem_wb:
                    self.register_file.write(decoded["rd"], self.mem_wb["alu_result"])
                    print(f"WriteBack: Escrito {self.mem_wb['alu_result']} en R{decoded['rd']}")
            else:
                print("WriteBack: No se realizó escritura (instrucción sin registro destino).")

            self.writeback_stage = {"instruction_pipeline": instruction_pipeline}
            self.mem_wb = None
        else:
            self.writeback_stage = None #Esto es para la interfaz

    def no_op_instruction(self):
        return {
            'opcode': 0,
            'funct3': 0,
            'funct7': 0,
            'type': 'NOP',
            'name': 'NOP',
            'rd': None,
            'rs1': None,
            'rs2': None,
            'imm': 0,
            'instruction': 0,
            'forwarding': {}
        }

    
    def default_control_signals(self):
        """
        Retorna un diccionario con valores neutros para todas las señales de control.
        Esto se utiliza para manejar NOPs.
        """
        return {
            'RegWrite': 0,
            'MemRead': 0,
            'MemWrite': 0,
            'ALUOp': 0,
            'Branch': 0,
            'Jump': 0,
            'MemToReg': 0,
            'ALUSrc': 0,
            'PCSrc': 0,
            'PCWrite': 1
        }
    def extract_control_signals(self):
        """
        Extrae los valores actuales de las señales de control en `ControlUnit` 
        y los convierte en un diccionario.
        """
        return {
            'RegWrite': self.control_unit.RegWrite,
            'MemRead': self.control_unit.MemRead,
            'MemWrite': self.control_unit.MemWrite,
            'ALUOp': self.control_unit.ALUOp,
            'Branch': self.control_unit.Branch,
            'Jump': self.control_unit.Jump,
            'MemToReg': self.control_unit.MemToReg,
            'ALUSrc': self.control_unit.ALUSrc,
            'PCSrc': self.control_unit.PCSrc,
            'PCWrite': self.control_unit.PCWrite
        }

    def reiniciar(self):
        """
        Reinicia el pipeline a su estado inicial.
        """
        # Reiniciar el contador de programa (PC)
        self.pc.reset()

        # Reiniciar el temporizador
        self.start_time = None
        self.end_time = None

        # Vaciar todas las etapas del pipeline
        self.fetch_stage = None
        self.decode_stage = None
        self.execute_stage = None
        self.memory_stage = None
        self.writeback_stage = None

        # Reiniciar los registros del pipeline
        self.if_id = None
        self.id_ex = None
        self.ex_mem = None
        self.mem_wb = None

        # Reiniciar el ciclo de reloj
        self.clock_cycle = 0

        # Reiniciar el contador de instrucciones completadas
        self.instrucciones_completadas = 0

        self.mode = "full_hazard_unit"

        print("Pipeline reiniciado.")

    def is_pipeline_empty(self):
        """
        Verifica si todas las etapas del pipeline están vacías y si el PC ya ha recorrido todas las instrucciones.
        """
        instrucciones_terminadas = (
                self.pc.value >= len(self.instruction_memory.instructions) * 4
        )
        etapas_vacias = all(
            stage is None for stage in [self.if_id, self.id_ex, self.ex_mem, self.mem_wb]
        )
        return instrucciones_terminadas and etapas_vacias

    def calcular_cpi(self):
        """
        Calcula el CPI basado en las instrucciones completadas.
        """
        instrucciones_completadas = self.pipeline_instructions_completed()
        if instrucciones_completadas == 0:  # Evitar división por cero
            return 0
        return self.clock_cycle / instrucciones_completadas

    def pipeline_instructions_completed(self):
        """
        Calcula el número de instrucciones completadas (escritas en WB).
        """
        # Usar un contador acumulado de instrucciones completadas
        completadas = getattr(self, "instrucciones_completadas", 0)

        # Incrementar si una instrucción pasa por WB
        if self.writeback_stage is not None: # no todas pasan por WB
            completadas += 1
            self.instrucciones_completadas = completadas  # Guardar el valor acumulado

        return completadas
