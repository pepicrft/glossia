defmodule GlossiaDaemonTest do
  use ExUnit.Case
  doctest GlossiaDaemon

  test "execute_task with shell command" do
    task = %{type: :shell, command: "echo 'test'"}
    result = GlossiaDaemon.execute_task(task)
    assert {:ok, output} = result
    assert output =~ "test"
  end

  test "execute_task with unknown type" do
    task = %{type: :unknown}
    result = GlossiaDaemon.execute_task(task)
    assert {:error, :unknown_task_type} = result
  end
end