import tkinter as tk
from tkinter import ttk, messagebox
from interfaz.simulacion_ventana import SimulacionVentana
from interfaz.historial_ventana import HistorialVentana

class ConfiguracionVentana:
    def __init__(self, root, pipeline):
        self.root = root
        self.root.title("Configuración de Simulación")
        self.root.geometry("700x450")
        self.root.configure(bg="#61C6E8")  # Fondo en #61C6E8
        self.pipeline = pipeline

        # Frame centralizado que contendrá todos los elementos
        self.frame_central = tk.Frame(self.root, bg="#61C6E8")
        self.frame_central.pack(fill='both', expand=True)

        # Título y opciones de resolución de riesgos
        label_riesgos = tk.Label(self.frame_central, text="Seleccione resolución de riesgos:", bg="#61C6E8", font=("Comic Sans MS", 10,"bold"), fg="#003333")
        label_riesgos.pack(pady=10)

        # Opciones de resolución de riesgos
        self.riesgos_map = {
            "Sin unidad de riesgos": "no_hazard",
            "Con unidad de riesgos": "hazard_unit",
            "Con predicción de saltos": "branch_prediction",
            "Con unidad de riesgos con predicción de saltos": "full_hazard",
        }
        opciones_riesgos = list(self.riesgos_map.keys())

        # Combobox para la primera y segunda versión
        label_version1 = tk.Label(self.frame_central, text="1° Versión:", font=("Comic Sans MS", 10), bg="#61C6E8", fg="#003333")
        label_version1.pack(pady=5)
        self.combo_version1 = ttk.Combobox(self.frame_central, values=list(self.riesgos_map.keys()), state="readonly", font=("Comic Sans MS", 9))
        self.combo_version1.pack(pady=5)

        label_version2 = tk.Label(self.frame_central, text="2° Versión:", font=("Comic Sans MS", 10), bg="#61C6E8", fg="#003333")
        label_version2.pack(pady=5)
        self.combo_version2 = ttk.Combobox(self.frame_central, values=list(self.riesgos_map.keys()), state="readonly", font=("Comic Sans MS", 9))
        self.combo_version2.pack(pady=5)

        # Opciones de funcionamiento
        label_funcionamiento = tk.Label(self.frame_central, text="Seleccione modo de funcionamiento:", font=("Comic Sans MS", 10, "bold"), bg="#61C6E8", fg="#003333")
        label_funcionamiento.pack(pady=10)

        opciones_funcionamiento = [
            "Step by step",
            "Un ciclo cada unidad de tiempo",
            "Ejecución completa al final"
        ]
        self.combo_funcionamiento = ttk.Combobox(self.frame_central, values=opciones_funcionamiento, state="readonly", font=("Comic Sans MS", 9))
        self.combo_funcionamiento.pack(pady=5)

        # Botón redondeado para continuar
        self.create_rounded_button(self.frame_central, "Continuar", self.abrir_ventana_simulacion, width=100, height=40)

        # Botón redondeado para abrir el historial
        self.create_rounded_button(self.frame_central, "Historial de Ejecuciones", self.abrir_ventana_historial, width=200, height=40)

    def abrir_ventana_historial(self):
        """Abre la ventana de historial de ejecuciones."""
        self.root.withdraw()  # Ocultar la ventana actual
        ventana_historial = tk.Toplevel(self.root)
        HistorialVentana(ventana_historial, self.root)

    def abrir_ventana_simulacion(self):
        # Validar que las opciones estén seleccionadas
        if not self.combo_version1.get() or not self.combo_version2.get() or not self.combo_funcionamiento.get():
            messagebox.showerror("Error", "Debe seleccionar todas las opciones antes de continuar.")
            return

        # Configurar la versión 1
        modo_riesgos_version1 = self.riesgos_map[self.combo_version1.get()]
        self.pipeline.set_mode(modo_riesgos_version1)

        # Configurar la versión 2
        modo_riesgos_version1 = self.riesgos_map[self.combo_version2.get()]
        self.pipeline.set_mode(modo_riesgos_version1)

        # Obtener el modo de funcionamiento
        modo_funcionamiento = self.combo_funcionamiento.get()

        # Ocultar la ventana de configuración y abrir la ventana de simulación
        self.root.withdraw()
        ventana_simulacion = tk.Toplevel(self.root)
        SimulacionVentana(ventana_simulacion, self.root, self.pipeline, modo_funcionamiento)

    def create_rounded_button(self, parent, text, command, width, height, font=("Comic Sans MS", 10, "bold")):
        # Crear botón redondeado en Canvas
        canvas = tk.Canvas(parent, width=width, height=height, bg="#61C6E8", highlightthickness=0)
        canvas.pack(pady=20)  # Asegurar que el botón esté centrado dentro del frame

        # Fondo del botón redondeado
        radius = height // 2
        canvas.create_oval(0, 0, height, height, fill="#00A9C0", outline="")
        canvas.create_oval(width-height, 0, width, height, fill="#00A9C0", outline="")
        canvas.create_rectangle(radius, 0, width-radius, height, fill="#00A9C0", outline="")

        # Texto del botón
        canvas.create_text(width // 2, height // 2, text=text, fill="white", font=font)

        # Hacer que el botón sea interactivo
        canvas.bind("<Button-1>", lambda event: command())
