# Sergio Armero
# Maria Fernanda Mejia
# Cristian Castañeda
# ==== PARCIAL 1 PROGRAMACION 3 ====
defmodule Reportes do
  @meta_diaria 500
  @dias_operacion 6

  @motivos [
    :repartidor_desconocido,
    :zona_desconocida,
    :dia_invalido,
    :kilometros_fuera_de_rango,
    :retraso_invalido
  ]

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

  def r2(zonas, servicios_validos) do
    resultados =
      Enum.map(zonas, fn zona ->
        servicios_de_zona =
          Enum.filter(servicios_validos, fn servicio -> servicio.zona == zona end)

        km_totales =
          Enum.reduce(servicios_de_zona, 0, fn servicio, i -> i + servicio.kilometros end)

        densidad = km_totales / zona.area

        %{
          id: zona.id,
          nombre: zona.nombre,
          kilometros: km_totales,
          area: zona.area,
          densidad: densidad
        }
      end)

    Enum.sort_by(resultados, fn registro -> registro.densidad end, :desc)
  end

  def r3(servicios_validos) do
    km_dias = kilometros_por_dia(servicios_validos)

    detalle_dias =
      for dia <- 1..@dias_operacion do
        km = Map.get(km_dias, dia, 0)
        alcanzado = km >= @meta_diaria

        %{
          dia: dia,
          kilometros: km,
          meta_alcanzada: alcanzado
        }
      end

    alcanzo_todos = Enum.all?(detalle_dias, fn dia -> dia.meta_alcanzada end)
    alcanzo_al_menos_uno = Enum.any?(detalle_dias, fn dia -> dia.meta_alcanzada end)

    %{
      dias: detalle_dias,
      meta_todos_los_dias: alcanzo_todos,
      meta_al_menos_un_dia: alcanzo_al_menos_uno
    }
  end

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

  def r5(repartidores_por_codigo, servicios_validos) do
    resultados_por_dia =
      for dia <- 1..@dias_operacion do
        servicios_del_dia = Enum.filter(servicios_validos, fn servicio -> servicio.dia == dia end)

        if servicios_del_dia == [] do
          %{
            dia: dia,
            ganadores: [],
            max_kilometros: 0,
            estado: "sin servicios"
          }
        else
          km_por_repartidor =
            Enum.reduce(servicios_del_dia, %{}, fn servicio, i ->
              Map.update(i, servicio.repartidor, servicio.kilometros, fn actual ->
                actual + servicio.kilometros
              end)
            end)

          {_rep, max_km} = Enum.max_by(km_por_repartidor, fn {_codigo, km} -> km end)

          ganadores_dia =
            km_por_repartidor
            |> Enum.filter(fn {_codigo, km} -> km == max_km end)
            |> Enum.map(fn {codigo, _km} -> codigo end)

          %{
            dia: dia,
            ganadores: ganadores_dia,
            max_kilometros: max_km,
            estado: "ok"
          }
        end
      end

    todos_los_ganadores = Enum.flat_map(resultados_por_dia, fn dia -> dia.ganadores end)

    mejores_globales =
      if todos_los_ganadores == [] do
        []
      else
        conteo_dias = Enum.frequencies(todos_los_ganadores)

        {_rep, max_dias_ganados} = Enum.max_by(conteo_dias, fn {_codigo, cant} -> cant end)

        conteo_dias
        |> Enum.filter(fn {_codigo, cant} -> cant == max_dias_ganados end)
        |> Enum.map(fn {codigo, _cant} -> codigo end)
      end

    %{
      detalle_dias: resultados_por_dia,
      mas_dias_primer_lugar: mejores_globales
    }
  end

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

  def r8(repartidores, zonas, servicios_validos) do
    ids_zonas_totales = MapSet.new(zonas, fn zona -> zona.id end)
    total_zonas_count = MapSet.size(ids_zonas_totales)

    zonas_por_repartidor =
      Enum.reduce(servicios_validos, %{}, fn servicio, acc ->
        Map.update(
          acc,
          servicio.repartidor,
          MapSet.new([servicio.zona]),
          fn zonas_existentes -> MapSet.put(zonas_existentes, servicio.zona) end
        )
      end)

    repartidores_universales =
      repartidores
      |> Enum.filter(fn repartidor ->
        zonas_del_rep = Map.get(zonas_por_repartidor, repartidor.codigo, MapSet.new())

        MapSet.size(zonas_del_rep) == total_zonas_count
      end)
      |> Enum.map(fn repartidor -> repartidor.codigo end)

    if repartidores_universales == [] do
      "No hay repartidores con servicios válidos en todas las zonas."
    else
      repartidores_universales
    end
  end

  def ranking(liquidaciones, opciones \\ []) do
    campo = Keyword.get(opciones, :campo, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, length(liquidaciones))

    liquidaciones
    |> Enum.sort_by(fn item -> valor_campo(item, campo) end, orden)
    |> Enum.take(limite)
    |> Enum.with_index(1)
    |> Enum.map(fn {item, index} ->
      valor_formateado = mostrar_valor_ranking(item, campo)

      "#{index}. Repartidor: #{item.nombre} | #{campo}: #{valor_formateado}"
    end)
  end

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

  defp linea_dia_meta(dia, kilometros) do
    estado = if kilometros >= @meta_diaria, do: "Alcanzada", else: "No alcanzada"

    "Día #{dia}: #{kilometros} km (#{estado})"
  end

  defp texto_si_no(true), do: "Si"
  defp texto_si_no(false), do: "No"

  defp mejor_del_dia(dia, servicios_validos) do
    servicios_del_dia = Enum.filter(servicios_validos, fn s -> s.dia == dia end)

    if servicios_del_dia == [] do
      %{dia: dia, kilometros: 0, mejores: []}
    else
      km_por_repartidor =
        Enum.reduce(servicios_del_dia, %{}, fn s, acc ->
          Map.update(acc, s.repartidor, s.kilometros, fn actual -> actual + s.kilometros end)
        end)

      {_rep, max_km} = Enum.max_by(km_por_repartidor, fn {_codigo, km} -> km end)

      mejores_repartidores =
        km_por_repartidor
        |> Enum.filter(fn {_codigo, km} -> km == max_km end)
        |> Enum.map(fn {codigo, _km} -> codigo end)

      %{
        dia: dia,
        kilometros: max_km,
        mejores: mejores_repartidores
      }
    end
  end

  defp linea_mejor_dia(resultado, repartidores_por_codigo) do
    if resultado.kilometros == 0 or resultado.mejores == [] do
      "Día #{resultado.dia}: Sin servicios registrados."
    else
      nombres_mejores =
        resultado.mejores
        |> Enum.map(fn codigo ->
          repartidor = Map.get(repartidores_por_codigo, codigo)
          if repartidor, do: repartidor.nombre, else: codigo
        end)
        |> Enum.join(", ")

      "Día #{resultado.dia}: #{resultado.kilometros} km - Destacado(s): #{nombres_mejores}"
    end
  end

  defp nombre_repartidor(repartidores_por_codigo, codigo) do
    case Map.get(repartidores_por_codigo, codigo) do
      nil -> codigo
      repartidor -> repartidor.nombre
    end
  end

  def kilometros_por_dia(servicios_validos) do
    for dia <- 1..@dias_operacion, into: %{} do
      servicios_del_dia = Enum.filter(servicios_validos, fn servicio -> servicio.dia == dia end)

      total_km = Enum.reduce(servicios_del_dia, 0, fn s, i -> i + s.kilometros end)

      {dia, total_km}
    end
  end

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

  def formatear_pesos(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end

  def formatear_decimal(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end
end
