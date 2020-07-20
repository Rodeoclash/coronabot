defmodule Coronabot.CovidData do
  @moduledoc """
  Figure out data about Covid
  """

  alias __MODULE__
  alias Coronabot.{CovidData.Records, CovidData.Records.Comparaison, CovidData.Records.Record}

  @enforce_keys [
    :today,
    :yesterday_today_comparaison
  ]

  defstruct today: %Record{
              province_state: nil,
              country_region: nil,
              last_update: nil,
              lat: nil,
              lng: nil,
              confirmed: nil,
              deaths: nil,
              recovered: nil,
              active: nil,
              combined_key: nil,
              incidence_rate: nil,
              case_fatality_ratio: nil
            },
            yesterday_today_comparaison: %Comparaison{
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

    yesterday =
      Date.add(date, -1)
      |> Records.get()
      |> Records.find(term)

    today =
      date
      |> Records.get()
      |> Records.find(term)

    %CovidData{
      today: today,
      yesterday_today_comparaison: Comparaison.between(yesterday, today)
    }
  end
end
