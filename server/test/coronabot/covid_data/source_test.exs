defmodule Coronabot.CovidData.SourceTest do
  alias Coronabot.{
    CovidData.Source
  }

  import Mox
  use ExUnit.Case

  doctest Source

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
end
