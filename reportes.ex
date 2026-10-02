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
#
# Para ordenar colecciones y para dar formato a cada elemento se usan
# las funciones puras de Util (ordenar/3 y convertir_coleccion_mensaje/2).
# Util no imprime nada cuando se usan esas dos funciones.

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
      Util.convertir_coleccion_mensaje(rechazados, fn {servicio, motivo} ->
        "#{servicio.repartidor} | #{servicio.zona} | dia #{servicio.dia} | " <>
          "#{servicio.kilometros} km | #{servicio.retraso} min -> #{motivo}"
      end)

    conteos =
      Enum.frequencies_by(rechazados, fn {_servicio, motivo} ->
        motivo
      end)

    resumen =
      Util.convertir_coleccion_mensaje(@motivos, fn motivo ->
        cantidad = Map.get(conteos, motivo, 0)
        "#{motivo}: #{cantidad}"
      end)

    "R1. Servicios rechazados\n" <>
      Enum.join(detalle, "\n") <>
      "\nRechazos por motivo\n" <>
      Enum.join(resumen, "\n")
  end


  # ============================================================
  # CRISTIAN - R2
  # ============================================================

  def r2(zonas, servicios_validos) do
    # Cada zona se calcula como {densidad, texto}. Se ordena por
    # densidad (no por texto) y recien despues se arma el texto,
    # porque ordenar cadenas no ordenaria de mayor a menor.

    detalles =
      Enum.map(zonas, fn zona ->
        kilometros =
          servicios_validos
          |> Enum.filter(fn servicio -> servicio.zona == zona.id end)
          |> Enum.reduce(0, fn servicio, acumulador ->
            acumulador + servicio.kilometros
          end)

        # El enunciado pide cuidar el caso area == 0.
        densidad =
          if zona.area > 0 do
            kilometros / zona.area
          else
            0
          end

        texto =
          "#{zona.id} | #{zona.nombre} | #{kilometros} km | " <>
            "#{zona.area} km2 | densidad #{formatear_decimal(densidad)}"

        {densidad, texto}
      end)

    lineas =
      detalles
      |> Util.ordenar(:desc, fn {densidad, _texto} -> densidad end)
      |> Util.convertir_coleccion_mensaje(fn {_densidad, texto} -> texto end)

    "R2. Densidad por zona (de mayor a menor)\n" <> Enum.join(lineas, "\n")
  end


  # ============================================================
  # CRISTIAN - FUNCION AUXILIAR PARA R3 Y PARA C.2
  # ============================================================

  def kilometros_por_dia(servicios_validos) do
    # Se recorre 1..6 y se guarda el total de cada dia. Un dia sin
    # servicios queda en 0, nunca ausente del mapa.

    Enum.reduce(1..@dias_operacion, %{}, fn dia, acumulador ->
      kilometros =
        servicios_validos
        |> Enum.filter(fn servicio -> servicio.dia == dia end)
        |> Enum.reduce(0, fn servicio, suma -> suma + servicio.kilometros end)

      Map.put(acumulador, dia, kilometros)
    end)
  end


  # ============================================================
  # CRISTIAN - R3
  # ============================================================

  def r3(servicios_validos) do
    kilometros_por_dia = kilometros_por_dia(servicios_validos)

    alcanzo_meta? = fn dia ->
      Map.get(kilometros_por_dia, dia, 0) >= @meta_diaria
    end

    lineas =
      Util.convertir_coleccion_mensaje(1..@dias_operacion, fn dia ->
        linea_dia_meta(dia, Map.get(kilometros_por_dia, dia, 0))
      end)

    todos_los_dias = Enum.all?(1..@dias_operacion, alcanzo_meta?)
    al_menos_un_dia = Enum.any?(1..@dias_operacion, alcanzo_meta?)

    "R3. Meta diaria de #{@meta_diaria} km\n" <>
      Enum.join(lineas, "\n") <>
      "\nTodos los dias alcanzaron la meta: #{texto_si_no(todos_los_dias)}" <>
      "\nAl menos un dia alcanzo la meta: #{texto_si_no(al_menos_un_dia)}"
  end


  # ============================================================
  # MAFE - R4
  # ============================================================

  def r4(liquidaciones) do
    ordenadas = Util.ordenar(liquidaciones, :desc, & &1.neto)

    lineas =
      ordenadas
      |> Enum.with_index(1)
      |> Util.convertir_coleccion_mensaje(fn {liquidacion, indice} ->
        "#{indice}. | #{liquidacion.nombre} | #{liquidacion.kilometros} km | " <>
          "$#{formatear_pesos(liquidacion.servicios)} | " <>
          "$#{formatear_pesos(liquidacion.bonificaciones)} | " <>
          "$#{formatear_pesos(liquidacion.alquiler)} | " <>
          "$#{formatear_pesos(liquidacion.neto)}"
      end)

    "R4. Liquidacion de la semana\n" <>
      "# | Repartidor | Kilometros | Servicios | Bonificaciones | Alquiler | Neto\n" <>
      Enum.join(lineas, "\n")
  end


  # ============================================================
  # CRISTIAN - R5
  # ============================================================

  def r5(repartidores_por_codigo, servicios_validos) do
    resultados =
      Util.convertir_coleccion_mensaje(1..@dias_operacion, fn dia ->
        mejor_del_dia(dia, servicios_validos)
      end)

    lineas =
      Util.convertir_coleccion_mensaje(resultados, fn resultado ->
        linea_mejor_dia(resultado, repartidores_por_codigo)
      end)

    # Cada dia puede tener varios ganadores por empate, asi que se
    # cuentan las apariciones de cada codigo en todos los dias.
    todos_los_ganadores =
      Enum.flat_map(resultados, fn resultado -> resultado.mejores end)

    mas_dias =
      if todos_los_ganadores == [] do
        []
      else
        conteo = Enum.frequencies(todos_los_ganadores)

        {_codigo, maximo} =
          Enum.max_by(conteo, fn {_codigo, cantidad} -> cantidad end)

        conteo
        |> Enum.filter(fn {_codigo, cantidad} -> cantidad == maximo end)
        |> Util.convertir_coleccion_mensaje(fn {codigo, _cantidad} -> codigo end)
        |> Util.ordenar(:asc)
      end

    cierre =
      if mas_dias == [] do
        "Ningun repartidor fue el mejor ningun dia."
      else
        nombres =
          Util.convertir_coleccion_mensaje(mas_dias, fn codigo ->
            nombre_repartidor(repartidores_por_codigo, codigo)
          end)

        "Repartidor(es) con mas dias en primer lugar: " <> Enum.join(nombres, ", ")
      end

    "R5. Mejor repartidor de cada dia\n" <> Enum.join(lineas, "\n") <> "\n" <> cierre
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
      |> Util.convertir_coleccion_mensaje(fn {codigo, servicios} ->
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
        Util.ordenar(candidatos, :asc, & &1.retraso_ponderado)
        |> List.first()

      nombre = nombre_repartidor(repartidores_por_codigo, mejor.codigo)

      "R6. Mejor puntualidad (minimo #{@minimo_servicios_r6} servicios validos)\n" <>
        "#{nombre}, con #{formatear_decimal(mejor.retraso_ponderado)} min de retraso ponderado por kilometros"
    end
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
    # Se cuentan zonas distintas realmente existentes, no la cantidad
    # cruda del listado, para no contar ids repetidos.
    total_zonas =
      zonas
      |> Enum.map(fn zona -> zona.id end)
      |> Enum.uniq()
      |> length()

    # Para cada repartidor se guardan las zonas donde tuvo al menos
    # un servicio valido.
    zonas_por_repartidor =
      Enum.reduce(servicios_validos, %{}, fn servicio, acumulador ->
        Map.update(acumulador, servicio.repartidor, [servicio.zona], fn zonas_vistas ->
          Enum.uniq(zonas_vistas ++ [servicio.zona])
        end)
      end)

    universales =
      Enum.filter(repartidores, fn repartidor ->
        zonas_vistas = Map.get(zonas_por_repartidor, repartidor.codigo, [])

        length(zonas_vistas) == total_zonas
      end)

    detalle =
      if universales == [] do
        "No hay repartidores con servicios validos en todas las zonas."
      else
        nombres =
          Util.convertir_coleccion_mensaje(universales, & &1.nombre)

        "Repartidores que cubrieron todas las zonas: " <> Enum.join(nombres, ", ")
      end

    "R8. Cobertura de zonas\n" <> detalle
  end


  # ============================================================
  # CRISTIAN - C.1 RANKING CON KEYWORD LISTS
  # ============================================================

  def ranking(liquidaciones, opciones) do
    # Estos son los valores por defecto pedidos por el parcial.
    campo = Keyword.get(opciones, :campo, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, length(liquidaciones))

    lineas =
      liquidaciones
      |> Util.ordenar(orden, fn liquidacion -> valor_campo(liquidacion, campo) end)
      |> Enum.take(limite)
      |> Enum.with_index(1)
      |> Util.convertir_coleccion_mensaje(fn {liquidacion, indice} ->
        "#{indice}. #{liquidacion.nombre} | #{campo}: " <>
          "#{mostrar_valor_ranking(liquidacion, campo)}"
      end)

    "Ranking por #{campo} (orden #{orden})\n" <> Enum.join(lineas, "\n")
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
    |> Util.ordenar(:asc)
    |> Util.convertir_coleccion_mensaje(fn dia ->
      "Dia #{dia}: #{Map.get(mapa_dias, dia)} km"
    end)
    |> Enum.join("\n")
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
        |> Util.ordenar(:asc)
        |> Util.convertir_coleccion_mensaje(fn dia ->
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

      "Comprobante de pago - #{repartidor.nombre} (#{repartidor.codigo})\n" <>
        Enum.join(detalle, "\n") <>
        "\nSuma de servicios: $#{formatear_pesos(liquidacion.servicios)}" <>
        "\nBonificaciones: $#{formatear_pesos(liquidacion.bonificaciones)}" <>
        "\nAlquiler (#{liquidacion.dias_trabajados} dias): -$#{formatear_pesos(liquidacion.alquiler)}" <>
        "\nNeto a pagar: $#{formatear_pesos(liquidacion.neto)}"
    end
  end


  # ============================================================
  # HELPERS QUE NECESITAN LOS REPORTES
  # ============================================================

  defp linea_dia_meta(dia, kilometros) do
    estado =
      if kilometros >= @meta_diaria do
        "meta alcanzada"
      else
        "meta no alcanzada"
      end

    "Dia #{dia}: #{kilometros} km (#{estado})"
  end


  defp texto_si_no(true), do: "Si"
  defp texto_si_no(false), do: "No"


  defp mejor_del_dia(dia, servicios_validos) do
    kilometros_por_repartidor =
      servicios_validos
      |> Enum.filter(fn servicio -> servicio.dia == dia end)
      |> Enum.reduce(%{}, fn servicio, acumulador ->
        Map.update(acumulador, servicio.repartidor, servicio.kilometros, fn actual ->
          actual + servicio.kilometros
        end)
      end)

    # Util.ordenar/3 deja el dia mas lejano al principio, asi que el
    # primer elemento es el de mayor kilometraje. Los empates se
    # detectan comparando contra ese maximo.
    ordenados =
      kilometros_por_repartidor
      |> Util.ordenar(:desc, fn {_codigo, km} -> km end)

    case ordenados do
      [] ->
        %{dia: dia, kilometros: 0, mejores: []}

      [{_codigo, maximo} | _resto] ->
        mejores =
          kilometros_por_repartidor
          |> Enum.filter(fn {_codigo, km} -> km == maximo end)
          |> Util.convertir_coleccion_mensaje(fn {codigo, _km} -> codigo end)
          |> Util.ordenar(:asc)

        %{
          dia: dia,
          kilometros: maximo,
          mejores: mejores
        }
    end
  end


  defp linea_mejor_dia(resultado, repartidores_por_codigo) do
    if resultado.mejores == [] do
      "Dia #{resultado.dia}: sin servicios"
    else
      nombres =
        Util.convertir_coleccion_mensaje(resultado.mejores, fn codigo ->
          nombre_repartidor(repartidores_por_codigo, codigo)
        end)

      "Dia #{resultado.dia}: #{resultado.kilometros} km | " <>
        "mejores: #{Enum.join(nombres, ", ")}"
    end
  end


  defp nombre_repartidor(repartidores_por_codigo, codigo) do
    case Map.get(repartidores_por_codigo, codigo) do
      nil -> codigo
      repartidor -> repartidor.nombre
    end
  end


  # Helpers de ranking.

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


  # Formato monetario.
  defp formatear_pesos(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end

  defp formatear_decimal(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end

end