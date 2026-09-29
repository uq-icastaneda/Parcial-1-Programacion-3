# =====================================================================
# ESQUELETO DEL PARCIAL 1 - PROYECTO "JUGUTIER" (EMPRESA DE MENSAJERIA)
# =====================================================================
#
# Este archivo simula, en un solo documento, el contenido de la carpeta
# "esqueleto" del material base, pero reescrito para NUESTRO proyecto:
# la liquidacion semanal de una empresa de mensajeria.
#
# Cada bloque marcado con "ARCHIVO: x.exs" se copia tal cual a un
# archivo .exs independiente con ese nombre antes de compilar.
#
# Al final de cada bloque se repite la regla de compilacion:
#
#   Remove-Item .\Elixir.*.beam -ErrorAction SilentlyContinue
#   elixirc.bat .\datos.exs
#   elixirc.bat .\util.exs
#   elixirc.bat .\colecciones.exs
#   elixirc.bat .\validacion.exs
#   elixirc.bat .\liquidacion.exs
#   elixirc.bat .\reportes.exs
#   elixir.bat .\programa.exs
#
# El orden importa: un archivo debe poder llamar a los modulos que ya
# fueron compilados.
#
# =====================================================================
# INTEGRANTES: Sergio, Cristian y Mafe
# =====================================================================
#
# Reparto de archivos principales
#
#   1. SERGIO   -> validacion.exs   (B.2 validacion de servicios)
#   2. MAFE     -> liquidacion.exs  (B.3 liquidacion de pagos)
#   3. CRISTIAN -> programa.exs     (B.1/B.5 integracion y flujo)
#
# Reparto de reportes.exs (archivo compartido)
#
#   R1  -> Sergio
#   R2  -> Cristian
#   R3  -> Cristian
#   R4  -> Mafe
#   R5  -> Cristian
#   R6  -> Sergio
#   R7  -> Mafe
#   R8  -> Cristian
#   ranking/2 -> Cristian
#   combinar_empresas/2 -> Sergio
#   mapa_dias_a_texto/1 -> Sergio
#   comprobante/4 -> Mafe
#
# Reparto de apoyo
#
#   colecciones.exs        -> Cristian
#   util.exs               -> queda listo (lo escribe el primero que empiece)
#   benchmarks.exs buscar  -> Sergio
#   benchmarks.exs listas  -> Mafe
#   datos.exs repartidores -> Mafe
#   datos.exs zonas        -> Mafe
#   datos.exs servicios    -> Sergio
#   Documento: Parte A     -> Cristian
#   Documento: R6          -> Sergio
#   Documento: C.1 keyword -> Cristian
#   Documento: C.2 merge   -> Sergio
#   Documento: Parte D     -> todos (bitacora compartida)
#   Sustentacion           -> todos (cualquiera explica cualquier linea)
#
# ---------------------------------------------------------------------
# ORDEN DE TRABAJO
# ---------------------------------------------------------------------
#
#   A. Todos crean los archivos .exs desde este esqueleto.
#   B. Mafe termina Liquidacion.
#   C. Sergio termina Validacion.
#   D. Cristian termina Colecciones.
#   E. Cada uno termina sus reportes.
#   F. Cristian integra Programa.main.
#   G. Se completan datos.exs con los datos propios del grupo.
#   H. Se prueba con los datos del enunciado.
#   I. Se ejecutan los benchmarks.
#   J. Se prepara la sustentacion.
#
# NO DESCOMENTAR Programa.main() HASTA QUE LOS MODULOS PRINCIPALES
# ESTEN LISTOS.
#
# ---------------------------------------------------------------------
# RESTRICCIONES QUE EL ENUNCIADO PROHIBE
# ---------------------------------------------------------------------
#
#   - recursividad (funciones que se llaman a si mismas)
#   - defstruct ni structs propios
#   - lectura o escritura de archivos con File
#   - procesos (spawn, Task, Agent, GenServer)
#   - proyectos creados con mix ni librerias externas
#   - try/rescue para validar datos
#
#   Los errores se manejan con tuplas {:ok, valor} y {:error, motivo}.
#   Los recorridos se hacen con Enum o con comprehensions (for).
#
# ---------------------------------------------------------------------
# PARAMETROS FIJOS DEL ENUNCIADO
# ---------------------------------------------------------------------
#
#   Tarifa base por kilometro ....... $2.500
#   Meta diaria de la empresa ....... 500 km
#   Dias de operacion .............. 6 (numerados 1 a 6)
#   Maxima distancia de un servicio . 45 km
#   Kilometros diarios p/ bonific. . 80 km
#   Bonificacion diaria ............. $15.000
#   Alquiler de bicicleta ........... $10.000 por dia trabajado
#
# Cada valor vive como atributo (@) en el modulo que lo usa.
#
# ---------------------------------------------------------------------
# DECISION DE DISENO QUE DEBEMOS PODER EXPLICAR
# ---------------------------------------------------------------------
#
# En Liquidacion guardamos un campo "bruto" aunque el enunciado no lo
# pida textualmente. "bruto" = valor de servicios + bonificaciones,
# es decir, la cantidad ANTES de restar el alquiler de bicicleta.
# Ese campo existe porque ranking/2 debe poder ordenar por :neto,
# :kilometros y :bruto (parte C.1).
#
# El enunciado solo dice que neto = valor de servicios + bonificaciones
# - alquiler. Guardar el "bruto" no cambia ese resultado, solo evita
# recalcularlo en el ranking.
#
# ---------------------------------------------------------------------
# MAPA DE MOTIVOS DE RECHAZO (se usan en Validacion y en R1)
# ---------------------------------------------------------------------
#
#   1 :repartidor_desconocido
#   2 :zona_desconocida
#   3 :dia_invalido
#   4 :kilometros_fuera_de_rango
#   5 :retraso_invalido
#
# =====================================================================


