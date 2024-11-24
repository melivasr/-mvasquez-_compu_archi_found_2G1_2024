import tkinter as tk
from tkinter import ttk

class HistorialVentana:
    def __init__(self, root, ventana_configuracion):
        self.root = root
        self.ventana_configuracion = ventana_configuracion
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
            "# ejecución", "1° Versión", "Cycles", "Tiempo", "CPI", "IPC",
            "2° Versión", "Cycles 2", "Tiempo 2", "CPI 2", "IPC 2"
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

        # Rellenar tabla con datos vacíos
        self.rellenar_tabla_vacia()

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

    def rellenar_tabla_vacia(self):
        """Rellena la tabla con filas vacías (20 filas como ejemplo)."""
        for i in range(1, 21):  # 20 filas
            self.tree_historial.insert("", "end", values=(
                i, "", "", "", "", "", "", "", "", "", ""
            ))
