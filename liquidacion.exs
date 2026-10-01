defmodule Liquidacion do

  @tarifa_base 2_500
  @kilometros_bonificacion 80
  @bonificacion_diaria 15_000
  @alquiler_bicicleta 10_000


  def valor_servicio(servicio) do
    valor_base = servicio.kilometros * @tarifa_base

    cond do
      servicio.retraso <= 0 ->
        valor_base * 1.08

      servicio.retraso <= 10 ->
        valor_base

      servicio.retraso <= 30 ->
        valor_base * 0.90

      true ->
        valor_base * 0.75
    end
  end

  def bonificacion_dia(kilometros_dia)
      when kilometros_dia >= @kilometros_bonificacion do
    @bonificacion_diaria
  end

  def bonificacion_dia(_kilometros_dia) do
    0
  end


  def alquiler_bicicleta(true, dias_trabajados) do
    dias_trabajados * @alquiler_bicicleta
  end

  def alquiler_bicicleta(false, _dias_trabajados) do
    0
  end


  def liquidar_repartidores(repartidores, servicios_validos) do
    Enum.map(repartidores, fn repartidor ->
      liquidar_repartidor(repartidor, servicios_validos)
    end)
  end


  defp liquidar_repartidor(repartidor, servicios_validos) do
    servicios_repartidor =
      Enum.filter(servicios_validos, fn servicio ->
        servicio.repartidor == repartidor.codigo
      end)

    kilometros =
      Enum.reduce(servicios_repartidor, 0, fn servicio, acumulador ->
        acumulador + servicio.kilometros
      end)

    suma_servicios =
      Enum.reduce(servicios_repartidor, 0, fn servicio, acumulador ->
        acumulador + valor_servicio(servicio)
      end)

    servicios_por_dia =
      Enum.group_by(servicios_repartidor, fn servicio ->
        servicio.dia
      end)

    bonificaciones =
      Map.values(servicios_por_dia)
      |> Enum.reduce(0, fn servicios_dia, acumulador ->
        kilometros_dia =
          Enum.reduce(servicios_dia, 0, fn servicio, suma ->
            suma + servicio.kilometros
          end)

        acumulador + bonificacion_dia(kilometros_dia)
      end)

    dias_trabajados =
      servicios_por_dia
      |> Map.keys()
      |> length()

    alquiler =
      alquiler_bicicleta(
        repartidor.bicicleta,
        dias_trabajados
      )

    bruto = suma_servicios + bonificaciones
    neto = bruto - alquiler

    %{
      codigo: repartidor.codigo,
      nombre: repartidor.nombre,
      kilometros: kilometros,
      servicios: suma_servicios,
      bonificaciones: bonificaciones,
      alquiler: alquiler,
      bruto: bruto,
      neto: neto,
      dias_trabajados: dias_trabajados
    }
  end

end
