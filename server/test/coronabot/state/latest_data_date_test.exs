defmodule Coronabot.State.LatestDataDateTest do
  alias Coronabot.State.LatestDataDate
  import Mox
  use ExUnit.Case, async: false

  doctest LatestDataDate

  @initial ~D[2020-07-18]
  @reschedule_in 100
  @state %{initial: @initial, reschedule_in: @reschedule_in, latest: nil}

  setup :set_mox_global
  setup :verify_on_exit!

  def mock_source_scan do
    HTTPoisonMock
    |> expect(:get, fn path ->
      assert path ==
               "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-18-2020.csv"

      {:ok, %HTTPoison.Response{status_code: 200}}
    end)
    |> expect(:get, fn path ->
      assert path ==
               "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/07-19-2020.csv"

      {:ok, %HTTPoison.Response{status_code: 404}}
    end)
  end

  describe "start_link/1" do
    test "it peforms expected startup" do
      mock_source_scan()

      assert {:ok, pid} =
               LatestDataDate.start_link(initial: @initial, reschedule_in: @reschedule_in)

      assert is_pid(pid)
      GenServer.stop(pid)
      refute Process.alive?(pid)
    end
  end

  describe "ready?/1" do
    test "it peforms expected startup" do
      mock_source_scan()

      assert {:ok, pid} =
               LatestDataDate.start_link(initial: @initial, reschedule_in: @reschedule_in)

      assert true == LatestDataDate.ready?()

      GenServer.stop(pid)
      refute Process.alive?(pid)
    end
  end

  describe "init/1" do
    test "returns expected latest value" do
      assert {:ok,
              %{
                initial: @initial,
                latest: nil,
                reschedule_in: @reschedule_in
              },
              {:continue, :work}} ==
               LatestDataDate.init(initial: @initial, reschedule_in: @reschedule_in)
    end
  end

  describe "handle_call/3 - ready?" do
    test "returns expected latest value" do
      assert {:reply, false, @state} == LatestDataDate.handle_call(:ready?, self(), @state)
    end
  end

  describe "handle_call/3 - latest" do
    test "returns expected latest value" do
      assert {:reply, nil, @state} == LatestDataDate.handle_call(:latest, self(), @state)
    end
  end

  describe "handle_info/2 - work" do
    test "correctly performs work" do
      mock_source_scan()

      assert {:noreply, %{initial: @initial, latest: @initial}} =
               LatestDataDate.handle_info(:work, @state)

      :timer.sleep(@reschedule_in + 100)
      assert_received :work
    end
  end

  describe "requeue/1" do
    test "receives work message after expected time" do
      LatestDataDate.requeue(@reschedule_in)
      :timer.sleep(@reschedule_in + 100)
      assert_received :work
    end
  end
end
