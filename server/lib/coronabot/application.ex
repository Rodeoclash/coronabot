defmodule Coronabot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = Application.get_env(:coronabot, :children)
    opts = [strategy: :one_for_one, name: Coronabot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
