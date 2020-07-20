ExUnit.start()
Mox.defmock(HTTPoisonMock, for: HTTPoison.Base)
Code.require_file("fixtures.exs", __DIR__)
