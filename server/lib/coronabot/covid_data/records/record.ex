defmodule Coronabot.CovidData.Records.Record do
  @moduledoc """
  Represents an individual covid data record
  """

  alias __MODULE__

  @enforce_keys [
    :province_state,
    :country_region,
    :last_update,
    :lat,
    :lng,
    :confirmed,
    :deaths,
    :recovered,
    :active,
    :combined_key,
    :incidence_rate,
    :case_fatality_ratio
  ]

  defstruct province_state: nil,
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

  def new([
        _,
        _,
        province_state,
        country_region,
        last_update,
        lat,
        lng,
        confirmed,
        deaths,
        recovered,
        active,
        combined_key,
        incidence_rate,
        case_fatality_ratio
      ]) do
    %Record{
      province_state: province_state,
      country_region: country_region,
      last_update: NaiveDateTime.from_iso8601!(last_update),
      lat: lat,
      lng: lng,
      confirmed: String.to_integer(confirmed),
      deaths: String.to_integer(deaths),
      recovered: String.to_integer(recovered),
      active: String.to_integer(active),
      combined_key: combined_key,
      incidence_rate: String.to_float(incidence_rate),
      case_fatality_ratio: String.to_float(case_fatality_ratio)
    }
  end
end
