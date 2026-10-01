# Sergio Armero
# Maria Fernanda Mejia
# Cristian Castañeda
# ==== PARCIAL 1 PROGRAMACION 3 ====
defmodule Colecciones do

  def repartidores_por_codigo(repartidores) do
    Enum.reduce(repartidores, %{}, fn repartidor, mapa_repartidores ->

      Map.put(mapa_repartidores, repartidor.codigo, repartidor);

    end);
  end

  def zonas_por_id(zonas) do
    Enum.reduce(zonas, %{}, fn zona, mapa_zonas ->

      Map.put(mapa_zonas, zona.id, zona);

    end);
  end
end
