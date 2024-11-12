import tkinter as tk
from tkinter import ttk

class SimulacionVentana:
    def __init__(self, root, ventana_configuracion):
        self.root = root
        self.ventana_configuracion = ventana_configuracion
        self.root.title("Simulación de Pipeline")
        self.root.state('zoomed')  # Maximiza la ventana al iniciar
        self.root.configure(bg="#61C6E8")  # Fondo en #61C6E8

        # Frame para el pipeline visual y el área de control
        frame_pipeline = tk.Frame(self.root, bg="#61C6E8")
        frame_pipeline.pack(side=tk.LEFT, padx=20, pady=20)

        # Crear el canvas para el pipeline
        self.canvas = tk.Canvas(frame_pipeline, width=600, height=300, bg="#61C6E8", highlightthickness=0)
        self.canvas.pack()

        # Dibujar las etapas del pipeline (IF, ID, EX, MEM, WB)
        self.stages = {
            "IF": self.canvas.create_rectangle(10, 50, 100, 150, fill="white", outline="black"),
            "ID": self.canvas.create_rectangle(120, 50, 210, 150, fill="white", outline="black"),
            "EX": self.canvas.create_rectangle(230, 50, 320, 150, fill="white", outline="black"),
            "MEM": self.canvas.create_rectangle(340, 50, 430, 150, fill="white", outline="black"),
            "WB": self.canvas.create_rectangle(450, 50, 540, 150, fill="white", outline="black")
        }

        # Etiquetas para cada etapa
        self.canvas.create_text(55, 170, text="IF")
        self.canvas.create_text(165, 170, text="ID")
        self.canvas.create_text(275, 170, text="EX")
        self.canvas.create_text(385, 170, text="MEM")
        self.canvas.create_text(495, 170, text="WB")

        # Líneas de conexión entre las etapas
        self.canvas.create_line(100, 100, 120, 100, arrow=tk.LAST)
        self.canvas.create_line(210, 100, 230, 100, arrow=tk.LAST)
        self.canvas.create_line(320, 100, 340, 100, arrow=tk.LAST)
        self.canvas.create_line(430, 100, 450, 100, arrow=tk.LAST)

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

        # Botones redondeados para "Ejecutar" y "Volver a configuración"
        self.create_rounded_button(self.root, "Ejecutar", self.cambiar_color_pipeline, x=760, y=500, width=100, height=40)
        self.create_rounded_button(self.root, "Volver a configuración", self.volver_a_configuracion, x=600, y=500, width=150, height=40)

    def create_rounded_button(self, parent, text, command, x, y, width, height):
        # Crear botón redondeado en Canvas
        canvas = tk.Canvas(parent, width=width, height=height, bg="#61C6E8", highlightthickness=0)
        canvas.place(x=x, y=y)

        # Fondo del botón redondeado
        radius = height // 2
        canvas.create_oval(0, 0, height, height, fill="#005F6A", outline="")
        canvas.create_oval(width-height, 0, width, height, fill="#005F6A", outline="")
        canvas.create_rectangle(radius, 0, width-radius, height, fill="#005F6A", outline="")

        # Texto del botón
        canvas.create_text(width // 2, height // 2, text=text, fill="white", font=("Arial", 10, "bold"))

        # Hacer que el botón sea interactivo
        canvas.bind("<Button-1>", lambda event: command())

    def cambiar_color_pipeline(self):
        # Ejemplo de cambio de color de cada etapa del pipeline
        self.canvas.itemconfig(self.stages["IF"], fill="lightblue")
        self.canvas.itemconfig(self.stages["ID"], fill="lightgreen")
        self.canvas.itemconfig(self.stages["EX"], fill="lightyellow")
        self.canvas.itemconfig(self.stages["MEM"], fill="lightpink")
        self.canvas.itemconfig(self.stages["WB"], fill="lightgrey")

    def volver_a_configuracion(self):
        self.root.withdraw()
        self.ventana_configuracion.deiconify()
