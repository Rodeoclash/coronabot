defmodule Coronabot.SlackBotTest do
  alias Coronabot.SlackBot
  use ExUnit.Case, async: false

  doctest SlackBot

  describe "start_link/1" do
    test "it peforms expected startup" do
      assert {:ok, pid} = SlackBot.start_link([])

      assert is_pid(pid)
      GenServer.stop(pid)
      refute Process.alive?(pid)
    end
  end

  describe "ready?/1" do
    test "false on boot" do
      assert {:ok, pid} = SlackBot.start_link([])

      refute SlackBot.ready?()

      GenServer.stop(pid)
      refute Process.alive?(pid)
    end

    test "can be made ready" do
      assert {:ok, pid} = SlackBot.start_link([])

      assert SlackBot.ready!()
      assert SlackBot.ready?()

      GenServer.stop(pid)
      refute Process.alive?(pid)
    end
  end

  describe "init/1" do
    test "returns expected latest value" do
      assert {:ok,
              %{
                rtm: nil,
                ready: false
              },
              {:continue, :setup}} ==
               SlackBot.init([])
    end
  end

  describe "handle_call/3 - ready?" do
    test "returns expected latest value" do
      assert {:reply, false, %{ready: false}} ==
               SlackBot.handle_call(:ready?, self(), %{ready: false})
    end
  end

  describe "handle_call/3 - ready!" do
    test "returns expected latest value" do
      assert {:noreply, %{ready: true}} == SlackBot.handle_cast(:ready!, %{ready: false})
    end
  end
end
