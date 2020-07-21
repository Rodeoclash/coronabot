defmodule Coronabot.CovidData.SourceTest do
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

  describe "scan/1" do
    test "when given date exists" do
      HTTPoisonMock
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-18-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 200}}
      end)
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-19-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 200}}
      end)
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-20-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 404}}
      end)

      assert ~D[2020-07-19] == Source.scan(~D[2020-07-18])
    end

    test "when given date does not exist" do
      HTTPoisonMock
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-17-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 404}}
      end)
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-16-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 200}}
      end)

      assert ~D[2020-07-16] == Source.scan(~D[2020-07-17])
    end
  end

  describe "scan_forward/1" do
    test "finds the correct date" do
      HTTPoisonMock
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-18-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 200}}
      end)
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-19-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 200}}
      end)
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-20-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 404}}
      end)

      assert ~D[2020-07-19] == Source.scan_forward(~D[2020-07-18], ~D[2020-07-17])
    end
  end

  describe "scan_backward/1" do
    test "finds the correct date" do
      HTTPoisonMock
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-18-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 404}}
      end)
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-17-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 404}}
      end)
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-16-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 200}}
      end)

      assert ~D[2020-07-16] == Source.scan_backward(~D[2020-07-18])
    end
  end

  describe "exists?/1" do
    test "true when data exists" do
      HTTPoisonMock
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-18-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 200}}
      end)

      assert true == Source.exists?(~D[2020-07-18])
    end

    test "false when data does not exist" do
      HTTPoisonMock
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-18-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 404}}
      end)

      assert false == Source.exists?(~D[2020-07-18])
    end
  end

  describe "get/1" do
    test "produces a get request against the expected url" do
      HTTPoisonMock
      |> expect(:get, fn path ->
        assert path ==
                 "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-18-2020.csv"

        {:ok, %HTTPoison.Response{status_code: 200}}
      end)

      assert true == Source.exists?(~D[2020-07-18])
    end
  end

  describe "message/1" do
    test "formats as expected" do
      assert ":newspaper: *The Daily Covid: 2020-07-18*\nConfirmed: 15 (_+4_)\nDeaths: 14 (_-2_)\nRecovered: 20 (_+6_)\nActive: 22 (_+20_)" == CovidData.message(@data)
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
