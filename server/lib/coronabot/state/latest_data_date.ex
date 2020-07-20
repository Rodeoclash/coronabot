defmodule Coronabot.State.LatestDataDate do
  alias Coronabot.{CovidData.Source}
  alias __MODULE__
  use GenServer

  # Client

  def start_link(default) when is_list(default) do
    GenServer.start_link(LatestDataDate, default, name: LatestDataDate)
  end

  @doc """
  We're ready to use the latest date once we've scanned the latest available data date.
  """
  def ready?() do
    GenServer.call(LatestDataDate, :ready?)
  end

  @doc """
  Fetch the latest known date
  """
  def latest() do
    GenServer.call(LatestDataDate, :latest)
  end

  # Server (callbacks)

  @impl true
  def init(initial: initial, reschedule_in: reschedule_in) do
    {:ok, %{initial: initial, latest: nil, reschedule_in: reschedule_in}, {:continue, :work}}
  end

  @impl true
  def handle_continue(:work, state) do
    handle_info(:work, state)
  end

  @impl true
  def handle_call(:ready?, _from, %{latest: latest} = state) do
    {:reply, is_nil(latest) === false, state}
  end

  @impl true
  def handle_call(:latest, _from, %{latest: latest} = state) do
    {:reply, latest, state}
  end

  @impl true
  def handle_info(:work, state) do
    latest = start_date_from_state(state) |> Source.scan()
    new_state = %{state | latest: latest}

    requeue(state[:reschedule_in])

    {:noreply, new_state}
  end

  @doc """
  Determines the time to scan for he latest date again. If we're < 2 hours from the check, check again in 20 hours from the original check
  """
  def requeue(milliseconds) do
    Process.send_after(self(), :work, milliseconds)
  end

  @doc """
  Given a date, produces a URL we can use to fetch the current days data.

  ## Examples

      iex> Coronabot.State.LatestDataDate.start_date_from_state(%{latest: nil, initial: ~D[2020-07-18]})
      ~D[2020-07-18]

      iex> Coronabot.State.LatestDataDate.start_date_from_state(%{latest: ~D[2020-07-19], initial: ~D[2020-07-18]})
      ~D[2020-07-19]

  """
  def start_date_from_state(state) do
    if is_nil(state[:latest]) == true do
      state[:initial]
    else
      state[:latest]
    end
  end
end
