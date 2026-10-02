# Integrantes: Sergio, Cristian y Mafe
# Responsable principal: Sergio
#
# Partes:
# - B.2 Validacion
# - Parte de B.5: convertir el servicio adicional
#
# ORDEN OBLIGATORIO DE VALIDACION:
# 1. repartidor
# 2. zona
# 3. dia
# 4. kilometros
# 5. retraso
#
# No se usa try/rescue. Los errores se devuelven con
# tuplas {:ok, valor} y {:error, motivo}.

defmodule Validacion do

  @moduledoc """
  Valida los servicios de la empresa de mensajeria en el orden
  exigido por el parcial.
  """

  # Valores fijos del enunciado
  @dias_operacion 6
  @maximo_kilometros 45
  @minimo_retraso -30
  @maximo_retraso 180


  # ============================================================
  # S1. VALIDACION PRINCIPAL
  # ============================================================

  def validar_servicio(servicio, repartidores_por_codigo, zonas_por_id) do

    # El "with" corta en el primer fallo, por eso queda garantizado
    # que un servicio con varios problemas solo reporte el primero
    # segun el orden repartidor -> zona -> dia -> km -> retraso.

    with {:ok, servicio} <- validar_repartidor(servicio, repartidores_por_codigo),
         {:ok, servicio} <- validar_zona(servicio, zonas_por_id),
         {:ok, servicio} <- validar_dia(servicio),
         {:ok, servicio} <- validar_kilometros(servicio),
         {:ok, servicio} <- validar_retraso(servicio) do

      {:ok, servicio}
    end
  end


  # ============================================================
  # S2. SEPARAR VALIDOS Y RECHAZADOS
  # ============================================================

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


  # ============================================================
  # S3. CONVERTIR LA LINEA DEL SERVICIO ADICIONAL
  # ============================================================

  def convertir_linea_servicio(linea) do
    # El usuario escribe: "M03;Z2;4;22.5;-3"
    # Se separa con el delimitador del enunciado y se recorta cada
    # campo con String.trim/1 para tolerar espacios sobrantes.

    campos =
      linea
      |> String.split(";")
      |> Enum.map(fn campo -> String.trim(campo) end)

    # El "case" exige exactamente 5 campos, como pide el enunciado.
    # El "with" encadena las conversiones: si una falla, el error
    # sale directo sin ejecutar las siguientes.
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


  # ============================================================
  # VALIDACIONES PRIVADAS
  # ============================================================

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
    # Este caso correcto se puede dejar listo.
    {:ok, servicio}
  end

  defp validar_dia(_servicio) do
    # Este motivo tambien viene definido por el parcial.
    {:error, :dia_invalido}
  end


  defp validar_kilometros(%{kilometros: kilometros} = servicio)
       when is_number(kilometros) and
              kilometros > 0 and
              kilometros <= @maximo_kilometros do

    # Caso valido segun el enunciado.
    # OJO: kilometros puede ser entero o decimal.
    {:ok, servicio}
  end

  defp validar_kilometros(_servicio) do
    {:error, :kilometros_fuera_de_rango}
  end


  defp validar_retraso(%{retraso: retraso} = servicio)
       when is_number(retraso) and
              retraso >= @minimo_retraso and
              retraso <= @maximo_retraso do

    # Caso valido segun el enunciado.
    # OJO: un retraso negativo significa entrega anticipada y es
    # valido. El rango va de -30 a 180 minutos.
    {:ok, servicio}
  end

  defp validar_retraso(_servicio) do
    {:error, :retraso_invalido}
  end


  # ============================================================
  # CONVERSION DE TEXTO
  # ============================================================

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
