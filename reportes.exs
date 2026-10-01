# Integrantes: Sergio, Cristian y Mafe
#
# ESTE ARCHIVO ES COMPARTIDO.
#
# Responsables:
#
# R1 -> Sergio
# R2 -> Cristian
# R3 -> Cristian
# R4 -> Mafe
# R5 -> Cristian
# R6 -> Sergio
# R7 -> Mafe
# R8 -> Cristian
# ranking/2 -> Cristian
# combinar_empresas/2 -> Sergio
# mapa_dias_a_texto/1 -> Sergio
# comprobante/4 -> Mafe
#
# REGLA:
# Las funciones de Reportes DEVUELVEN texto.
# No deben hacer IO.puts.

defmodule Reportes do

  @moduledoc """
  Construye los reportes del parcial sin imprimirlos.
  """

  # Valores fijos del enunciado
  @meta_diaria 500
  @dias_operacion 6

  @motivos [
    :repartidor_desconocido,
    :zona_desconocida,
    :dia_invalido,
    :kilometros_fuera_de_rango,
    :retraso_invalido
  ]

  @minimo_servicios_r6 3


  # ============================================================
  # SERGIO - R1
  # ============================================================

  def r1(rechazados) do
    detalle =
      rechazados
      |> Enum.map(fn {servicio, motivo} ->
        "#{servicio.repartidor} | #{servicio.zona} | dia #{servicio.dia} | " <>
          "#{servicio.kilometros} km | #{servicio.retraso} min -> #{motivo}"
      end)
      |> Enum.join("\n")

    conteos =
      Enum.frequencies_by(rechazados, fn {_servicio, motivo} ->
        motivo
      end)

    resumen =
      @motivos
      |> Enum.map(fn motivo ->
        cantidad = Map.get(conteos, motivo, 0)
        "#{motivo}: #{cantidad}"
      end)
      |> Enum.join("\n")

    "R1. Servicios rechazados\n" <>
      detalle <>
      "\nRechazos por motivo\n" <>
      resumen
  end


  # ============================================================
  # SERGIO - R6
  # ============================================================

  def r6(repartidores_por_codigo, servicios_validos) do
    candidatos =
      servicios_validos
      |> Enum.group_by(fn servicio -> servicio.repartidor end)
      |> Enum.filter(fn {_codigo, servicios} ->
        length(servicios) >= @minimo_servicios_r6
      end)
      |> Enum.map(fn {codigo, servicios} ->
        suma_ponderada =
          Enum.reduce(servicios, 0, fn servicio, acumulador ->
            acumulador + servicio.retraso * servicio.kilometros
          end)

        kilometros =
          Enum.reduce(servicios, 0, fn servicio, acumulador ->
            acumulador + servicio.kilometros
          end)

        %{
          codigo: codigo,
          retraso_ponderado: suma_ponderada / kilometros
        }
      end)

    if candidatos == [] do
      "R6. Mejor puntualidad (minimo #{@minimo_servicios_r6} servicios validos)\n" <>
        "No hay repartidores que cumplan el minimo de servicios."
    else
      mejor =
        Enum.min_by(candidatos, fn candidato ->
          candidato.retraso_ponderado
        end)

      nombre =
        nombre_repartidor(
          repartidores_por_codigo,
          mejor.codigo
        )

      "R6. Mejor puntualidad (minimo #{@minimo_servicios_r6} servicios validos)\n" <>
        "#{nombre}, con #{formatear_decimal(mejor.retraso_ponderado)} min de retraso ponderado por kilometros"
    end
  end


  # ============================================================
  # SERGIO - C.2 COMBINACION DE LAS DOS EMPRESAS
  # ============================================================

  def combinar_empresas(mapa_empresa, mapa_aliada) do
    Map.merge(mapa_empresa, mapa_aliada, fn _dia, km_empresa, km_aliada ->
      km_empresa + km_aliada
    end)
  end


  def mapa_dias_a_texto(mapa_dias) do
    mapa_dias
    |> Map.keys()
    |> Enum.sort_by(fn dia -> dia end, :asc)
    |> Enum.map(fn dia ->
      "Dia #{dia}: #{Map.get(mapa_dias, dia)} km"
    end)
    |> Enum.join("\n")
  end


  # ============================================================
  # CRISTIAN - R2
  # ============================================================

  def r2(zonas, servicios_validos) do
    # TODO CRISTIAN:
    #
    # Para cada zona:
    # - sumar kilometros validos
    # - leer el area (km2)
    # - densidad = kilometros / area
    #
    # Ordenar de mayor a menor densidad.
    # Una zona sin servicios debe aparecer con 0 km.
    # Cuidar el caso area == 0.

    "R2 pendiente"
  end


  # ============================================================
  # CRISTIAN - FUNCION AUXILIAR PARA R3 Y PARA C.2
  # ============================================================

  def kilometros_por_dia(servicios_validos) do
    # TODO CRISTIAN:
    #
    # Debe devolver un mapa:
    #
    # %{
    #   1 => kilometros_dia_1,
    #   2 => kilometros_dia_2,
    #   ...
    #   6 => kilometros_dia_6
    # }
    #
    # Si no hay servicios en un dia, guardar 0.
    # Este mapa es el que despues se combina en C.2.

    %{}
  end


  # ============================================================
  # CRISTIAN - R3
  # ============================================================

  def r3(servicios_validos) do
    # TODO CRISTIAN:
    #
    # Usar kilometros_por_dia/1.
    #
    # Para cada dia:
    # - mostrar kilometros
    # - indicar si se alcanzo la @meta_diaria (500 km)
    #
    # Al final:
    # - ¿se alcanzo todos los dias?
    # - ¿se alcanzo al menos un dia?

    "R3 pendiente"
  end


  # ============================================================
  # MAFE - R4
  # ============================================================

  def r4(liquidaciones) do
    lineas =
      liquidaciones
      |> Enum.sort_by(fn liquidacion -> liquidacion.neto end, :desc)
      |> Enum.with_index()
      |> Enum.map(fn {liquidacion, indice} ->
        "#{indice + 1}. | #{liquidacion.nombre} | #{liquidacion.kilometros} km | " <>
          "$#{formatear_pesos(liquidacion.servicios)} | " <>
          "$#{formatear_pesos(liquidacion.bonificaciones)} | " <>
          "$#{formatear_pesos(liquidacion.alquiler)} | " <>
          "$#{formatear_pesos(liquidacion.neto)}"
      end)
      |> Enum.join("\n")

    "R4. Liquidacion de la semana\n" <>
      "# | Repartidor | Kilometros | Servicios | Bonificaciones | Alquiler | Neto\n" <>
      lineas
  end


  # ============================================================
  # CRISTIAN - R5
  # ============================================================

  def r5(repartidores_por_codigo, servicios_validos) do
    # TODO CRISTIAN:
    #
    # Para cada dia 1..6:
    # - sumar kilometros por repartidor
    # - encontrar el maximo
    # - conservar todos si hay empate
    #
    # Dia sin servicios -> "sin servicios"
    #
    # Al final:
    # repartidor(es) que fueron mejores mas dias.

    "R5 pendiente"
  end


  # ============================================================
  # MAFE - R7
  # ============================================================

  def r7(liquidaciones, servicios_validos) do
    total_pagado =
      Enum.reduce(liquidaciones, 0, fn liquidacion, acumulador ->
        acumulador + liquidacion.neto
      end)

    kilometros_validos =
      Enum.reduce(servicios_validos, 0, fn servicio, acumulador ->
        acumulador + servicio.kilometros
      end)

    costo_promedio =
      if kilometros_validos == 0 do
        0
      else
        total_pagado / kilometros_validos
      end

    "R7. Totales de la semana\n" <>
      "Total a pagar: $#{formatear_pesos(total_pagado)}\n" <>
      "Kilometros validos: #{kilometros_validos} km\n" <>
      "Costo promedio por kilometro: $#{formatear_pesos(costo_promedio)}"
  end


  # ============================================================
  # CRISTIAN - R8
  # ============================================================

  def r8(repartidores, zonas, servicios_validos) do
    # TODO CRISTIAN:
    #
    # Encontrar repartidores que tengan al menos
    # un servicio valido en TODAS las zonas.
    #
    # Si no hay ninguno, devolver un mensaje.

    "R8 pendiente"
  end


  # ============================================================
  # CRISTIAN - C.1 RANKING CON KEYWORD LISTS
  # ============================================================

  def ranking(liquidaciones, opciones) do
    # Estos son los valores por defecto pedidos por el parcial.
    campo = Keyword.get(opciones, :campo, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, length(liquidaciones))

    # TODO CRISTIAN:
    #
    # 1. ordenar segun "campo"
    # 2. usar "orden"
    # 3. limitar a "limite"
    # 4. convertir a texto
    #
    # Debe aceptar:
    # :neto
    # :kilometros
    # :bruto

    "Ranking pendiente: campo=#{campo}, orden=#{orden}, limite=#{limite}"
  end


  # ============================================================
  # MAFE - B.5 COMPROBANTE DEL REPARTIDOR
  # ============================================================

  def comprobante(
        codigo,
        repartidores_por_codigo,
        servicios_validos,
        liquidaciones
      ) do
    repartidor = Map.get(repartidores_por_codigo, codigo)

    if repartidor == nil do
      "No existe un repartidor con el codigo #{codigo}."
    else
      liquidacion =
        Enum.find(liquidaciones, fn item ->
          item.codigo == codigo
        end)

      servicios_repartidor =
        Enum.filter(servicios_validos, fn servicio ->
          servicio.repartidor == codigo
        end)

      servicios_por_dia =
        Enum.group_by(servicios_repartidor, fn servicio ->
          servicio.dia
        end)

      detalle =
        servicios_por_dia
        |> Map.keys()
        |> Enum.sort_by(fn dia -> dia end, :asc)
        |> Enum.map(fn dia ->
          servicios_dia = Map.get(servicios_por_dia, dia)

          kilometros =
            Enum.reduce(servicios_dia, 0, fn servicio, acumulador ->
              acumulador + servicio.kilometros
            end)

          valor_dia =
            Enum.reduce(servicios_dia, 0, fn servicio, acumulador ->
              acumulador + Liquidacion.valor_servicio(servicio)
            end)

          bonificacion =
            Liquidacion.bonificacion_dia(kilometros)

          "Dia #{dia}: #{kilometros} km | " <>
            "servicios $#{formatear_pesos(valor_dia)} | " <>
            "bonificacion $#{formatear_pesos(bonificacion)}"
        end)
        |> Enum.join("\n")

      "Comprobante de pago - #{repartidor.nombre} (#{repartidor.codigo})\n" <>
        detalle <>
        "\nSuma de servicios: $#{formatear_pesos(liquidacion.servicios)}" <>
        "\nBonificaciones: $#{formatear_pesos(liquidacion.bonificaciones)}" <>
        "\nAlquiler (#{liquidacion.dias_trabajados} dias): -$#{formatear_pesos(liquidacion.alquiler)}" <>
        "\nNeto a pagar: $#{formatear_pesos(liquidacion.neto)}"
    end
  end


  # ============================================================
  # HELPERS QUE NECESITARAN LOS REPORTES
  # ============================================================

  defp linea_dia_meta(dia, kilometros) do
    # TODO CRISTIAN:
    # Si kilometros >= @meta_diaria -> alcanzo la meta.
    # Si no -> no alcanzo la meta.

    "Dia #{dia}: #{kilometros} km"
  end


  defp texto_si_no(true), do: "Si"
  defp texto_si_no(false), do: "No"


  defp mejor_del_dia(dia, servicios_validos) do
    # TODO CRISTIAN:
    #
    # Debe devolver algo con esta forma:
    #
    # %{dia: dia, kilometros: maximo, mejores: ["M01", "M03"]}
    #
    # Si no hay servicios:
    # %{dia: dia, kilometros: 0, mejores: []}

    %{dia: dia, kilometros: 0, mejores: []}
  end


  defp linea_mejor_dia(resultado, repartidores_por_codigo) do
    # TODO CRISTIAN:
    # Convertir el resultado de mejor_del_dia/2 a texto.

    "Dia #{resultado.dia}: pendiente"
  end


  defp nombre_repartidor(repartidores_por_codigo, codigo) do
    # CRISTIAN lo escribe una vez, lo usan Sergio y Mafe.
    # Buscar el codigo y retornar el nombre.
    # Si no existe, retornar el codigo.

    repartidor = Map.get(repartidores_por_codigo, codigo)

    if repartidor == nil do
      codigo
    else
      repartidor.nombre
    end
  end


  # Helpers de ranking.
  # Las cabeceras ya quedan preparadas para que Cristian complete
  # la logica.

  defp valor_campo(liquidacion, :kilometros) do
    liquidacion.kilometros
  end

  defp valor_campo(liquidacion, :bruto) do
    liquidacion.bruto
  end

  defp valor_campo(liquidacion, :neto) do
    liquidacion.neto
  end

  defp valor_campo(liquidacion, _campo) do
    liquidacion.neto
  end


  defp mostrar_valor_ranking(liquidacion, :kilometros) do
    "#{liquidacion.kilometros} km"
  end

  defp mostrar_valor_ranking(liquidacion, :bruto) do
    "$#{formatear_pesos(liquidacion.bruto)}"
  end

  defp mostrar_valor_ranking(liquidacion, :neto) do
    "$#{formatear_pesos(liquidacion.neto)}"
  end

  defp mostrar_valor_ranking(liquidacion, _campo) do
    "$#{formatear_pesos(liquidacion.neto)}"
  end


  # Formato monetario ya lo pueden dejar listo.
  defp formatear_pesos(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end

  defp formatear_decimal(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end

end