# =====================================================================
# ARCHIVO: util.exs
# =====================================================================
#
# Responsable: queda listo. Lo escribe el primero que empiece.
#
# Este archivo se puede dejar prácticamente listo porque solo maneja
# entrada y salida. No debe tener reglas de negocio de la empresa.

defmodule Util do

  @moduledoc """
  Funciones de entrada y salida usadas por el programa.
  Son las unicas funciones del proyecto con efectos secundarios.
  """

  def leer(mensaje, :string) do
    IO.gets(mensaje)
    |> String.trim()
  end

  def imprimir_mensaje(mensaje) do
    IO.puts(mensaje)
  end

end


# =====================================================================
# ARCHIVO: colecciones.exs
# =====================================================================
#
# Integrantes: Sergio, Cristian y Mafe
# Responsable principal: Cristian
# Relacion: Parte A.1 - Colecciones
#
# OBJETIVO:
# Crear estructuras auxiliares para buscar repartidores por codigo
# y zonas por id.
#
# IMPORTANTE:
# Datos.repartidores() y Datos.zonas() siguen siendo listas.
# Estas funciones crean mapas auxiliares; no reemplazan los datos
# originales porque los mapas no garantizan conservar el orden.

defmodule Colecciones do

  @moduledoc """
  Funciones puras para preparar colecciones auxiliares.
  """

  def repartidores_por_codigo(repartidores) do
    # TODO CRISTIAN:
    # Recorrer la lista de repartidores.
    # Construir un mapa donde:
    #
    # clave  = repartidor.codigo
    # valor = repartidor
    #
    # Ejemplo esperado:
    # %{
    #   "M01" => %{codigo: "M01", nombre: "...", bicicleta: true},
    #   "M02" => %{codigo: "M02", nombre: "...", bicicleta: false}
    # }
    #
    # Sugerencia: Enum.reduce/3 acumulando con Map.put/3.

    %{}
  end


  def zonas_por_id(zonas) do
    # TODO CRISTIAN:
    # Recorrer la lista de zonas.
    # Construir un mapa donde:
    #
    # clave = zona.id
    # valor = zona
    #
    # Ejemplo esperado:
    # %{"Z1" => %{id: "Z1", nombre: "Centro", area: 6.5}}

    %{}
  end

end


