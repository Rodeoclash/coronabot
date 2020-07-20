import Config

config :coronabot,
  connect_slack: true,
  http_client: HTTPoison

import_config "#{Mix.env()}.exs"
