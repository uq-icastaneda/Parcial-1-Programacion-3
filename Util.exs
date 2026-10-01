# Sergio Armero
# Maria Fernanda Mejia
# Cristian Castañeda
# ==== PARCIAL 1 PROGRAMACION 3 ====
defmodule Util do

  def leer_mensaje(mensaje, :string) do
    String.trim(IO.gets(mensaje));
  end

  def imprimir_mensaje(mensaje) do
    IO.puts(mensaje);
  end

end
