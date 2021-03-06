import Config

config :coronabot,
  connect_slack: true,
  http_client: HTTPoison

config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]

import_config "#{Mix.env()}.exs"
