defmodule Coronabot.CovidData.ComparaisonTest do
  alias Coronabot.{CovidData.Records.Comparaison, CovidData.Records.Record}
  use ExUnit.Case

  doctest Comparaison

  describe "between/1" do
    test "calculates the delta correctly" do
      record_past = %Record{
        province_state: "Victoria",
        country_region: "Australia",
        last_update: ~N[2020-07-18 04:34:45],
        lat: "-37.8136",
        lng: "144.9631",
        confirmed: 5343,
        deaths: 30,
        recovered: 2704,
        active: 2605,
        combined_key: "Victoria, Australia",
        incidence_rate: 79.74028265886362,
        case_fatality_ratio: 0.5351578554081824
      }

      record_future = %Record{
        province_state: "Victoria",
        country_region: "Australia",
        last_update: ~N[2020-07-18 04:34:45],
        lat: "-37.8136",
        lng: "144.9631",
        confirmed: 5353,
        deaths: 34,
        recovered: 2709,
        active: 2610,
        combined_key: "Victoria, Australia",
        incidence_rate: 80.74028265886362,
        case_fatality_ratio: 0.6351578554081824
      }

      assert %Comparaison{
               confirmed: 10,
               deaths: 4,
               recovered: 5,
               active: 5,
               incidence_rate: 1.0,
               case_fatality_ratio: 0.09999999999999998
             } == Comparaison.between(record_past, record_future)
    end
  end
end
