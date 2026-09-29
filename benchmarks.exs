# Integrantes: Sergio, Cristian y Mafe
#
# Responsables:
# - Sergio: buscar en lista vs mapa
# - Mafe: agregar al final vs agregar al inicio
#
# Este archivo NO forma parte de la logica principal.
# Es para la medicion adicional solicitada por el profesor.

defmodule Benchmarks do

  @cantidad_repartidores 100_000
  @cantidad_busquedas 1_000
  @cantidad_elementos 20_000

  # ============================================================
  # SERGIO - BUSCAR EN LISTA VS MAPA
  # ============================================================

  def ejecutar_busquedas do
    # 1. Se generan 100_000 repartidores en una LISTA.
    repartidores =
      Enum.map(1..@cantidad_repartidores, fn numero ->
        %{
          codigo: "M#{numero}",
          nombre: "Repartidor #{numero}",
          bicicleta: rem(numero, 2) == 0
        }
      end)

    # 2. Se generan 1_000 codigos al azar con :rand.uniform/1.
    codigos =
      Enum.map(1..@cantidad_busquedas, fn _numero ->
        "M#{:rand.uniform(@cantidad_repartidores)}"
      end)

    # 3. El mismo conjunto de repartidores, indexado en un MAPA
    #    por codigo (mismo reduce que usa Colecciones).
    mapa_repartidores =
      Enum.reduce(repartidores, %{}, fn repartidor, acumulador ->
        Map.put(acumulador, repartidor.codigo, repartidor)
      end)

    # 4. Las dos busquedas se hacen sobre LOS MISMOS codigos para
    #    que la comparacion sea justa.
    #    :timer.tc/1 devuelve {tiempo_microsegundos, resultado}.

    {tiempo_lista, _resultados_lista} =
      :timer.tc(fn ->
        Enum.map(codigos, fn codigo ->
          Enum.find(repartidores, fn repartidor ->
            repartidor.codigo == codigo
          end)
        end)
      end)

    {tiempo_mapa, _resultados_mapa} =
      :timer.tc(fn ->
        Enum.map(codigos, fn codigo ->
          Map.get(mapa_repartidores, codigo)
        end)
      end)

    {tiempo_lista, tiempo_mapa}
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
