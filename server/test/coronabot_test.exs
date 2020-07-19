defmodule CoronabotTest do
  use ExUnit.Case
  doctest Coronabot

  test "greets the world" do
    assert Coronabot.hello() == :world
  end
end
