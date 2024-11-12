import tkinter as tk
from tkinter import ttk
from interfaz.simulacion_ventana import SimulacionVentana

class ConfiguracionVentana:
    def __init__(self, root):
        self.root = root
        self.root.title("Configuración de Simulación")
        self.root.geometry("600x400")
        self.root.configure(bg="#61C6E8")  # Fondo en #61C6E8

        # Frame centralizado que contendrá todos los elementos
        self.frame_central = tk.Frame(self.root, bg="#61C6E8")
        self.frame_central.pack(fill='both', expand=True)

        # Título y opciones de resolución de riesgos
        label_riesgos = tk.Label(self.frame_central, text="Seleccione resolución de riesgos:", bg="#61C6E8", font=("Arial", 11))
        label_riesgos.pack(pady=10)

        # Opciones de riesgo
        opciones_riesgos = [
            "Sin unidad de riesgos",
            "Con unidad de riesgos",
            "Con predicción de saltos",
            "Con unidad de riesgos con predicción de saltos"
        ]

        # Combobox para la primera y segunda versión
        label_version1 = tk.Label(self.frame_central, text="1° Versión:", bg="#61C6E8", font=("Arial", 11))
        label_version1.pack(pady=5)
        self.combo_version1 = ttk.Combobox(self.frame_central, values=opciones_riesgos, state="readonly", font=("Arial", 10))
        self.combo_version1.pack(pady=5)

        label_version2 = tk.Label(self.frame_central, text="2° Versión:", bg="#61C6E8", font=("Arial", 11))
        label_version2.pack(pady=5)
        self.combo_version2 = ttk.Combobox(self.frame_central, values=opciones_riesgos, state="readonly", font=("Arial", 10))
        self.combo_version2.pack(pady=5)

        # Opciones de funcionamiento
        label_funcionamiento = tk.Label(self.frame_central, text="Seleccione modo de funcionamiento:", bg="#61C6E8", font=("Arial", 11))
        label_funcionamiento.pack(pady=10)

        opciones_funcionamiento = [
            "Step by step",
            "Un ciclo cada unidad de tiempo",
            "Ejecución completa al final"
        ]
        self.combo_funcionamiento = ttk.Combobox(self.frame_central, values=opciones_funcionamiento, state="readonly", font=("Arial", 10))
        self.combo_funcionamiento.pack(pady=5)

        # Botón redondeado para continuar
        self.create_rounded_button(self.frame_central, "Continuar", self.abrir_ventana_simulacion, width=100, height=40)

    def abrir_ventana_simulacion(self):
        # Oculta la ventana de configuración y abre la ventana de simulación
        self.root.withdraw()
        ventana_simulacion = tk.Toplevel(self.root)
        SimulacionVentana(ventana_simulacion, self.root)

    def create_rounded_button(self, parent, text, command, width, height):
        # Crear botón redondeado en Canvas
        canvas = tk.Canvas(parent, width=width, height=height, bg="#61C6E8", highlightthickness=0)
        canvas.pack(pady=20)  # Asegurar que el botón esté centrado dentro del frame

        # Fondo del botón redondeado
        radius = height // 2
        canvas.create_oval(0, 0, height, height, fill="#00A9C0", outline="")
        canvas.create_oval(width-height, 0, width, height, fill="#00A9C0", outline="")
        canvas.create_rectangle(radius, 0, width-radius, height, fill="#00A9C0", outline="")

        # Texto del botón
        canvas.create_text(width // 2, height // 2, text=text, fill="white", font=("Arial", 10, "bold"))

        # Hacer que el botón sea interactivo
        canvas.bind("<Button-1>", lambda event: command())
