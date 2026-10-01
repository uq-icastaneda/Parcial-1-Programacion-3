defmodule Main do
  def iniciar do
    Util.imprimir_mensaje("========================================")
    Util.imprimir_mensaje("   SISTEMA DE LIQUIDACIÓN DE SERVICIOS  ")
    Util.imprimir_mensaje("========================================\n")

    repartidores = Datos.repartidores()
    zonas = Datos.zonas()
    servicios_raw = Datos.servicios()

    repartidores_dict = Colecciones.repartidores_por_codigo(repartidores)
    zonas_dict = Colecciones.zonas_por_id(zonas)

    {servicios_validos, servicios_rechazados} =
      Validacion.separar_servicios(servicios_raw, repartidores_dict, zonas_dict)

    liquidaciones = Liquidacion.liquidar_repartidores(repartidores, servicios_validos)

    ejecutar_reportes(
      repartidores,
      repartidores_dict,
      zonas,
      servicios_validos,
      servicios_rechazados,
      liquidaciones
    )
    menu_comprobantes(repartidores_dict, servicios_validos, liquidaciones)
  end

  defp ejecutar_reportes(repartidores, repartidores_dict, zonas, validos, rechazados, liquidaciones) do
    Util.imprimir_mensaje("\n" <> Reportes.r1(rechazados))

    Util.imprimir_mensaje("\n----------------------------------------")
    Util.imprimir_mensaje("R2. Zonas ordenadas por densidad")
    densidades = Reportes.r2(zonas, validos)
    Enum.each(densidades, fn z ->
      Util.imprimir_mensaje("#{z.nombre} (Area: #{z.area}): #{z.kilometros} km totales -> Densidad: #{Reportes.formatear_decimal(z.densidad)} km/area")
    end)

    Util.imprimir_mensaje("\n----------------------------------------")
    Util.imprimir_mensaje("R3. Desempeño vs Meta Diaria")
    meta_info = Reportes.r3(validos)
    Enum.each(meta_info.dias, fn dia ->
      estado = if dia.meta_alcanzada, do: "ALCANZADA", else: "NO ALCANZADA"
      Util.imprimir_mensaje("Día #{dia.dia}: #{dia.kilometros} km (#{estado})")
    end)
    Util.imprimir_mensaje("¿Se alcanzó todos los días? #{if meta_info.meta_todos_los_dias, do: "Sí", else: "No"}")
    Util.imprimir_mensaje("¿Se alcanzó al menos un día? #{if meta_info.meta_al_menos_un_dia, do: "Sí", else: "No"}")

    Util.imprimir_mensaje("\n----------------------------------------")
    Util.imprimir_mensaje(Reportes.r4(liquidaciones))

    Util.imprimir_mensaje("\n----------------------------------------")
    Util.imprimir_mensaje("R5. Repartidores destacados por día")
    r5_info = Reportes.r5(repartidores_dict, validos)
    Enum.each(r5_info.detalle_dias, fn dia ->
      if dia.estado == "sin servicios" do
        Util.imprimir_mensaje("Día #{dia.dia}: Sin servicios")
      else
        nombres = Enum.map(dia.ganadores, fn c -> Map.get(repartidores_dict, c).nombre end) |> Enum.join(", ")
        Util.imprimir_mensaje("Día #{dia.dia}: #{dia.max_kilometros} km - Destacado(s): #{nombres}")
      end
    end)
    nombres_globales = Enum.map(r5_info.mas_dias_primer_lugar, fn c -> Map.get(repartidores_dict, c).nombre end) |> Enum.join(", ")
    Util.imprimir_mensaje("Repartidor(es) que ganó más días: #{nombres_globales}")

    Util.imprimir_mensaje("\n----------------------------------------")
    Util.imprimir_mensaje(Reportes.r6(repartidores_dict, validos))

    Util.imprimir_mensaje("\n----------------------------------------")
    Util.imprimir_mensaje(Reportes.r7(liquidaciones, validos))

    Util.imprimir_mensaje("\n----------------------------------------")
    Util.imprimir_mensaje("R8. Repartidores con servicios en TODAS las zonas")
    r8_info = Reportes.r8(repartidores, zonas, validos)
    if is_binary(r8_info) do
      Util.imprimir_mensaje(r8_info)
    else
      nombres_r8 = Enum.map(r8_info, fn c -> Map.get(repartidores_dict, c).nombre end) |> Enum.join(", ")
      Util.imprimir_mensaje("Cumplen cobertura total: #{nombres_r8}")
    end

    Util.imprimir_mensaje("\n----------------------------------------")
    Util.imprimir_mensaje("Top 3 Repartidores por Kilómetros (Ranking Dinámico)")
    ranking_km = Reportes.ranking(liquidaciones, campo: :kilometros, orden: :desc, limite: 3)
    Enum.each(ranking_km, fn linea -> Util.imprimir_mensaje(linea) end)
  end

  defp menu_comprobantes(repartidores_dict, validos, liquidaciones) do
    Util.imprimir_mensaje("\n========================================")
    Util.imprimir_mensaje("   GENERACIÓN DE COMPROBANTES DE PAGO   ")
    Util.imprimir_mensaje("========================================")
    codigo = Util.leer_mensaje("Ingrese el código del repartidor (ej. M01) o 'salir' para terminar: ", :string)

    if String.downcase(codigo) != "salir" do
      codigo_formateado = String.upcase(codigo)

      Util.imprimir_mensaje("\n----------------------------------------")
      Util.imprimir_mensaje(Reportes.comprobante(codigo_formateado, repartidores_dict, validos, liquidaciones))
      Util.imprimir_mensaje("----------------------------------------")
      menu_comprobantes(repartidores_dict, validos, liquidaciones)
    else
      Util.imprimir_mensaje("\n¡Gracias por usar el sistema! Hasta luego.")
    end
  end
end
Main.iniciar();
