defmodule Validacion do

  @dias_operacion 6
  @maximo_kilometros 45
  @minimo_retraso -30
  @maximo_retraso 180

  def validar_servicio(servicio, repartidores_por_codigo, zonas_por_id) do

    with {:ok, servicio} <- validar_repartidor(servicio, repartidores_por_codigo),
         {:ok, servicio} <- validar_zona(servicio, zonas_por_id),
         {:ok, servicio} <- validar_dia(servicio),
         {:ok, servicio} <- validar_kilometros(servicio),
         {:ok, servicio} <- validar_retraso(servicio) do

      {:ok, servicio}
    end
  end

  def separar_servicios(servicios, repartidores_por_codigo, zonas_por_id) do
    Enum.reduce(servicios, {[], []}, fn servicio, {validos, rechazados} ->
      case validar_servicio(servicio, repartidores_por_codigo, zonas_por_id) do
        {:ok, servicio_valido} ->
          {validos ++ [servicio_valido], rechazados}

        {:error, motivo} ->
          {validos, rechazados ++ [{servicio, motivo}]}
      end
    end)
  end

  def convertir_linea_servicio(linea) do

    campos =
      linea
      |> String.split(";")
      |> Enum.map(fn campo -> String.trim(campo) end)

    case campos do
      [repartidor, zona, dia_texto, kilometros_texto, retraso_texto] ->
        with {:ok, dia} <- convertir_entero(dia_texto),
             {:ok, kilometros} <- convertir_numero(kilometros_texto),
             {:ok, retraso} <- convertir_numero(retraso_texto) do

          {:ok,
           %{
             repartidor: repartidor,
             zona: zona,
             dia: dia,
             kilometros: kilometros,
             retraso: retraso
           }}
        end

      _ ->
        {:error, :formato_invalido}
    end
  end

  defp validar_repartidor(servicio, repartidores_por_codigo) do
    case Map.get(repartidores_por_codigo, servicio.repartidor) do
      nil -> {:error, :repartidor_desconocido}
      _ -> {:ok, servicio}
    end
  end


  defp validar_zona(servicio, zonas_por_id) do
    case Map.get(zonas_por_id, servicio.zona) do
      nil -> {:error, :zona_desconocida}
      _ -> {:ok, servicio}
    end
  end


  defp validar_dia(%{dia: dia} = servicio)
       when is_integer(dia) and dia in 1..@dias_operacion do
    {:ok, servicio}
  end

  defp validar_dia(_servicio) do
    {:error, :dia_invalido}
  end


  defp validar_kilometros(%{kilometros: kilometros} = servicio)
       when is_number(kilometros) and
              kilometros > 0 and
              kilometros <= @maximo_kilometros do
    {:ok, servicio}
  end

  defp validar_kilometros(_servicio) do
    {:error, :kilometros_fuera_de_rango}
  end


  defp validar_retraso(%{retraso: retraso} = servicio)
       when is_number(retraso) and
              retraso >= @minimo_retraso and
              retraso <= @maximo_retraso do
    {:ok, servicio}
  end

  defp validar_retraso(_servicio) do
    {:error, :retraso_invalido}
  end

  defp convertir_entero(texto) do
    case Integer.parse(texto) do
      {numero, ""} -> {:ok, numero}
      _ -> {:error, :formato_invalido}
    end
  end


  defp convertir_numero(texto) do
    case Float.parse(texto) do
      {numero, ""} -> {:ok, numero}
      _ -> {:error, :formato_invalido}
    end
  end

end
