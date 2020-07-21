defmodule Coronabot.CovidData.CovidDataTest do
  alias Coronabot.{
    CovidData,
    CovidData.Records.Comparaison,
    CovidData.Records.Record,
    CovidData.Source
  }

  import Mox
  use ExUnit.Case

  doctest Source

  @data %CovidData{
    date: ~D[2020-07-18],
    today: %Record{
      province_state: nil,
      country_region: nil,
      last_update: nil,
      lat: nil,
      lng: nil,
      confirmed: 15,
      deaths: 14,
      recovered: 20,
      active: 22,
      combined_key: nil,
      incidence_rate: 0.2,
      case_fatality_ratio: 0.3
    },
    yesterday_today_comparaison: %Comparaison{
      confirmed: 4,
      deaths: -2,
      recovered: 6,
      active: 20,
      incidence_rate: 0.5,
      case_fatality_ratio: 0.1
    }
  }

  setup :verify_on_exit!

  describe "message/1" do
    test "formats as expected" do
      assert ":newspaper: *The Daily Covid: 2020-07-18 UTC*\nConfirmed: 15 (_+4_)\nDeaths: 14 (_-2_)\nRecovered: 20 (_+6_)\nActive: 22 (_+20_)" == CovidData.message(@data)
    end
  end

  describe "entry/1" do
    test "formats as expected" do
      assert "Confirmed: 14 (_-2_)" == CovidData.entry("Confirmed", @data, :deaths)
    end
  end

  describe "format_change/1" do
    test "positive" do
      assert "+1" == CovidData.format_change(1)
    end

    test "negative" do
      assert "-1" == CovidData.format_change(-1)
    end

    test "zero" do
      assert "0" == CovidData.format_change(0)
    end
  end
end