# =====================================================================
# ARCHIVO: validacion.exs
# =====================================================================
#
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
# Si un servicio incumple varias condiciones, solo se registra el
# PRIMER error segun ese orden.

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

    # Esta estructura se deja creada porque el parcial exige usar with.
    # Sergio debe implementar correctamente cada funcion llamada aqui.

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
    # TODO SERGIO:
    #
    # Recorrer "servicios".
    # Por cada servicio llamar validar_servicio/3.
    #
    # Si retorna {:ok, servicio_valido}
    # agregarlo a la lista de validos.
    #
    # Si retorna {:error, motivo}
    # agregar {servicio, motivo} a rechazados.
    #
    # Retorno final:
    # {servicios_validos, servicios_rechazados}
    #
    # OJO: los servicios rechazados no participan en ningun calculo
    # posterior, excepto en R1.

    {[], []}
  end


  # ============================================================
  # S3. CONVERTIR LA LINEA DEL SERVICIO ADICIONAL
  # ============================================================

  def convertir_linea_servicio(linea) do
    # TODO SERGIO:
    #
    # La entrada llega asi:
    # "M03;Z2;4;22.5;-3"
    #
    # Debe convertirse en:
    #
    # {:ok,
    #  %{
    #    repartidor: "M03",
    #    zona: "Z2",
    #    dia: 4,
    #    kilometros: 22.5,
    #    retraso: -3.0
    #  }}
    #
    # Si:
    # - no hay exactamente 5 campos
    # - dia no es entero
    # - kilometros no es numero
    # - retraso no es numero
    #
    # retornar:
    # {:error, :formato_invalido}
    #
    # OJO: un retraso NEGATIVO es valido (entrega anticipada).
    # Solo es problema de formato cuando no se puede convertir
    # a numero.
    #
    # Despues Programa llamara validar_servicio/3.

    {:error, :formato_invalido}
  end


  # ============================================================
  # VALIDACIONES PRIVADAS
  # ============================================================

  defp validar_repartidor(servicio, repartidores_por_codigo) do
    # TODO SERGIO:
    #
    # Buscar servicio.repartidor en repartidores_por_codigo.
    #
    # Si existe:
    # {:ok, servicio}
    #
    # Si no existe:
    # {:error, :repartidor_desconocido}

    nil
  end


  defp validar_zona(servicio, zonas_por_id) do
    # TODO SERGIO:
    #
    # Si servicio.zona existe:
    # {:ok, servicio}
    #
    # Si no:
    # {:error, :zona_desconocida}

    nil
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
    # TODO SERGIO:
    # Usar Integer.parse/1.
    #
    # Correcto:
    # {numero, ""} -> {:ok, numero}
    #
    # Otro caso:
    # {:error, :formato_invalido}

    nil
  end


  defp convertir_numero(texto) do
    # TODO SERGIO:
    # Usar Float.parse/1.
    #
    # Correcto:
    # {numero, ""} -> {:ok, numero}
    #
    # Otro caso:
    # {:error, :formato_invalido}
    #
    # OJO: Float.parse/1 tambien acepta "-3" y lo devuelve como
    # -3.0. Eso es correcto para el retraso.

    nil
  end

end


# =====================================================================
# ARCHIVO: liquidacion.exs
# =====================================================================
#
# Integrantes: Sergio, Cristian y Mafe
# Responsable principal: Mafe
#
# Partes:
# - B.3 Liquidacion
# - reglas 2, 3, 4 y 5

