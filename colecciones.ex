# Integrantes: Sergio, Cristian y Mafe
# Responsable principal: Cristian
# Relacion: Parte A.1 - Colecciones
#
# OBJETIVO:
# Crear estructuras auxiliares para buscar repartidores por codigo
# y zonas por id.
#
# IMPORTANTE:
# Datos.repartidores() y Datos.zonas() siguen siendo listas.
# Estas funciones crean mapas auxiliares; no reemplazan los datos
# originales porque los mapas no garantizan conservar el orden.

defmodule Colecciones do

  @moduledoc """
  Funciones puras para preparar colecciones auxiliares.
  """

  def repartidores_por_codigo(repartidores) do
    Enum.reduce(repartidores, %{}, fn repartidor, mapa_repartidores ->
      Map.put(mapa_repartidores, repartidor.codigo, repartidor)
    end)
  end

  def zonas_por_id(zonas) do
    Enum.reduce(zonas, %{}, fn zona, mapa_zonas ->
      Map.put(mapa_zonas, zona.id, zona)
    end)
  end

end