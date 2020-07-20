defmodule Coronabot.MixProject do
  use Mix.Project

  def project do
    [
      app: :coronabot,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        coronabot: [
          include_executables_for: [:unix],
          applications: [
            coronabot: :permanent,
            runtime_tools: :permanent
          ]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Coronabot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:mox, "~> 0.5", only: :test},
      {:nimble_csv, "~> 0.7"},
      {:slack, "~> 0.23.5"}
    ]
  end
end
