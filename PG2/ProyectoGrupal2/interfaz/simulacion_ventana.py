import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import os
import json


class SimulacionVentana:
    def __init__(self, root, ventana_configuracion, pipeline, modo_funcionamiento, version1, version2):
        self.ejecutar_simulacion = None
        self.siguiente_paso = None
        self.modo_funcionamiento = modo_funcionamiento
        self.root = root
        self.ventana_configuracion = ventana_configuracion
        self.root.title("Simulación de Pipeline")
        self.root.state('zoomed')
        self.root.configure(bg="#61C6E8")
        self.pipeline = pipeline
        self.register_file = pipeline.register_file
        self.instruction_memory = pipeline.instruction_memory
        self.data_memory = pipeline.data_memory
        self.version_actual = 1  # Controla qué versión está activa
        self.modo_version1 = version1
        self.modo_version2 = version2
        self.historial_file = "historial.json"
        self.init_historial()
        self.datos_guardados = {
            "version1": False,
            "version2": False
        }

        # Configurar la primera versión
        self.pipeline.set_mode(self.modo_version1)

        self.label_version = tk.Label(self.root, text=f"Ejecutando versión:{self.modo_version1} ",
                                      bg="#61C6E8", font=("Comic Sans MS", 14, "bold"), fg="#003333")
        self.label_version.pack(side=tk.TOP, pady=10)

        # Frame para el pipeline visual y el área de control con borde
        frame_pipeline = tk.Frame(self.root, bg="#61C6E8", highlightbackground="black", highlightthickness=0)
        frame_pipeline.pack(side=tk.LEFT, padx=10, pady=20)

        # Frame para las instrucciones en el pipeline
        frame_instruccion= tk.Frame(frame_pipeline, bg="#61C6E8", highlightbackground="black", highlightthickness=0)
        frame_instruccion.pack(side=tk.TOP, fill=tk.X, pady=(0, 10))

        # Crear etiquetas para las etapas con anchos ajustables
        self.instruccion_labels = []
        instrucciones = ["", "", "", "", ""]
        instruccion_widths = [25, 25, 26, 17, 12]
        for etapa, width in zip(instrucciones, instruccion_widths):
            label = tk.Label(frame_instruccion, text=etapa, bg="#61C6E8",
                             font=("Arial", 9, "bold"), width=width, height=2, relief="ridge")
            label.pack(side=tk.LEFT, expand=True, padx=5, pady=5)
            self.instruccion_labels.append(label)

        # Crear el canvas para el pipeline
        self.canvas = tk.Canvas(frame_pipeline, width=800, height=330, bg="#61C6E8", highlightthickness=0)
        self.canvas.pack()

        # Cargar la imagen de fondo
        try:
            image_path = os.path.abspath("interfaz/cables.png")
            self.background_image = Image.open(image_path)
            self.background_image = self.background_image.resize((800, 330), Image.LANCZOS)
            self.background_photo = ImageTk.PhotoImage(self.background_image)
            self.canvas.create_image(0, 0, image=self.background_photo, anchor="nw")  # Coloca la imagen en el fondo
            print("Imagen cargada exitosamente")
        except Exception as e:
            print("Error al cargar la imagen de fondo:", e)

        # Definición de los componentes con posiciones y tamaños ajustados
        components = {
            "Mux1": (20, 100, 40, 130),
            "PCPlus4": (105, 40, 125, 70),
            "PC": (60, 95, 90, 135),
            "InstrMemory": (110, 90, 180, 140),
            "IF/ID": (190, 30, 210, 280),
            "RegisterFile": (290, 100, 360, 150),
            "Decode": (235, 130, 265, 170),
            "ID/EX": (370, 30, 390, 280),
            "Imm": (300, 190, 340, 210),
            "Mux2": (425, 90, 445, 120),
            "Mux3": (415, 145, 435, 175),
            "Mux4": (470, 80, 490, 110),
            "Mux5": (470, 155, 490, 185),
            "ALU": (500, 90, 550, 180),
            "Branch": (460, 230, 500, 260),
            "EX/MEM": (570, 30, 590, 280),
            "DataMemory": (610, 110, 680, 160),
            "MEM/WB": (700, 30, 720, 280),
            "Mux6": (750, 110, 770, 140),
        }

        self.rectangles = {}
        for name, coords in components.items():
            # Crear rectángulos y texto sobre el canvas
            self.rectangles[name] = self.canvas.create_rectangle(*coords, fill="white", outline="black")
            self.canvas.create_text((coords[0] + coords[2]) / 2, coords[3] + 10, text=name)

        # Frame para los datos de control y ejecución a la derecha
        frame_datos = tk.Frame(self.root, bg="#61C6E8")
        frame_datos.pack(side=tk.RIGHT, padx=20, pady=20)

        # Campos de métricas
        tk.Label(frame_datos, text="Cycles:", font=("Comic Sans MS", 10), bg="#61C6E8").grid(row=1, column=1, sticky="e", padx=10)
        self.entry_ciclo = tk.Entry(frame_datos, width=10)
        self.entry_ciclo.grid(row=1, column=2, padx=5, pady=5)

        tk.Label(frame_datos, text="Tiempo:", font=("Comic Sans MS", 10), bg="#61C6E8").grid(row=2, column=1, sticky="e", padx=10)
        self.entry_tiempo = tk.Entry(frame_datos, width=10)
        self.entry_tiempo.grid(row=2, column=2, padx=5, pady=5)

        tk.Label(frame_datos, text="Valor PC:", font=("Comic Sans MS", 10), bg="#61C6E8").grid(row=3, column=1, sticky="e", padx=10)
        self.entry_pc = tk.Entry(frame_datos, width=10)
        self.entry_pc.grid(row=3, column=2, padx=5, pady=5)

        tk.Label(frame_datos, text="CPI:", font=("Comic Sans MS", 10), bg="#61C6E8").grid(row=4, column=1, sticky="e", padx=10)
        self.entry_cpi = tk.Entry(frame_datos, width=10)
        self.entry_cpi.grid(row=4, column=2, padx=5, pady=5)

        tk.Label(frame_datos, text="IPC:", font=("Comic Sans MS", 10), bg="#61C6E8").grid(row=5, column=1, sticky="e", padx=10)
        self.entry_ipc = tk.Entry(frame_datos, width=10)
        self.entry_ipc.grid(row=5, column=2, padx=5, pady=5)


        # Tabla de memoria de instrucciones
        tk.Label(frame_datos, text="Memoria de instrucciones:", font=("Comic Sans MS", 10), bg="#61C6E8").grid(row=6, column=1, sticky="w",
                                                                                   columnspan=1)
        self.tree_memoria = ttk.Treeview(frame_datos, columns=("Addr", "Stage", "Instruction"), show="headings",
                                         height=5)
        self.tree_memoria.heading("Addr", text="Addr")
        self.tree_memoria.heading("Stage", text="Stage")
        self.tree_memoria.heading("Instruction", text="Instruction")
        self.tree_memoria.column("Addr", width=50)
        self.tree_memoria.column("Stage", width=50)
        self.tree_memoria.column("Instruction", width=80)
        self.tree_memoria.grid(row=7, column=1, padx=5, pady=5)

        # Tabla de registros
        tk.Label(frame_datos, text="Valor registros:", font=("Comic Sans MS", 10), bg="#61C6E8",).grid(row=8, column=1, sticky="w", columnspan=2)
        self.tree_registros = ttk.Treeview(frame_datos, columns=("Name", "Alias", "Value"), show="headings", height=5)
        self.tree_registros.heading("Name", text="Name")
        self.tree_registros.heading("Alias", text="Alias")
        self.tree_registros.heading("Value", text="Value")
        self.tree_registros.column("Name", width=50)
        self.tree_registros.column("Alias", width=50)
        self.tree_registros.column("Value", width=50)
        self.tree_registros.grid(row=9, column=1, padx=5, pady=5)

        # Tabla de memoria de datos
        tk.Label(frame_datos, text="Memoria de datos:", font=("Comic Sans MS", 10), bg="#61C6E8").grid(row=8, column=2, sticky="w", columnspan=1)
        self.tree_datos = ttk.Treeview(frame_datos, columns=("Addr", "Data"), show="headings", height=5)
        self.tree_datos.heading("Addr", text="Addr")
        self.tree_datos.heading("Data", text="Data")
        self.tree_datos.column("Addr", width=50)
        self.tree_datos.column("Data", width=80)
        self.tree_datos.grid(row=9, column=2, padx=5, pady=5)

        # Botones redondeados
        if self.modo_funcionamiento == "Step by step":
            self.create_rounded_button(self.root, "Next", self.ejecutar_next, x=660, y=550, width=100, height=40)
        elif    self.modo_funcionamiento == "Un ciclo cada unidad de tiempo":
            self.create_rounded_button(self.root, "Ejecutar", self.ejecutar_pipeline, x=660, y=550, width=100, height=40)
        else:
            self.create_rounded_button(self.root, "Ejecutar completo", self.ejecutar_pipeline_completo, x=660, y=550, width=150, height=40)
        self.create_rounded_button(self.root, "Volver a configuración", self.volver_a_configuracion, x=500, y=550, width=150, height=40)


        # Actualización periódica de las memorias
        self.actualizar_registros_periodicamente()
        self.actualizar_memoria_periodicamente()
        self.actualizar_memoria_datos_periodicamente()


    def create_rounded_button(self, parent, text, command, x, y, width, height, font=("Comic Sans MS", 10, "bold")):
        canvas = tk.Canvas(parent, width=width, height=height, bg="#61C6E8", highlightthickness=0)
        canvas.place(x=x, y=y)
        radius = height // 2
        canvas.create_oval(0, 0, height, height, fill="#005F6A", outline="")
        canvas.create_oval(width - height, 0, width, height, fill="#005F6A", outline="")
        canvas.create_rectangle(radius, 0, width - radius, height, fill="#005F6A", outline="")
        canvas.create_text(width // 2, height // 2, text=text, fill="white", font=font)
        canvas.bind("<Button-1>", lambda event: command())

    def cambiar_color_pipeline(self):
        for component in self.rectangles.values():
            self.canvas.itemconfig(component, fill="lightblue")

    def actualizar_registros(self):
        # Limpiar la tabla antes de actualizar
        for item in self.tree_registros.get_children():
            self.tree_registros.delete(item)

        # Agregar los valores actuales de los registros
        for i, value in enumerate(self.register_file.registers):
            self.tree_registros.insert("", "end", values=(f"x{i}", f"R{i}", value))

    def actualizar_registros_periodicamente(self):
        self.actualizar_registros()
        self.root.after(1000, self.actualizar_registros_periodicamente)  # Actualiza cada 1 segundo

    def actualizar_memoria_instrucciones(self):
        """Actualiza la tabla de memoria de instrucciones en función de la etapa del pipeline."""
        # Limpiar la tabla antes de actualizar
        for item in self.tree_memoria.get_children():
            self.tree_memoria.delete(item)

        # Agrega etapas actuales de las instrucciones
        for addr, instruction in enumerate(self.instruction_memory.instructions):
            stage = ""  # Valor por defecto
            # Determinar la etapa actual para la instrucción
            if self.pipeline.if_id and self.pipeline.if_id["pc"] == addr * 4:
                stage = "ID"
            elif self.pipeline.id_ex and self.pipeline.id_ex["decoded"]["instruction"] == instruction:
                stage = "IF"
            elif self.pipeline.ex_mem and self.pipeline.ex_mem["decoded"]["instruction"] == instruction:
                stage = "EX"
            elif self.pipeline.mem_wb and self.pipeline.mem_wb["decoded"]["instruction"] == instruction:
                stage = "MEM"
            elif self.pipeline.writeback_stage and self.pipeline.writeback_stage["instruction_pipeline"] == instruction:
                stage = "WB"

            # Insertar en la tabla
            self.tree_memoria.insert("", "end", values=(f"0x{addr * 4}", stage, instruction))

    def actualizar_memoria_periodicamente(self):
        self.actualizar_memoria_instrucciones()
        self.root.after(1000, self.actualizar_memoria_periodicamente)  # Actualiza cada 1 segundo

    def actualizar_memoria_datos(self):
        """Actualiza toda la tabla de memoria de datos."""
        # Limpiar la tabla antes de actualizar
        for item in self.tree_datos.get_children():
            self.tree_datos.delete(item)

        # Agregar los datos actuales de la memoria
        for addr, value in enumerate(self.data_memory.memory):
            self.tree_datos.insert("", "end", values=(f"0x{addr*4}", value))

    def actualizar_memoria_datos_periodicamente(self):
        """Actualiza la tabla de memoria periódicamente."""
        self.actualizar_memoria_datos()
        self.root.after(1000, self.actualizar_memoria_datos_periodicamente)  # Actualiza cada 1 segundo

    def init_historial(self):
        """Inicializa el archivo JSON si no existe."""
        if not os.path.exists(self.historial_file):
            with open(self.historial_file, 'w') as f:
                json.dump([], f)  # Inicializa con una lista vacía

    def guardar_historial(self, datos, version):
        """Guarda los datos de la versión en el archivo JSON."""
        try:
            # Comprueba si el archivo existe y tiene contenido válido
            if os.path.exists(self.historial_file) and os.path.getsize(self.historial_file) > 0:
                with open(self.historial_file, 'r') as f:
                    historial = json.load(f)  # Intenta cargar el contenido existente
            else:
                historial = []  # Si el archivo no existe o está vacío, inicializa una lista vacía

            if not self.datos_guardados[version]:  # Solo guarda si no ha sido guardado aún
                historial.append(datos)  # Agrega los nuevos datos al historial

                with open(self.historial_file, 'w') as f:
                    json.dump(historial, f, indent=4)  # Escribe el historial actualizado
                self.datos_guardados[version] = True  # Marca como guardado
        except json.JSONDecodeError as e:
            print(f"Error al leer el archivo JSON: {e}")
            # Inicializa el archivo con una lista vacía si está corrupto
            with open(self.historial_file, 'w') as f:
                json.dump([datos], f, indent=4)
            self.datos_guardados[version] = True

    def ejecutar_next(self):
        """Ejecuta un ciclo del pipeline."""
        if not self.pipeline.is_pipeline_empty():
            self.pipeline.step()
            self.actualizar_interfaz()
        else:
            if self.version_actual == 1 and not self.datos_guardados["version1"]:
                print("Primera versión completada. Guardando datos...")
                datos_version = {
                    "1 Version": self.modo_version1,
                    "Cycles": self.pipeline.clock_cycle,
                    "Tiempo": round(self.pipeline.get_elapsed_time(), 3),  # Formato con 3 decimales
                    "CPI": round(self.pipeline.calcular_cpi(), 3),  # Formato con 3 decimales
                    "IPC": round(1 / self.pipeline.calcular_cpi(), 3) if self.pipeline.calcular_cpi() != 0 else 0
                }
                self.guardar_historial(datos_version, "version1")

                print("Reiniciando pipeline para la segunda versión...")
                # Cambiar a la segunda versión
                self.pipeline.reiniciar()
                self.pipeline.set_mode(self.modo_version2)
                self.version_actual = 2
                self.label_version.config(text=f"Ejecutando versión: {self.modo_version2}")
                self.actualizar_interfaz()
            elif self.version_actual == 2 and not self.datos_guardados["version2"]:
                print("Segunda versión completada. Guardando datos...")
                datos_version = {
                    "2 Version": self.modo_version2,
                    "Cycles 2": self.pipeline.clock_cycle,
                    "Tiempo 2": round(self.pipeline.get_elapsed_time(), 3),  # Formato con 3 decimales
                    "CPI 2": round(self.pipeline.calcular_cpi(), 3),  # Formato con 3 decimales
                    "IPC 2": round(1 / self.pipeline.calcular_cpi(), 3) if self.pipeline.calcular_cpi() != 0 else 0
                }
                self.guardar_historial(datos_version, "version2")

                print("Pipeline completado para ambas versiones.")

    def ejecutar_pipeline(self):
        """Ejecuta el pipeline de forma continua, un ciclo cada unidad de tiempo."""

        def ejecutar_ciclo():
            if not self.pipeline.is_pipeline_empty():
                self.pipeline.step()
                self.actualizar_interfaz()
                self.root.after(1000, ejecutar_ciclo)  # Ejecuta cada segundo
            else:
                if self.version_actual == 1 and not self.datos_guardados["version1"]:
                    print("Primera versión completada. Guardando datos...")
                    datos_version = {
                        "1 Version": self.modo_version1,
                        "Cycles": self.pipeline.clock_cycle,
                        "Tiempo": round(self.pipeline.get_elapsed_time(), 3),  # Formato con 3 decimales
                        "CPI": round(self.pipeline.calcular_cpi(), 3),  # Formato con 3 decimales
                        "IPC": round(1 / self.pipeline.calcular_cpi(), 3) if self.pipeline.calcular_cpi() != 0 else 0
                    }
                    self.guardar_historial(datos_version, "version1")

                    print("Reiniciando pipeline para la segunda versión...")
                    # Cambiar a la segunda versión
                    self.pipeline.reiniciar()
                    self.pipeline.set_mode(self.modo_version2)
                    self.version_actual = 2
                    self.label_version.config(text=f"Ejecutando versión: {self.modo_version2}")
                    self.actualizar_interfaz()
                    self.root.after(1000, ejecutar_ciclo)  # Ejecuta la segunda versión
                elif self.version_actual == 2 and not self.datos_guardados["version2"]:
                    print("Segunda versión completada. Guardando datos...")
                    datos_version = {
                        "2 Version": self.modo_version2,
                        "Cycles 2": self.pipeline.clock_cycle,
                        "Tiempo 2": round(self.pipeline.get_elapsed_time(), 3),  # Formato con 3 decimales
                        "CPI 2": round(self.pipeline.calcular_cpi(), 3),  # Formato con 3 decimales
                        "IPC 2": round(1 / self.pipeline.calcular_cpi(), 3) if self.pipeline.calcular_cpi() != 0 else 0
                    }
                    self.guardar_historial(datos_version, "version2")

                    print("Pipeline completado para ambas versiones.")

        ejecutar_ciclo()

    def ejecutar_pipeline_completo(self):
        """Ejecuta el pipeline completo hasta que esté vacío."""
        if not self.pipeline.is_pipeline_empty():
            self.pipeline.step()
            self.actualizar_interfaz()
            self.root.after(10, self.ejecutar_pipeline_completo)  # Ejecuta rápidamente sin bloquear
        else:
            if self.version_actual == 1 and not self.datos_guardados["version1"]:
                print("Primera versión completada. Guardando datos...")
                datos_version = {
                    "1 Version": self.modo_version1,
                    "Cycles": self.pipeline.clock_cycle,
                    "Tiempo": round(self.pipeline.get_elapsed_time(), 3),  # Formato con 3 decimales
                    "CPI": round(self.pipeline.calcular_cpi(), 3),  # Formato con 3 decimales
                    "IPC": round(1 / self.pipeline.calcular_cpi(), 3) if self.pipeline.calcular_cpi() != 0 else 0
                }
                self.guardar_historial(datos_version, "version1")

                print("Reiniciando pipeline para la segunda versión...")
                # Cambiar a la segunda versión
                self.pipeline.reiniciar()
                self.pipeline.set_mode(self.modo_version2)
                self.version_actual = 2
                self.label_version.config(text=f"Ejecutando versión: {self.modo_version2}")
                self.actualizar_interfaz()
                self.root.after(10, self.ejecutar_pipeline_completo)  # Ejecuta rápidamente la segunda versión
            elif self.version_actual == 2 and not self.datos_guardados["version2"]:
                print("Segunda versión completada. Guardando datos...")
                datos_version = {
                    "2 Version": self.modo_version2,
                    "Cycles 2": self.pipeline.clock_cycle,
                    "Tiempo 2": round(self.pipeline.get_elapsed_time(), 3),  # Formato con 3 decimales
                    "CPI 2": round(self.pipeline.calcular_cpi(), 3),  # Formato con 3 decimales
                    "IPC 2": round(1 / self.pipeline.calcular_cpi(), 3) if self.pipeline.calcular_cpi() != 0 else 0
                }
                self.guardar_historial(datos_version, "version2")

                print("Pipeline ejecutado completamente para ambas versiones.")
    def actualizar_cpi_ipc(self):
        """
        Actualiza los valores de CPI e IPC en la interfaz.
        """
        # Calcular CPI
        cpi = self.pipeline.calcular_cpi()

        # Evitar división por cero para IPC
        if cpi == 0:
            ipc = 0
        else:
            ipc = 1 / cpi

        # Actualizar los campos en la interfaz
        self.entry_cpi.delete(0, tk.END)
        self.entry_cpi.insert(0, f"{cpi:.2f}")

        self.entry_ipc.delete(0, tk.END)
        self.entry_ipc.insert(0, f"{ipc:.2f}")

    def actualizar_interfaz(self):
        """Actualiza los datos de la interfaz, como ciclo, PC, registros y etapas."""
        # Restablecer colores de los rectángulos
        for rect in self.rectangles.values():
            self.canvas.itemconfig(rect, fill="white")  # Color predeterminado

        # Actualizar ciclo y PC
        self.entry_ciclo.delete(0, tk.END)
        self.entry_ciclo.insert(0, self.pipeline.clock_cycle)
        self.entry_pc.delete(0, tk.END)
        self.entry_pc.insert(0, f"0x{self.pipeline.pc.value}")

        # Actualizar CPI e IPC
        self.actualizar_cpi_ipc()

        # Actualizar tiempo
        elapsed_time = self.pipeline.get_elapsed_time()
        self.entry_tiempo.delete(0, tk.END)
        self.entry_tiempo.insert(0, f"{elapsed_time:.2f} s")

        # Actualizar etiquetas de las etapas del pipeline
        etapas = [
            {"stage": "IF", "data": self.pipeline.if_id},
            {"stage": "ID", "data": self.pipeline.id_ex},
            {"stage": "EX", "data": self.pipeline.ex_mem},
            {"stage": "MEM", "data": self.pipeline.mem_wb},
            {"stage": "WB", "data": self.pipeline.writeback_stage}
        ]

        for i, etapa in enumerate(etapas):
            stage_data = etapa["data"]

            if stage_data is None:
                # Si no hay datos en la etapa, limpiar la etiqueta
                self.instruccion_labels[i].config(text=" ")
            else:
                # Mostrar siempre la instrucción, incluso si es NOP
                instruction = stage_data.get("instruction_pipeline", "")
                self.instruccion_labels[i].config(text=instruction)

                if instruction != "NOP":
                    # Pintar los módulos correspondientes según la etapa si no es un NOP
                    stage = etapa["stage"]
                    if stage == "IF":
                        self.canvas.itemconfig(self.rectangles["PC"], fill="lightblue")
                        self.canvas.itemconfig(self.rectangles["InstrMemory"], fill="lightblue")
                        self.canvas.itemconfig(self.rectangles["IF/ID"], fill="lightblue")
                    elif stage == "ID":
                        self.canvas.itemconfig(self.rectangles["RegisterFile"], fill="lightgreen")
                        self.canvas.itemconfig(self.rectangles["Imm"], fill="lightgreen")
                        self.canvas.itemconfig(self.rectangles["ID/EX"], fill="lightgreen")
                    elif stage == "EX":
                        # Pintar toda la etapa EX de rojo
                        self.canvas.itemconfig(self.rectangles["ALU"], fill="red")
                        self.canvas.itemconfig(self.rectangles["Mux2"], fill="red")
                        self.canvas.itemconfig(self.rectangles["Mux3"], fill="red")
                        self.canvas.itemconfig(self.rectangles["Mux4"], fill="red")
                        self.canvas.itemconfig(self.rectangles["Mux5"], fill="red")
                        self.canvas.itemconfig(self.rectangles["EX/MEM"], fill="red")
                    elif stage == "MEM":
                        self.canvas.itemconfig(self.rectangles["DataMemory"], fill="orange")
                        self.canvas.itemconfig(self.rectangles["MEM/WB"], fill="orange")
                    elif stage == "WB":
                        self.canvas.itemconfig(self.rectangles["Mux6"], fill="pink")

        # Resetear writeback_stage si el pipeline está vacío
        if self.pipeline.is_pipeline_empty():
            self.root.after(600, self.reset_writeback_stage)

    def reset_writeback_stage(self):
        """Restablece writeback_stage y actualiza la interfaz."""
        self.pipeline.writeback_stage = None
        self.instruccion_labels[-1].config(text=" ")  # Limpia la última etiqueta WB en la interfaz

    def volver_a_configuracion(self):
        """Vuelve a la ventana de configuracion y reinicia el pipeline"""
        self.pipeline.reiniciar()
        self.root.withdraw()
        self.ventana_configuracion.deiconify()