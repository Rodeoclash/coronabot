defmodule Coronabot.Slack do
  @moduledoc """
  Thin wrapper around Slack.
  """

  @http_client Application.get_env(:coronabot, :http_client)

  @doc """
  Send a message to Slack
  """
  def message(content) do
    @http_client.post(
      System.get_env("SLACK_WEBHOOK_URL"),
      '{"text": "#{content}"}',
      [{"Content-Type", "application/json"}]
    )
  end
end
