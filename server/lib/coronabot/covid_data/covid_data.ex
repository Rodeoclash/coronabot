defmodule Coronabot.CovidData do
  @moduledoc """
  Figure out data about Covid
  """

  alias __MODULE__
  alias Coronabot.{CovidData.Records, CovidData.Records.Comparaison}

  @enforce_keys [
    :yesterday_today_comparaison
  ]

  defstruct yesterday_today_comparaison: %Comparaison{
              confirmed: nil,
              deaths: nil,
              recovered: nil,
              active: nil,
              incidence_rate: nil,
              case_fatality_ratio: nil
            }

  @doc """
  Given a date, performs an analysis on it.
  """
  def analysis(date) do
    term = [province_state: "Victoria", country_region: "Australia"]

    previous =
      Date.add(date, -1)
      |> Records.get()
      |> Records.find(term)

    current =
      date
      |> Records.get()
      |> Records.find(term)

    %CovidData{
      yesterday_today_comparaison: Comparaison.between(previous, current)
    }
  end
end
