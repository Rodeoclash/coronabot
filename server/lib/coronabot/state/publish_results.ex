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
        latest_data_date = LatestDataDate.latest()
        covid_data = CovidData.analysis(latest_data_date)

        :timer.sleep(15000)

        SlackBot.message(~s[:newspaper: *The Daily Covid*
#{entry("Confirmed", covid_data, :confirmed)}
#{entry("Deaths", covid_data, :deaths)}
#{entry("Recovered", covid_data, :recovered)}
#{entry("Active", covid_data, :active)}])

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

  def entry(label, data, field) do
    value = Map.get(data.today, field)
    change = Map.get(data.yesterday_today_comparaison, field)

    "#{label}: #{value} (_#{format_change(change)}_)"
  end

  def format_change(n) when n > 0 do
    "+#{n}"
  end

  def format_change(n) when n <= 0 do
    "#{n}"
  end
end
