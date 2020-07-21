defmodule Coronabot.State.PublishResults do
  alias Coronabot.{CovidData, State.LatestDataDate, SlackBot}
  alias __MODULE__
  use GenServer

  # Client

  def start_link(default) when is_list(default) do
    GenServer.start_link(PublishResults, default, name: PublishResults)
  end

  # Server (callbacks)

  @impl true
  def init(reschedule_in: reschedule_in) do
    {:ok, %{last_published_at: nil, reschedule_in: reschedule_in}, {:continue, :work}}
  end

  @impl true
  def handle_continue(:work, state) do
    handle_info(:work, state)
  end

  @impl true
  def handle_info(:work, state) do
    state =
      if can_publish?(state) == true do
        LatestDataDate.latest()
        |> CovidData.analysis()
        |> CovidData.message()
        |> SlackBot.message()

        %{state | last_published_at: Date.utc_today()}
      else
        state
      end

    requeue(state[:reschedule_in])

    {:noreply, state}
  end

  @doc """
  Determines the time to scan for he latest date again. If we're < 2 hours from the check, check again in 20 hours from the original check
  """
  def requeue(milliseconds) do
    Process.send_after(self(), :work, milliseconds)
  end

  def can_publish?(state) do
    data_ready?() === true && (has_not_published?(state) || out_of_date?(state))
  end

  def data_ready? do
    LatestDataDate.ready?() == true
  end

  def has_not_published?(state) do
    is_nil(state[:last_published_at]) == true
  end

  def out_of_date?(state) do
    Date.diff(LatestDataDate.latest(), state[:last_published_at]) > 0
  end
end
