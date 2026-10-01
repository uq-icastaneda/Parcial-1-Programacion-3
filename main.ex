# Sergio Armero
# Maria Fernanda Mejia
# Cristian Castañeda
# ==== PARCIAL 1 PROGRAMACION 3 ====
defmodule Main do
  def iniciar do
    Util.imprimir_mensaje("========================================")
    Util.imprimir_mensaje("   SISTEMA DE LIQUIDACIÓN DE SERVICIOS  ")
    Util.imprimir_mensaje("========================================\n")

    # 1. Cargar datos base
    repartidores = Datos.repartidores()
    zonas = Datos.zonas()
    servicios_raw = Datos.servicios()

    repartidores_dict = Colecciones.repartidores_por_codigo(repartidores)
    zonas_dict = Colecciones.zonas_por_id(zonas)

    # 2. INTERACCIÓN: Servicio Adicional ANTES de validar todo
    servicios_completos = solicitar_servicio_adicional(servicios_raw)

    # 3. Validar y separar servicios
    {servicios_validos, servicios_rechazados} =
      Validacion.separar_servicios(servicios_completos, repartidores_dict, zonas_dict)

    # 4. Calcular liquidaciones
    liquidaciones = Liquidacion.liquidar_repartidores(repartidores, servicios_validos)

    # 5. Imprimir Reportes R1 a R8
    ejecutar_reportes(repartidores, repartidores_dict, zonas, servicios_validos, servicios_rechazados, liquidaciones)

    # 6. INVESTIGACIÓN: Map.merge/3
    demostrar_merge_empresas(servicios_validos)

    # 7. INTERACCIÓN FINAL: Comprobante único
    solicitar_comprobante_unico(repartidores_dict, servicios_validos, liquidaciones)
  end

  # ==========================================
  # LÓGICA DEL SERVICIO ADICIONAL
  # ==========================================
  defp solicitar_servicio_adicional(servicios_raw) do
    Util.imprimir_mensaje("Ingrese un servicio adicional (repartidor;zona;dia;kilometros;retraso) o Enter para omitir:")
    entrada = IO.gets("> ") |> String.trim()

    if entrada == "" do
      Util.imprimir_mensaje("No se ingresó servicio (se presionó Enter).\n")
      servicios_raw
    else
      case parsear_servicio_texto(entrada) do
        {:ok, nuevo_servicio} ->
          Util.imprimir_mensaje("Servicio agregado para validación posterior.\n")
          servicios_raw ++ [nuevo_servicio]

        {:error, :formato_invalido} ->
          Util.imprimir_mensaje("Error: Rechazado por formato inválido.\n")
          servicios_raw
      end
    end
  end

  defp parsear_servicio_texto(texto) do
    partes = String.split(texto, ";")

    if length(partes) != 5 do
      {:error, :formato_invalido}
    else
      [rep, zon, dia_str, km_str, ret_str] = partes

      case {Integer.parse(dia_str), Float.parse(km_str <> ".0"), Float.parse(ret_str <> ".0")} do
        {{dia, ""}, {km, _}, {ret, _}} ->
          {:ok, %{repartidor: rep, zona: zon, dia: dia, kilometros: km, retraso: trunc(ret)}}
        _ ->
          {:error, :formato_invalido}
      end
    end
  end

  # ==========================================
  # LÓGICA DE INVESTIGACIÓN MAP.MERGE
  # ==========================================
  defp demostrar_merge_empresas(validos) do
    Util.imprimir_mensaje("\n----------------------------------------")
    Util.imprimir_mensaje("INVESTIGACIÓN: Combinación de empresas (Map.merge/3)")

    # Construir mapa base con los servicios válidos %{dia => kilometros_totales}
    mapa_r3 = Enum.reduce(validos, %{}, fn servicio, acc ->
      Map.update(acc, servicio.dia, servicio.kilometros, fn km_existente -> km_existente + servicio.kilometros end)
    end)

    empresa_aliada = %{
      1 => 580.5,
      2 => 430,
      3 => 510,
      5 => 625,
      7 => 180
    }

    # Map.merge/3 recibe los mapas y una función anónima para resolver choques de llaves
    mapa_combinado = Map.merge(mapa_r3, empresa_aliada, fn _dia, km_nuestra, km_aliada ->
      km_nuestra + km_aliada
    end)

    Enum.each(mapa_combinado, fn {dia, kms} ->
      Util.imprimir_mensaje("Día #{dia}: #{kms} km totales combinados")
    end)
  end

  # ==========================================
  # COMPROBANTE FINAL ÚNICO
  # ==========================================
  defp solicitar_comprobante_unico(repartidores_dict, validos, liquidaciones) do
    Util.imprimir_mensaje("\n========================================")
    Util.imprimir_mensaje("   GENERACIÓN DE COMPROBANTE DE PAGO    ")
    Util.imprimir_mensaje("========================================")

    Util.imprimir_mensaje("Ingrese el código de un repartidor (ej. M01):")
    codigo = IO.gets("> ") |> String.trim() |> String.upcase()

    if Map.has_key?(repartidores_dict, codigo) do
      Util.imprimir_mensaje("\n" <> Reportes.comprobante(codigo, repartidores_dict, validos, liquidaciones))
    else
      Util.imprimir_mensaje("\nEl código ingresado no corresponde a ningún repartidor.")
      Util.imprimir_mensaje("El programa continuará normalmente.")
    end

    Util.imprimir_mensaje("\n¡Fin de la ejecución!")
  end

  # ==========================================
  # EJECUCIÓN DE REPORTES
  # ==========================================
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
end
Main.iniciar();
