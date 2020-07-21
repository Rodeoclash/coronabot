defmodule Coronabot.SlackBot.Rtm do
  alias Coronabot.{SlackBot}
  use Slack

  def handle_connect(_slack, state) do
    SlackBot.ready!()
    {:ok, state}
  end

  def handle_event(_message = %{type: "message"}, _slack, state) do
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    send_message(text, channel, slack)

    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}
end
