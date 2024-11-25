import json
import tkinter as tk
from tkinter import ttk

class HistorialVentana:
    def __init__(self, root, ventana_configuracion, historial_file="historial.json"):
        self.root = root
        self.ventana_configuracion = ventana_configuracion
        self.historial_file = historial_file  # Archivo JSON de historial
        self.root.title("Historial de Ejecuciones")
        self.root.state('zoomed')
        self.root.configure(bg="#61C6E8")

        # Configuración de estilos
        style = ttk.Style(self.root)
        style.theme_use("default")
        style.configure("Treeview", background="white", rowheight=22, fieldbackground="white")
        style.configure("Treeview.Heading", font=("Comic Sans MS", 10), background="#D3D3D3",
                        foreground="black")  # Títulos gris claro
        style.map("Treeview.Heading", background=[("active", "#B0B0B0")])

        # Frame principal
        frame_historial = tk.Frame(self.root, bg="#61C6E8", highlightbackground="black", highlightthickness=0)
        frame_historial.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)

        # Etiqueta de título
        tk.Label(frame_historial, text="Historial de Ejecuciones", bg="#61C6E8", font=("Comic Sans MS", 12, "bold"), fg="#003333").pack(pady=10)

        # Tabla de historial
        columnas = [
            "# ejecución", "1 Version", "Cycles", "Tiempo", "CPI", "IPC",
            "2 Version", "Cycles 2", "Tiempo 2", "CPI 2", "IPC 2"
        ]
        self.tree_historial = ttk.Treeview(frame_historial, columns=columnas, show="headings", height=20)

        # Configurar encabezados y ajustar columnas
        for col in columnas:
            self.tree_historial.heading(col, text=col)  # Configurar encabezado con texto claro
            self.tree_historial.column(col, width=100, anchor="center", stretch=True)

        # Empaquetar la tabla
        self.tree_historial.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # Botón para volver a la ventana de configuración
        boton_frame = tk.Frame(frame_historial, bg="#61C6E8")  # Frame para centrar el botón
        boton_frame.pack(pady=20)  # Separación inferior
        self.create_rounded_button(boton_frame, "Volver a configuración", self.volver_a_configuracion, width=200, height=40)

        # Rellenar tabla con datos del historial
        self.rellenar_tabla_con_historial()

    def create_rounded_button(self, parent, text, command, width, height, font=("Comic Sans MS", 10, "bold")):
        # Crear botón redondeado en Canvas
        canvas = tk.Canvas(parent, width=width, height=height, bg="#61C6E8", highlightthickness=0)
        canvas.pack()  # Centramos dentro del frame del botón

        # Fondo del botón redondeado
        radius = height // 2
        canvas.create_oval(0, 0, height, height, fill="#00A9C0", outline="")
        canvas.create_oval(width - height, 0, width, height, fill="#00A9C0", outline="")
        canvas.create_rectangle(radius, 0, width - radius, height, fill="#00A9C0", outline="")

        # Texto del botón con fuente personalizada
        canvas.create_text(width // 2, height // 2, text=text, fill="white", font=font)

        # Hacer que el botón sea interactivo
        canvas.bind("<Button-1>", lambda event: command())

    def volver_a_configuracion(self):
        """Vuelve a la ventana de configuración."""
        self.root.withdraw()
        self.ventana_configuracion.deiconify()

    def rellenar_tabla_con_historial(self):
        """Llena la tabla con los datos del archivo historial.json, agrupando versiones 1 y 2 en la misma fila."""
        try:
            with open(self.historial_file, "r") as file:
                historial = json.load(file)  # Cargar datos del archivo JSON

            # Limpiar la tabla antes de insertar nuevos datos
            for item in self.tree_historial.get_children():
                self.tree_historial.delete(item)

            # Procesar las entradas en pares (1º Versión y 2º Versión)
            for i in range(0, len(historial), 2):  # Itera en pasos de 2
                entrada1 = historial[i]  # Datos de la versión 1
                entrada2 = historial[i + 1] if i + 1 < len(historial) else {}  # Datos de la versión 2 (si existe)

                self.tree_historial.insert("", "end", values=(
                    (i // 2) + 1,  # Número de ejecución (basado en pares)
                    entrada1.get("1 Version", ""),  # 1 Versión
                    entrada1.get("Cycles", ""),  # Cycles
                    entrada1.get("Tiempo", ""),  # Tiempo
                    entrada1.get("CPI", ""),  # CPI
                    entrada1.get("IPC", ""),  # IPC
                    entrada2.get("2 Version", ""),  # 2 Versión
                    entrada2.get("Cycles 2", ""),  # Cycles 2
                    entrada2.get("Tiempo 2", ""),  # Tiempo 2
                    entrada2.get("CPI 2", ""),  # CPI 2
                    entrada2.get("IPC 2", "")  # IPC 2
                ))
        except FileNotFoundError:
            print(f"Error: No se encontró el archivo {self.historial_file}.")
        except json.JSONDecodeError:
            print(f"Error: El archivo {self.historial_file} no contiene un JSON válido.")