defmodule Liquidacion do

  @moduledoc """
  Calcula el valor de cada servicio, las bonificaciones por
  productividad, el alquiler de bicicleta y el neto de cada repartidor.
  """

  # Valores fijos del parcial
  @tarifa_base 2_500
  @kilometros_bonificacion 80
  @bonificacion_diaria 15_000
  @alquiler_bicicleta 10_000


  # ============================================================
  # M1. VALOR DE UN SERVICIO
  # ============================================================

  def valor_servicio(servicio) do
    # TODO MAFE:
    #
    # 1. valor_base = servicio.kilometros * @tarifa_base
    #
    # 2. Segun servicio.retraso:
    #
    # hasta 0 minutos                -> bonificacion del 8 %
    # mas de 0 hasta 10              -> sin ajuste
    # mas de 10 hasta 30             -> descuento del 10 %
    # mas de 30                      -> descuento del 25 %
    #
    # OJO: un retraso de -3 o 0 recibe la bonificacion del 8 %.
    # Devuelve solamente el valor final del servicio.

    0
  end


  # ============================================================
  # M2. BONIFICACION POR PRODUCTIVIDAD
  # ============================================================

  def bonificacion_dia(kilometros_dia)
      when kilometros_dia >= @kilometros_bonificacion do
    # Este valor viene directamente del enunciado.
    @bonificacion_diaria
  end

  def bonificacion_dia(_kilometros_dia) do
    0
  end


  # ============================================================
  # M3. ALQUILER DE BICICLETA
  # ============================================================

  def alquiler_bicicleta(true, dias_trabajados) do
    # TODO MAFE:
    # multiplicar los dias trabajados por el alquiler diario.

    0
  end

  def alquiler_bicicleta(false, _dias_trabajados) do
    # Si no usa bicicleta de la empresa, no se descuenta nada.
    0
  end


  # ============================================================
  # M4. LIQUIDAR A TODOS
  # ============================================================

  def liquidar_repartidores(repartidores, servicios_validos) do
    # TODO MAFE:
    #
    # Debe devolver UNA liquidacion por cada repartidor.
    # Incluso uno sin servicios validos debe aparecer con todo en 0.
    #
    # Sugerencia vista en clase:
    # Enum.map(repartidores, fn repartidor -> ... end)

    []
  end


  defp liquidar_repartidor(repartidor, servicios_validos) do
    # TODO MAFE:
    #
    # Para este repartidor debes calcular:
    #
    # servicios_repartidor
    # kilometros
    # suma_servicios
    # servicios_por_dia
    # bonificaciones
    # dias_trabajados
    # alquiler
    # bruto
    # neto
    #
    #neto = suma_servicios + bonificaciones - alquiler
    # bruto = suma_servicios + bonificaciones
    #
    # El mapa final debe tener exactamente estos campos:
    #
    # %{
    #   codigo: repartidor.codigo,
    #   nombre: repartidor.nombre,
    #   kilometros: ...,
    #   servicios: ...,
    #   bonificaciones: ...,
    #   alquiler: ...,
    #   bruto: ...,
    #   neto: ...,
    #   dias_trabajados: ...
    # }

    %{
      codigo: repartidor.codigo,
      nombre: repartidor.nombre,
      kilometros: 0,
      servicios: 0,
      bonificaciones: 0,
      alquiler: 0,
      bruto: 0,
      neto: 0,
      dias_trabajados: 0
    }
  end

end


# =====================================================================
# ARCHIVO: reportes.exs
# =====================================================================
#
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


  # ============================================================
  # SERGIO - R1
  # ============================================================

  def r1(rechazados) do
    # TODO SERGIO:
    #
    # Debe construir un texto con:
    # 1. cada servicio rechazado
    # 2. su motivo
    # 3. conteo por cada motivo de @motivos
    #
    # No imprimir.
    #
    # Sugerencia: Enum.frequencies_by/2 para el conteo.

    "R1 pendiente"
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
    # TODO MAFE:
    #
    # Ordenar por neto de mayor a menor.
    # Numerar desde 1.
    # Mostrar:
    # numero
    # nombre
    # kilometros
    # valor de servicios
    # bonificaciones
    # alquiler
    # neto

    "R4 pendiente"
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
  # SERGIO - R6
  # ============================================================

  def r6(repartidores_por_codigo, servicios_validos) do
    # TODO SERGIO:
    #
    # Solo repartidores con 3 o mas servicios validos.
    #
    # retraso_ponderado =
    # suma(retraso * kilometros) / suma(kilometros)
    #
    # Elegir el MENOR retraso ponderado.
    #
    # OJO: los valores negativos son posibles (entrega anticipada).
    # Entre -4 y 3, el mejor resultado es -4.
    #
    # Ademas en el documento hay que explicar por que este valor
    # puede diferir del promedio simple de los retrasos.

    "R6 pendiente"
  end


  # ============================================================
  # MAFE - R7
  # ============================================================

  def r7(liquidaciones, servicios_validos) do
    # TODO MAFE:
    #
    # total_pagado = suma de netos
    # kilometros_validos = suma de kilometros de servicios validos
    #
    # costo_promedio =
    # total_pagado / kilometros_validos
    #
    # Cuidar el caso kilometros_validos == 0.

    "R7 pendiente"
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
  # SERGIO - C.2 COMBINACION DE LAS DOS EMPRESAS
  # ============================================================

  def combinar_empresas(mapa_empresa, mapa_aliada) do
    # TODO SERGIO:
    #
    # El parcial obliga a usar Map.merge/3.
    #
    # Cuando el dia exista en ambos mapas:
    # kilometros_empresa + kilometros_aliada
    #
    # El mapa aliado es:
    # %{1 => 580.5, 2 => 430, 3 => 510, 5 => 625, 7 => 180}
    #
    # En el documento hay que explicar:
    # 1. que produciria Map.merge/2
    # 2. por que eso no resuelve el problema
    # 3. que sucede con el dia 7 de la empresa aliada

    %{}
  end


  def mapa_dias_a_texto(mapa_dias) do
    # TODO SERGIO:
    # Convertir el mapa combinado en texto ordenado por dia.

    inspect(mapa_dias)
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
    # TODO MAFE:
    #
    # 1. Buscar el repartidor.
    # 2. Si no existe, devolver mensaje.
    # 3. Si existe:
    #    - buscar su liquidacion
    #    - filtrar sus servicios validos
    #    - agrupar por dia
    #    - para cada dia mostrar:
    #         kilometros
    #         valor de servicios
    #         bonificacion
    #    - mostrar suma de servicios, suma de bonificaciones,
    #      descuento por alquiler y neto a pagar
    #
    # Solo deben aparecer los dias en los que exista por lo menos
    # un servicio valido.

    "Comprobante pendiente para #{codigo}"
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
    # TODO CRISTIAN (lo escribe una vez, lo usan Sergio y Mafe):
    # Buscar el codigo y retornar el nombre.
    # Si no existe, retornar el codigo.

    codigo
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


