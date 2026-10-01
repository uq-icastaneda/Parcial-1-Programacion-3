# Sergio Armero
# Maria Fernanda Mejia
# Cristian Castañeda
# ==== PARCIAL 1 PROGRAMACION 3 ====
defmodule Datos do

  def repartidores do
    [
      %{codigo: "M01", nombre: "Ana Torres", bicicleta: true},
      %{codigo: "M02", nombre: "Luis Garcia", bicicleta: false},
      %{codigo: "M03", nombre: "Carlos Ruiz", bicicleta: true},
      %{codigo: "M04", nombre: "Maria Lopez", bicicleta: true},
      %{codigo: "M05", nombre: "Pedro Martinez", bicicleta: false},
      %{codigo: "M06", nombre: "Sofia Hernandez", bicicleta: true},
      %{codigo: "M07", nombre: "Diego Diaz", bicicleta: false},
      %{codigo: "M08", nombre: "Laura Perez", bicicleta: false},
      %{codigo: "M09", nombre: "Jorge Sanchez", bicicleta: false},
      %{codigo: "M10", nombre: "Elena Ramirez", bicicleta: false}
    ]
  end


  def zonas do
    [
      %{id: "Z1", nombre: "Centro", area: 6.5},
      %{id: "Z2", nombre: "Norte", area: 8.2},
      %{id: "Z3", nombre: "Sur", area: 5.0},
      %{id: "Z4", nombre: "Oriente", area: 7.3}
    ]
  end


  def servicios do
    [
      # ---- M01 (8 servicios) ----
      %{repartidor: "M01", zona: "Z1", dia: 1, kilometros: 20, retraso: 5},
      %{repartidor: "M01", zona: "Z2", dia: 1, kilometros: 25, retraso: 0},
      %{repartidor: "M01", zona: "Z1", dia: 2, kilometros: 18, retraso: -3},
      %{repartidor: "M01", zona: "Z3", dia: 2, kilometros: 22, retraso: 40},
      %{repartidor: "M01", zona: "Z2", dia: 3, kilometros: 30, retraso: 12},
      %{repartidor: "M01", zona: "Z4", dia: 4, kilometros: 15, retraso: 8},
      %{repartidor: "M01", zona: "Z1", dia: 5, kilometros: 24, retraso: 25},
      %{repartidor: "M01", zona: "Z3", dia: 6, kilometros: 28, retraso: -10},

      # ---- M02 (8 servicios) ----
      %{repartidor: "M02", zona: "Z2", dia: 1, kilometros: 45, retraso: 3},
      %{repartidor: "M02", zona: "Z3", dia: 1, kilometros: 15, retraso: 60},
      %{repartidor: "M02", zona: "Z4", dia: 2, kilometros: 28, retraso: 10},
      %{repartidor: "M02", zona: "Z1", dia: 3, kilometros: 40, retraso: 0},
      %{repartidor: "M02", zona: "Z2", dia: 3, kilometros: 12, retraso: 95},
      %{repartidor: "M02", zona: "Z3", dia: 4, kilometros: 33, retraso: 18},
      %{repartidor: "M02", zona: "Z4", dia: 5, kilometros: 20, retraso: -5},
      %{repartidor: "M02", zona: "Z1", dia: 6, kilometros: 26, retraso: 45},

      # ---- M03 (8 servicios) ----
      %{repartidor: "M03", zona: "Z4", dia: 1, kilometros: 40, retraso: 8},
      %{repartidor: "M03", zona: "Z1", dia: 2, kilometros: 45, retraso: 5},
      %{repartidor: "M03", zona: "Z2", dia: 2, kilometros: 20, retraso: 30},
      %{repartidor: "M03", zona: "Z3", dia: 3, kilometros: 38, retraso: 0},
      %{repartidor: "M03", zona: "Z4", dia: 3, kilometros: 15, retraso: -12},
      %{repartidor: "M03", zona: "Z1", dia: 4, kilometros: 27, retraso: 20},
      %{repartidor: "M03", zona: "Z2", dia: 5, kilometros: 32, retraso: 65},
      %{repartidor: "M03", zona: "Z3", dia: 6, kilometros: 19, retraso: 7},

      # ---- M04 (8 servicios) ----
      # Dia 1: 45 + 45 = 90 km -> supera los 80 km de bonificacion.
      %{repartidor: "M04", zona: "Z1", dia: 1, kilometros: 45, retraso: 2},
      %{repartidor: "M04", zona: "Z2", dia: 1, kilometros: 45, retraso: 2},
      %{repartidor: "M04", zona: "Z3", dia: 2, kilometros: 30, retraso: 15},
      %{repartidor: "M04", zona: "Z4", dia: 3, kilometros: 25, retraso: 35},
      %{repartidor: "M04", zona: "Z1", dia: 3, kilometros: 20, retraso: 50},
      %{repartidor: "M04", zona: "Z2", dia: 4, kilometros: 38, retraso: -6},
      %{repartidor: "M04", zona: "Z3", dia: 5, kilometros: 22, retraso: 80},
      %{repartidor: "M04", zona: "Z4", dia: 6, kilometros: 29, retraso: 0},

      # ---- M05 (8 servicios) ----
      %{repartidor: "M05", zona: "Z2", dia: 1, kilometros: 42, retraso: 4},
      %{repartidor: "M05", zona: "Z4", dia: 2, kilometros: 33, retraso: 9},
      %{repartidor: "M05", zona: "Z1", dia: 2, kilometros: 25, retraso: 25},
      %{repartidor: "M05", zona: "Z2", dia: 3, kilometros: 40, retraso: -2},
      %{repartidor: "M05", zona: "Z3", dia: 4, kilometros: 18, retraso: 100},
      %{repartidor: "M05", zona: "Z4", dia: 4, kilometros: 24, retraso: 70},
      %{repartidor: "M05", zona: "Z1", dia: 5, kilometros: 35, retraso: 15},
      %{repartidor: "M05", zona: "Z2", dia: 6, kilometros: 16, retraso: 0},

      # ---- M06 (8 servicios) ----
      %{repartidor: "M06", zona: "Z3", dia: 1, kilometros: 45, retraso: 6},
      %{repartidor: "M06", zona: "Z4", dia: 1, kilometros: 20, retraso: 11},
      %{repartidor: "M06", zona: "Z2", dia: 2, kilometros: 36, retraso: 0},
      %{repartidor: "M06", zona: "Z1", dia: 3, kilometros: 42, retraso: -8},
      %{repartidor: "M06", zona: "Z3", dia: 3, kilometros: 18, retraso: 55},
      %{repartidor: "M06", zona: "Z4", dia: 4, kilometros: 31, retraso: 25},
      %{repartidor: "M06", zona: "Z2", dia: 5, kilometros: 27, retraso: 90},
      %{repartidor: "M06", zona: "Z1", dia: 6, kilometros: 23, retraso: 3},

      # ---- M07 (8 servicios) ----
      %{repartidor: "M07", zona: "Z1", dia: 1, kilometros: 35, retraso: 14},
      %{repartidor: "M07", zona: "Z3", dia: 2, kilometros: 44, retraso: 7},
      %{repartidor: "M07", zona: "Z2", dia: 2, kilometros: 21, retraso: 38},
      %{repartidor: "M07", zona: "Z4", dia: 3, kilometros: 33, retraso: -4},
      %{repartidor: "M07", zona: "Z1", dia: 3, kilometros: 26, retraso: 20},
      %{repartidor: "M07", zona: "Z3", dia: 4, kilometros: 15, retraso: 120},
      %{repartidor: "M07", zona: "Z4", dia: 5, kilometros: 30, retraso: 30},
      %{repartidor: "M07", zona: "Z2", dia: 6, kilometros: 34, retraso: -15},

      # ---- M08 (8 servicios) ----
      %{repartidor: "M08", zona: "Z2", dia: 1, kilometros: 40, retraso: 1},
      %{repartidor: "M08", zona: "Z3", dia: 1, kilometros: 25, retraso: 48},
      %{repartidor: "M08", zona: "Z4", dia: 2, kilometros: 29, retraso: -9},
      %{repartidor: "M08", zona: "Z2", dia: 3, kilometros: 37, retraso: 22},
      %{repartidor: "M08", zona: "Z1", dia: 4, kilometros: 20, retraso: 35},
      %{repartidor: "M08", zona: "Z3", dia: 4, kilometros: 28, retraso: 65},
      %{repartidor: "M08", zona: "Z4", dia: 5, kilometros: 17, retraso: 5},
      %{repartidor: "M08", zona: "Z1", dia: 6, kilometros: 32, retraso: -20},

      # ---- M09 (8 servicios) ----
      %{repartidor: "M09", zona: "Z4", dia: 1, kilometros: 40, retraso: 9},
      %{repartidor: "M09", zona: "Z1", dia: 2, kilometros: 30, retraso: 16},
      %{repartidor: "M09", zona: "Z3", dia: 2, kilometros: 25, retraso: -11},
      %{repartidor: "M09", zona: "Z2", dia: 3, kilometros: 41, retraso: 0},
      %{repartidor: "M09", zona: "Z4", dia: 4, kilometros: 18, retraso: 70},
      %{repartidor: "M09", zona: "Z1", dia: 4, kilometros: 33, retraso: 30},
      %{repartidor: "M09", zona: "Z3", dia: 5, kilometros: 26, retraso: 50},
      %{repartidor: "M09", zona: "Z2", dia: 6, kilometros: 20, retraso: 0},

      # ---- M10 (8 servicios) ----
      %{repartidor: "M10", zona: "Z3", dia: 1, kilometros: 45, retraso: 3},
      %{repartidor: "M10", zona: "Z2", dia: 2, kilometros: 24, retraso: 27},
      %{repartidor: "M10", zona: "Z4", dia: 2, kilometros: 36, retraso: -5},
      %{repartidor: "M10", zona: "Z1", dia: 3, kilometros: 30, retraso: 12},
      %{repartidor: "M10", zona: "Z4", dia: 3, kilometros: 28, retraso: 40},
      %{repartidor: "M10", zona: "Z2", dia: 4, kilometros: 22, retraso: 85},
      %{repartidor: "M10", zona: "Z1", dia: 5, kilometros: 35, retraso: 18},
      %{repartidor: "M10", zona: "Z3", dia: 6, kilometros: 19, retraso: -6},

      # --- :repartidor_desconocido (2) ---
      %{repartidor: "M99", zona: "Z1", dia: 1, kilometros: 20, retraso: 3},
      %{repartidor: "MX1", zona: "Z2", dia: 2, kilometros: 15.5, retraso: -4},

      # --- :zona_desconocida (2) ---
      %{repartidor: "M01", zona: "Z9", dia: 1, kilometros: 20, retraso: 3},
      %{repartidor: "M02", zona: "ZX", dia: 3, kilometros: 30, retraso: 8},

      # --- :dia_invalido (2) ---
      %{repartidor: "M03", zona: "Z1", dia: 0, kilometros: 25, retraso: 5},
      %{repartidor: "M04", zona: "Z2", dia: 7, kilometros: 18, retraso: 5},

      # --- :kilometros_fuera_de_rango (2) ---
      %{repartidor: "M05", zona: "Z3", dia: 2, kilometros: 60, retraso: 5},
      %{repartidor: "M06", zona: "Z4", dia: 4, kilometros: 0, retraso: 5},

      # --- :retraso_invalido (2) ---
      %{repartidor: "M07", zona: "Z1", dia: 3, kilometros: 30, retraso: 250},
      %{repartidor: "M08", zona: "Z2", dia: 5, kilometros: 22, retraso: -45}
    ]
  end

end
