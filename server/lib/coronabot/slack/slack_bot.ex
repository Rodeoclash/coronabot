defmodule Coronabot.SlackBot do
  @moduledoc """
  Thin wrapper around the Slack module. Mostly proves a better API and stores pid state for the linked Slack process.
  """

  alias __MODULE__
  alias Coronabot.{SlackBot.Rtm}
  use GenServer

  # Client

  def start_link(default) when is_list(default) do
    GenServer.start_link(SlackBot, default, name: SlackBot)
  end

  @doc """
  Can the bot accept messages yet?
  """
  def ready? do
    GenServer.call(SlackBot, :ready?)
  end

  @doc """
  Indicate that the bot is ready for messages
  """
  def ready! do
    GenServer.cast(SlackBot, :ready!)
  end

  @doc """
  Send a message to Slack
  """
  def message(content) do
    GenServer.cast(SlackBot, {:message, content})
  end

  # Server (callbacks)

  @impl true
  def init(_init_args) do
    {:ok, %{rtm: nil, ready: false}, {:continue, :setup}}
  end

  @impl true
  def handle_continue(:setup, state) do
    if Application.get_env(:coronabot, :connect_slack) === true do
      {:ok, rtm} = Slack.Bot.start_link(Rtm, [], System.get_env("SLACK_BOT_TOKEN"))
      {:noreply, %{state | rtm: rtm}}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_call(:ready?, _from, %{ready: ready} = state) do
    {:reply, ready, state}
  end

  @impl true
  def handle_cast(:ready!, state) do
    {:noreply, %{state | ready: true}}
  end

  @impl true
  def handle_cast({:message, content}, %{rtm: rtm} = state) do
    send(rtm, {:message, content, "#coronabot-test"})
    {:noreply, state}
  end
end