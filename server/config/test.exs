import Config

config :coronabot,
  connect_slack: false,
  http_client: HTTPoisonMock,
  children: []
