defmodule Coronabot.State.PublishResultsTest do
  alias Coronabot.{State.PublishResults, State.LatestDataDate}
  import Mox
  use ExUnit.Case, async: false

  doctest PublishResults

  @reschedule_in 100

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

      assert {:ok, pid} = LatestDataDate.start_link(initial: ~D[2020-07-18], reschedule_in: 1000)

      assert {:ok, pid} = PublishResults.start_link(reschedule_in: @reschedule_in)

      assert is_pid(pid)
      GenServer.stop(pid)
      refute Process.alive?(pid)
    end
  end

  describe "init/1" do
    test "returns expected latest value" do
      assert {:ok,
              %{
                last_published_at: nil,
                reschedule_in: @reschedule_in
              },
              {:continue, :work}} ==
               PublishResults.init(reschedule_in: @reschedule_in)
    end
  end

  describe "handle_info/2 - work" do
    test "when can publish and has not published" do
      mock_source_scan()

      assert {:ok, pid} = LatestDataDate.start_link(initial: ~D[2020-07-18], reschedule_in: 1000)

      assert {:noreply, %{last_published_at: last_published_at, reschedule_in: @reschedule_in}} =
               PublishResults.handle_info(:work, %{
                 last_published_at: nil,
                 reschedule_in: @reschedule_in
               })

      assert last_published_at == Date.utc_today()

      :timer.sleep(@reschedule_in + 100)
      assert_received :work
    end

    test "when can publish, has already published but is out of date" do
      mock_source_scan()

      assert {:ok, pid} = LatestDataDate.start_link(initial: ~D[2020-07-18], reschedule_in: 1000)

      assert {:noreply, %{last_published_at: last_published_at, reschedule_in: @reschedule_in}} =
               PublishResults.handle_info(:work, %{
                 last_published_at: ~D[2020-07-17],
                 reschedule_in: @reschedule_in
               })

      assert last_published_at == Date.utc_today()

      :timer.sleep(@reschedule_in + 100)
      assert_received :work
    end

    test "when can publish, when has already published and is not out of date" do
      mock_source_scan()

      assert {:ok, pid} = LatestDataDate.start_link(initial: ~D[2020-07-18], reschedule_in: 1000)

      assert {:noreply, %{last_published_at: ~D[2020-07-18], reschedule_in: @reschedule_in}} =
               PublishResults.handle_info(:work, %{
                 last_published_at: ~D[2020-07-18],
                 reschedule_in: @reschedule_in
               })

      :timer.sleep(@reschedule_in + 100)
      assert_received :work
    end
  end

  describe "has_not_published?/1" do
    test "true when last published is nil" do
      assert PublishResults.has_not_published?(%{
               last_published_at: nil
             })
    end
  end

  describe "can_publish?/1" do
    test "true when latest data date is ready" do
      mock_source_scan()

      assert {:ok, pid} = LatestDataDate.start_link(initial: ~D[2020-07-18], reschedule_in: 1000)

      assert PublishResults.can_publish?()

      GenServer.stop(pid)
      refute Process.alive?(pid)
    end

    test "true when latest data is older than published date" do
      mock_source_scan()

      assert {:ok, pid} = LatestDataDate.start_link(initial: ~D[2020-07-18], reschedule_in: 1000)

      assert PublishResults.out_of_date?(%{
               last_published_at: ~D[2020-07-17]
             })

      GenServer.stop(pid)
      refute Process.alive?(pid)
    end
  end

  describe "out_of_date?/1" do
    test "false when date is the same" do
      mock_source_scan()

      assert {:ok, pid} = LatestDataDate.start_link(initial: ~D[2020-07-18], reschedule_in: 1000)

      refute PublishResults.out_of_date?(%{
               last_published_at: ~D[2020-07-18]
             })

      GenServer.stop(pid)
      refute Process.alive?(pid)
    end

    test "true when latest data is older than published date" do
      mock_source_scan()

      assert {:ok, pid} = LatestDataDate.start_link(initial: ~D[2020-07-18], reschedule_in: 1000)

      assert PublishResults.out_of_date?(%{
               last_published_at: ~D[2020-07-17]
             })

      GenServer.stop(pid)
      refute Process.alive?(pid)
    end
  end
end
