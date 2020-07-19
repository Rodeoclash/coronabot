defmodule Coronabot.CovidData.Records do
  @moduledoc """
  Represents a collection of covid data records.
  """

  alias Coronabot.{CovidData.Records.Record, CovidData.Source}
  alias NimbleCSV.RFC4180, as: CSV
  alias __MODULE__

  defstruct data: []

  @doc """
  Fetch dats for the given day as a record set.
  """
  def get(date) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- Source.get(date),
         do: new(body)
  end

  @doc """
  Parses the fetched data into an array of tuples.

  ## Examples

      iex> Coronabot.CovidData.Records.new("name,age\\njohn,27")
      %Records{data: [["john","27"]]}

  """
  def new(data) do
    %Records{data: CSV.parse_string(data)}
  end

  @doc """
  Given records, find a particular entry
  """
  def find(records, province_state: province_state, country_region: country_region) do
    records
    |> Map.get(:data)
    |> Enum.find(fn [
                      _,
                      _,
                      record_province_state,
                      record_country_region,
                      _,
                      _,
                      _,
                      _,
                      _,
                      _,
                      _,
                      _,
                      _,
                      _
                    ] ->
      record_province_state == province_state && record_country_region == country_region
    end)
    |> Record.new()
  end
end