# =====================================================================
# ARCHIVO: programa.exs
# =====================================================================
#
# Integrantes: Sergio, Cristian y Mafe
# Responsable principal: Cristian
#
# Partes:
# - B.1 Organizacion
# - B.5 Interaccion
# - integracion de todos los modulos
#
# IMPORTANTE:
# Este archivo debe terminarse AL FINAL,
# cuando Validacion, Liquidacion y Reportes ya funcionen.

defmodule Programa do

  @moduledoc """
  Coordina todo el programa.
  """

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

    # TODO CRISTIAN:
    # llamar:
    # Colecciones.repartidores_por_codigo/1
    # Colecciones.zonas_por_id/1

    repartidores_por_codigo = %{}
    zonas_por_id = %{}


    # ==========================================================
    # PASO 3. VALIDAR SERVICIOS ORIGINALES
    # ==========================================================

    # TODO CRISTIAN (con la funcion de Sergio):
    # usar Validacion.separar_servicios/3

    servicios_validos = []
    servicios_rechazados = []


    # ==========================================================
    # PASO 4. PEDIR UN SERVICIO ADICIONAL
    # ==========================================================

    linea_adicional =
      Util.leer(
        "Ingrese un servicio adicional (repartidor;zona;dia;kilometros;retraso) o Enter para omitir: ",
        :string
      )

    # TODO CRISTIAN (con la funcion de Sergio):
    # llamar procesar_servicio_adicional/4.
    #
    # Debe actualizar servicios_validos si el nuevo servicio es valido.
    #
    # El programa debe informar al usuario si el servicio:
    # - fue agregado
    # - fue rechazado por formato
    # - fue rechazado por alguna regla de validacion
    # - o no se ingreso porque se presiono Enter


    # ==========================================================
    # PASO 5. CALCULAR LIQUIDACIONES
    # ==========================================================

    # TODO CRISTIAN:
    # llamar Liquidacion.liquidar_repartidores/2.

    liquidaciones = []


    # ==========================================================
    # PASO 6. MOSTRAR R1 - R8
    # ==========================================================

    # TODO CRISTIAN:
    # Cuando los reportes esten listos, imprimir:
    #
    # Util.imprimir_mensaje(Reportes.r1(servicios_rechazados))
    # Util.imprimir_mensaje(Reportes.r2(zonas, servicios_validos))
    # Util.imprimir_mensaje(Reportes.r3(servicios_validos))
    # Util.imprimir_mensaje(Reportes.r4(liquidaciones))
    # Util.imprimir_mensaje(Reportes.r5(repartidores_por_codigo, servicios_validos))
    # Util.imprimir_mensaje(Reportes.r6(repartidores_por_codigo, servicios_validos))
    # Util.imprimir_mensaje(Reportes.r7(liquidaciones, servicios_validos))
    # Util.imprimir_mensaje(Reportes.r8(repartidores, zonas, servicios_validos))
    #
    # Recordar:
    # Reportes construye texto.
    # Programa imprime.


    # ==========================================================
    # PASO 7. C.1 RANKING
    # ==========================================================

    # Estas son las tres llamadas que exige el parcial.
    #
    # Descomentarlas cuando ranking/2 ya este terminado.

    # Util.imprimir_mensaje(
    #   Reportes.ranking(liquidaciones, [])
    # )

    # Util.imprimir_mensaje(
    #   Reportes.ranking(
    #     liquidaciones,
    #     campo: :kilometros,
    #     limite: 3
    #   )
    # )

    # Util.imprimir_mensaje(
    #   Reportes.ranking(
    #     liquidaciones,
    #     orden: :asc,
    #     campo: :bruto
    #   )
    # )


    # ==========================================================
    # PASO 8. C.2 EMPRESA ALIADA
    # ==========================================================

    # Este mapa viene dado por el enunciado.
    empresa_aliada = %{
      1 => 580.5,
      2 => 430,
      3 => 510,
      5 => 625,
      7 => 180
    }

    # TODO CRISTIAN (con la funcion de Sergio):
    #
    # mapa_empresa = Reportes.kilometros_por_dia(servicios_validos)
    #
    # mapa_combinado =
    #   Reportes.combinar_empresas(mapa_empresa, empresa_aliada)
    #
    # imprimir el resultado.


    # ==========================================================
    # PASO 9. PEDIR CODIGO PARA EL COMPROBANTE
    # ==========================================================

    # TODO CRISTIAN:
    #
    # codigo =
    #   Util.leer(
    #     "Ingrese el codigo del repartidor para ver su comprobante: ",
    #     :string
    #   )
    #
    # llamar Reportes.comprobante/4
    # e imprimir el texto.
    #
    # Si el codigo no corresponde a ningun repartidor, informar
    # y continuar normalmente.


    # Estas variables se usan para evitar warnings mientras
    # todavia estan completando el esqueleto.
    _ = repartidores
    _ = zonas
    _ = servicios
    _ = repartidores_por_codigo
    _ = zonas_por_id
    _ = servicios_validos
    _ = servicios_rechazados
    _ = linea_adicional
    _ = liquidaciones
    _ = empresa_aliada

    Util.imprimir_mensaje(
      "ESQUELETO CARGADO. Complete las funciones marcadas con TODO."
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

    # Este caso se deja listo:
    # Enter sin escribir nada = no agregar servicio.

    {servicios_validos, "No se ingreso ningun servicio."}
  end


  defp procesar_servicio_adicional(
         linea,
         servicios_validos,
         repartidores_por_codigo,
         zonas_por_id
       ) do

    # TODO CRISTIAN + SERGIO:
    #
    # 1. Validacion.convertir_linea_servicio(linea)
    #
    # 2. Si da {:error, motivo}
    #    devolver:
    #    {servicios_validos, "Servicio rechazado: #{motivo}"}
    #
    # 3. Si da {:ok, servicio}
    #    llamar Validacion.validar_servicio/3.
    #
    # 4. Si es valido:
    #    agregarlo al FINAL de servicios_validos.
    #    Un servicio valido se incorpora a TODOS los reportes.
    #
    # 5. Si es rechazado:
    #    no modificar la lista.

    _ = linea
    _ = repartidores_por_codigo
    _ = zonas_por_id

    {servicios_validos, "Procesamiento del servicio adicional pendiente."}
  end

end


# Cuando TODO el proyecto este listo, descomentar:
#
# Programa.main()


# =====================================================================
# ARCHIVO: benchmarks.exs
# =====================================================================
#
# Integrantes: Sergio, Cristian y Mafe
#
# Responsables:
# - Sergio: buscar en lista vs mapa
# - Mafe: agregar al final vs agregar al inicio
#
# Este archivo NO forma parte de la logica principal.
# Es para la medicion adicional solicitada por el profesor.

defmodule Benchmarks do

  # ============================================================
  # SERGIO - BUSCAR EN LISTA VS MAPA
  # ============================================================

  def ejecutar_busquedas do
    # TODO SERGIO:
    #
    # 1. Generar 100_000 repartidores.
    # 2. Generar 1_000 codigos al azar.
    # 3. Crear mapa indexado por codigo.
    # 4. Medir con :timer.tc/1:
    #       Enum.find/2 sobre lista
    #       Map.get/2 sobre mapa
    #
    # Retornar:
    # {tiempo_lista, tiempo_mapa}

    {0, 0}
  end


  # ============================================================
  # MAFE - AGREGAR FINAL VS INICIO
  # ============================================================

  def ejecutar_listas do
    # TODO MAFE:
    #
    # Construir 20_000 elementos con Enum.reduce/3.
    #
    # Medicion 1:
    # lista ++ [elemento]
    #
    # Medicion 2:
    # [elemento | lista]
    #
    # Retornar:
    # {tiempo_final, tiempo_inicio}

    {0, 0}
  end

end


# Cuando las dos funciones esten listas,
# hacer 3 ejecuciones de cada una y mostrar los tiempos.
#
# IMPORTANTE:
# Los tiempos se deben medir en el computador real del grupo.
#
# Ejemplo de called:
#
#   {lista_1, mapa_1} = Benchmarks.ejecutar_busquedas()
#   {final_1, inicio_1} = Benchmarks.ejecutar_listas()
#   Util.imprimir_mensaje("Busqueda 1 - lista: #{lista_1} | mapa: #{mapa_1}")
#   Util.imprimir_mensaje("Lista 1 - final: #{final_1} | inicio: #{inicio_1}")


# =====================================================================
# ARCHIVO: datos.exs
# =====================================================================
#
# Integrantes: Sergio, Cristian y Mafe
#
# DATOS PROPIOS DEL GRUPO.
#
# Requisitos minimos del parcial:
#
# - 10 repartidores
# - 4 o mas con bicicleta: true
# - 4 zonas
# - servicios validos en los 6 dias
# - 80 servicios validos
# - minimo 2 invalidos por cada motivo:
#     :repartidor_desconocido
#     :zona_desconocida
#     :dia_invalido
#     :kilometros_fuera_de_rango
#     :retraso_invalido
#
# Reparto de este archivo:
#   repartidores/0 -> MAFE
#   zonas/0        -> MAFE
#   servicios/0    -> SERGIO
#
# El grupo debe llenar este archivo.
# Se dejan ejemplos de la FORMA de cada dato.

defmodule Datos do

  def repartidores do
    [
      # EJEMPLO:
      # %{codigo: "M01", nombre: "Ana Torres", bicicleta: true}

      # TODO MAFE:
      # completar minimo 10 repartidores
      # con minimo 4 que usen bicicleta: true
    ]
  end


  def zonas do
    [
      # EJEMPLO:
      # %{id: "Z1", nombre: "Centro", area: 6.5}

      # TODO MAFE:
      # completar minimo 4 zonas
      # (area esta en km2 y puede ser decimal)
    ]
  end


  def servicios do
    [
      # EJEMPLO VALIDO:
      # %{repartidor: "M01", zona: "Z1", dia: 1, kilometros: 18, retraso: 3}

      # EJEMPLO VALIDO CON ENTREGA ANTICIPADA (retraso negativo):
      # %{repartidor: "M03", zona: "Z2", dia: 4, kilometros: 22.5, retraso: -3}

      # EJEMPLO INVALIDO POR REPARTIDOR:
      # %{repartidor: "M99", zona: "Z1", dia: 1, kilometros: 20, retraso: 3}

      # EJEMPLO INVALIDO POR ZONA:
      # %{repartidor: "M01", zona: "Z9", dia: 1, kilometros: 20, retraso: 3}

      # EJEMPLO INVALIDO POR DIA:
      # %{repartidor: "M02", zona: "Z1", dia: 7, kilometros: 20, retraso: 3}

      # EJEMPLO INVALIDO POR KILOMETROS:
      # %{repartidor: "M02", zona: "Z1", dia: 2, kilometros: 60, retraso: 3}

      # EJEMPLO INVALIDO POR RETRASO:
      # %{repartidor: "M02", zona: "Z1", dia: 2, kilometros: 20, retraso: 250}

      # TODO SERGIO:
      # completar 80 validos
      # + minimo 10 invalidos (2 por motivo)
      #
      # OJO: un servicio puede tener varios errores a la vez,
      # pero solo se registra el primero segun el orden:
      # repartidor -> zona -> dia -> kilometros -> retraso.
    ]
  end

end


# =====================================================================
# FIN DEL ESQUELETO
# =====================================================================
#
# Cada bloque de arriba se copia a un .exs independiente y se compila
# en el orden indicado al principio de este archivo.
#
# NO descomentar Programa.main() hasta que todos los modulos
# principales esten listos.
