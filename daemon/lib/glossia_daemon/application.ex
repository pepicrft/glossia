defmodule GlossiaDaemon.Application do
  @moduledoc """
  The GlossiaDaemon Application supervisor.
  
  This module starts the necessary processes for the daemon library
  when used as a standalone application.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: GlossiaDaemon.Finch}
    ]

    opts = [strategy: :one_for_one, name: GlossiaDaemon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end