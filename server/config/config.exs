import Config

config :coronabot,
  http_client: HTTPoison

import_config "#{Mix.env()}.exs"
