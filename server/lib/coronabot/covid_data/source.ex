defmodule Coronabot.CovidData.Source do
  @moduledoc """
  Used to fetch covid data
  """

  @http_client Application.get_env(:coronabot, :http_client)

  @doc """
  Scan until we find a usable date. If the given date exists, start working fowards. If it doesn't, work backwards.

  It is intended that this gets "todays" date then figures out what the latest data is.
  """
  def scan(date) do
    case exists?(date) do
      true -> scan_forward(Date.add(date, 1), date)
      false -> scan_backward(Date.add(date, -1))
    end
  end

  @doc """
  Scan forward until future date is not found, return the last known date that existed.
  """
  def scan_forward(date, previous_date) do
    case exists?(date) do
      true -> scan_forward(Date.add(date, 1), date)
      false -> previous_date
    end
  end

  @doc """
  Scan backward until a date is found
  """
  def scan_backward(date) do
    case exists?(date) do
      true -> date
      false -> scan_backward(Date.add(date, -1))
    end
  end

  @doc """
  Does data exist for the given date?
  """
  def exists?(date) do
    case get(date) do
      {:ok, %HTTPoison.Response{status_code: 200}} -> true
      {:ok, %HTTPoison.Response{status_code: 404}} -> false
    end
  end

  @doc """
  Fetches the data for the given date
  """
  def get(date) do
    day = date.day |> Integer.to_string() |> String.pad_leading(2, "0")
    month = date.month |> Integer.to_string() |> String.pad_leading(2, "0")

    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/#{
      month
    }-#{day}-#{date.year}.csv"
    |> @http_client.get()
  end
end
