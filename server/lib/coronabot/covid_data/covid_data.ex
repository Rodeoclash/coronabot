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

  defstruct date: nil,
            today: %Record{
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
      date: date,
      today: today,
      yesterday_today_comparaison: Comparaison.between(yesterday, today)
    }
  end

  def message(data) do
    ~s[:newspaper: *The Daily Covid: #{Date.to_string(data.date)} UTC*
#{entry("Confirmed", data, :confirmed)}
#{entry("Deaths", data, :deaths)}
#{entry("Recovered", data, :recovered)}
#{entry("Active", data, :active)}]
  end

  def entry(label, data, field) do
    value = Map.get(data.today, field)
    change = Map.get(data.yesterday_today_comparaison, field)

    "#{label}: #{value} (_#{format_change(change)}_)"
  end

  def format_change(n) when n > 0 do
    "+#{n}"
  end

  def format_change(n) when n <= 0 do
    "#{n}"
  end
end
