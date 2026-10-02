# Integrantes: Sergio, Cristian y Mafe
# Responsable principal: Sergio
#
# PUNTO DE ENTRADA DEL PARCIAL.
#
# Este es el unico archivo .exs del proyecto: coordina todo el programa.
# Los modulos de logica (Util, Colecciones, Validacion, Liquidacion y
# Reportes) estan en archivos .ex y se compilan a .beam con:
#
#     elixirc *.ex
#
# Despues se ejecuta este archivo agregando la carpeta actual al path:
#
#     elixir -pa . programa.exs
#
# IMPORTANTE:
# Reportes construye texto y Programa lo imprime. Por eso toda la
# entrada y toda la salida pasa por Util.

# Datos es un script de datos fijos, por eso se carga aqui.
Code.require_file("datos.exs", __DIR__)

defmodule Programa do
  @moduledoc """
  Coordina todo el programa: carga datos, valida, liquida, reporta
  y muestra los resultados usando las funciones de Util.
  """

  # Este mapa viene dado por el enunciado.
  @empresa_aliada %{
    1 => 580.5,
    2 => 430,
    3 => 510,
    5 => 625,
    7 => 180
  }

  def main do
    # ==========================================================
    # PASO 1. CARGAR DATOS
    # ==========================================================

    repartidores = Datos.repartidores()
    zonas = Datos.zonas()
    servicios = Datos.servicios()

    # ==========================================================
    # PASO 2. PREPARAR COLECCIONES AUXILIARES
    # ==========================================================

    repartidores_por_codigo = Colecciones.repartidores_por_codigo(repartidores)
    zonas_por_id = Colecciones.zonas_por_id(zonas)

    # ==========================================================
    # PASO 3. VALIDAR SERVICIOS ORIGINALES
    # ==========================================================

    {servicios_validos, servicios_rechazados} =
      Validacion.separar_servicios(
        servicios,
        repartidores_por_codigo,
        zonas_por_id
      )

    # ==========================================================
    # PASO 4. PEDIR UN SERVICIO ADICIONAL
    # ==========================================================

    linea_adicional =
      Util.ingresar(
        "Ingrese un servicio adicional (repartidor;zona;dia;kilometros;retraso) o Enter para omitir: ",
        :texto
      )

    {servicios_validos, mensaje_servicio} =
      procesar_servicio_adicional(
        linea_adicional,
        servicios_validos,
        repartidores_por_codigo,
        zonas_por_id
      )

    # ==========================================================
    # PASO 5. CALCULAR LIQUIDACIONES
    # ==========================================================

    liquidaciones =
      Liquidacion.liquidar_repartidores(repartidores, servicios_validos)

    # ==========================================================
    # PASO 6. MOSTRAR R1 - R8
    # ==========================================================

    Util.mostrar(Reportes.r1(servicios_rechazados), :mensaje)
    Util.mostrar(Reportes.r2(zonas, servicios_validos), :mensaje)
    Util.mostrar(Reportes.r3(servicios_validos), :mensaje)
    Util.mostrar(Reportes.r4(liquidaciones), :mensaje)
    Util.mostrar(Reportes.r5(repartidores_por_codigo, servicios_validos), :mensaje)
    Util.mostrar(Reportes.r6(repartidores_por_codigo, servicios_validos), :mensaje)
    Util.mostrar(Reportes.r7(liquidaciones, servicios_validos), :mensaje)
    Util.mostrar(Reportes.r8(repartidores, zonas, servicios_validos), :mensaje)

    # ==========================================================
    # PASO 7. C.1 RANKING
    # ==========================================================

    Util.mostrar(Reportes.ranking(liquidaciones, []), :mensaje)

    Util.mostrar(
      Reportes.ranking(
        liquidaciones,
        campo: :kilometros,
        limite: 3
      ),
      :mensaje
    )

    Util.mostrar(
      Reportes.ranking(
        liquidaciones,
        orden: :asc,
        campo: :bruto
      ),
      :mensaje
    )

    # ==========================================================
    # PASO 8. C.2 EMPRESA ALIADA
    # ==========================================================

    mapa_empresa = Reportes.kilometros_por_dia(servicios_validos)

    mapa_combinado =
      Reportes.combinar_empresas(mapa_empresa, @empresa_aliada)

    Util.mostrar("C.2. Kilometros combinados con la empresa aliada\n", :mensaje)

    Util.mostrar(
      Reportes.mapa_dias_a_texto(mapa_combinado),
      :mensaje
    )

    # ==========================================================
    # PASO 9. PEDIR CODIGO PARA EL COMPROBANTE
    # ==========================================================

    codigo =
      Util.ingresar(
        "Ingrese el codigo del repartidor para ver su comprobante: ",
        :texto
      )

    Util.mostrar(
      Reportes.comprobante(
        codigo,
        repartidores_por_codigo,
        servicios_validos,
        liquidaciones
      ),
      :mensaje
    )

    # ==========================================================
    # RESUMEN DE LA EJECUCION
    # ==========================================================

    Util.mostrar("", :mensaje)

    Util.mostrar(
      "Servicio adicional: #{mensaje_servicio}",
      :mensaje
    )

    Util.mostrar(
      "Validos: #{length(servicios_validos)} | Rechazados: #{length(servicios_rechazados)}",
      :mensaje
    )
  end


  # ============================================================
  # B.5 - PROCESAR SERVICIO ADICIONAL
  # ============================================================

  defp procesar_servicio_adicional(
         "",
         servicios_validos,
         _repartidores_por_codigo,
         _zonas_por_id
       ) do
    # Enter sin escribir nada = no agregar servicio.

    {servicios_validos, "No se ingreso ningun servicio."}
  end


  defp procesar_servicio_adicional(
         linea,
         servicios_validos,
         repartidores_por_codigo,
         zonas_por_id
       ) do
    # El servicio valido se incorpora al FINAL de la lista para que
    # aparezca en todos los reportes.

    case Validacion.convertir_linea_servicio(linea) do
      {:error, motivo} ->
        {servicios_validos, "Servicio rechazado por formato: #{motivo}"}

      {:ok, servicio} ->
        case Validacion.validar_servicio(
               servicio,
               repartidores_por_codigo,
               zonas_por_id
             ) do
          {:ok, servicio_valido} ->
            {servicios_validos ++ [servicio_valido],
             "Servicio agregado: #{servicio_valido.repartidor} en " <>
               "zona #{servicio_valido.zona} el dia #{servicio_valido.dia}"}

          {:error, motivo} ->
            {servicios_validos, "Servicio rechazado: #{motivo}"}
        end
    end
  end
end

Programa.main()