defmodule GlossiaDaemonTest do
  use ExUnit.Case
  doctest GlossiaDaemon

  test "hello/0 returns :world" do
    assert GlossiaDaemon.hello() == :world
  end
end