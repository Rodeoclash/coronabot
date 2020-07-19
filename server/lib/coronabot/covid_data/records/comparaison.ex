defmodule Coronabot.CovidData.Records.Comparaison do
  @moduledoc """
  Compare two records
  """

  alias __MODULE__

  @enforce_keys [
    :confirmed,
    :deaths,
    :recovered,
    :active,
    :incidence_rate,
    :case_fatality_ratio
  ]

  defstruct confirmed: nil,
            deaths: nil,
            recovered: nil,
            active: nil,
            incidence_rate: nil,
            case_fatality_ratio: nil

  @doc """
  Compare two records and collect the delta between them.
  """
  def between(record_1, record_2) do
    %Comparaison{
      confirmed: record_2.confirmed - record_1.confirmed,
      deaths: record_2.deaths - record_1.deaths,
      recovered: record_2.recovered - record_1.recovered,
      active: record_2.active - record_1.active,
      incidence_rate: record_2.incidence_rate - record_1.incidence_rate,
      case_fatality_ratio: record_2.case_fatality_ratio - record_1.case_fatality_ratio
    }
  end
end
