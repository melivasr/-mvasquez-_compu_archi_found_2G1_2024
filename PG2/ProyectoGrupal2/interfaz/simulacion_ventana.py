import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import os

class SimulacionVentana:
    def __init__(self, root, ventana_configuracion):
        self.root = root
        self.ventana_configuracion = ventana_configuracion
        self.root.title("Simulación de Pipeline")
        self.root.state('zoomed')
        self.root.configure(bg="#61C6E8")

        # Frame para el pipeline visual y el área de control con borde
        frame_pipeline = tk.Frame(self.root, bg="#61C6E8", highlightbackground="black", highlightthickness=0)
        frame_pipeline.pack(side=tk.LEFT, padx=10, pady=20)

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

        # Campos de ciclo, tiempo y PC
        tk.Label(frame_datos, text="Ciclo de ejecución:", bg="#61C6E8").grid(row=0, column=0, sticky="e")
        self.entry_ciclo = tk.Entry(frame_datos, width=10)
        self.entry_ciclo.grid(row=0, column=1, padx=5, pady=5)

        tk.Label(frame_datos, text="Tiempo:", bg="#61C6E8").grid(row=1, column=0, sticky="e")
        self.entry_tiempo = tk.Entry(frame_datos, width=10)
        self.entry_tiempo.grid(row=1, column=1, padx=5, pady=5)

        tk.Label(frame_datos, text="Valor PC:", bg="#61C6E8").grid(row=2, column=0, sticky="e")
        self.entry_pc = tk.Entry(frame_datos, width=10)
        self.entry_pc.grid(row=2, column=1, padx=5, pady=5)

        # Tabla de registros
        tk.Label(frame_datos, text="Valor registros:", bg="#61C6E8").grid(row=3, column=0, sticky="w", columnspan=2)
        self.tree_registros = ttk.Treeview(frame_datos, columns=("Name", "Alias", "Value"), show="headings", height=5)
        self.tree_registros.heading("Name", text="Name")
        self.tree_registros.heading("Alias", text="Alias")
        self.tree_registros.heading("Value", text="Value")
        self.tree_registros.column("Name", width=50)
        self.tree_registros.column("Alias", width=50)
        self.tree_registros.column("Value", width=50)
        self.tree_registros.grid(row=4, column=0, columnspan=2, pady=5)

        # Tabla de memoria de datos
        tk.Label(frame_datos, text="Memoria de datos:", bg="#61C6E8").grid(row=5, column=0, sticky="w", columnspan=2)
        self.tree_memoria = ttk.Treeview(frame_datos, columns=("Addr", "Stage", "Instruction"), show="headings", height=5)
        self.tree_memoria.heading("Addr", text="Addr")
        self.tree_memoria.heading("Stage", text="Stage")
        self.tree_memoria.heading("Instruction", text="Instruction")
        self.tree_memoria.column("Addr", width=50)
        self.tree_memoria.column("Stage", width=50)
        self.tree_memoria.column("Instruction", width=80)
        self.tree_memoria.grid(row=6, column=0, columnspan=2, pady=5)

        # Botones redondeados
        self.create_rounded_button(self.root, "Ejecutar", self.cambiar_color_pipeline, x=760, y=500, width=100, height=40)
        self.create_rounded_button(self.root, "Volver a configuración", self.volver_a_configuracion, x=600, y=500, width=150, height=40)

    def create_rounded_button(self, parent, text, command, x, y, width, height):
        canvas = tk.Canvas(parent, width=width, height=height, bg="#61C6E8", highlightthickness=0)
        canvas.place(x=x, y=y)
        radius = height // 2
        canvas.create_oval(0, 0, height, height, fill="#005F6A", outline="")
        canvas.create_oval(width - height, 0, width, height, fill="#005F6A", outline="")
        canvas.create_rectangle(radius, 0, width - radius, height, fill="#005F6A", outline="")
        canvas.create_text(width // 2, height // 2, text=text, fill="white", font=("Arial", 10, "bold"))
        canvas.bind("<Button-1>", lambda event: command())

    def cambiar_color_pipeline(self):
        for component in self.rectangles.values():
            self.canvas.itemconfig(component, fill="lightblue")

    def volver_a_configuracion(self):
        self.root.withdraw()
        self.ventana_configuracion.deiconify()


