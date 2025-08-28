defmodule Glossia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    flame_parent = FLAME.Parent.get()

    children =
      [
        !flame_parent && GlossiaWeb.Telemetry,
        !flame_parent && Glossia.Repo,
        !flame_parent &&
          {DNSCluster, query: Application.get_env(:glossia, :dns_cluster_query) || :ignore},
        !flame_parent && {Phoenix.PubSub, name: Glossia.PubSub},
        # Start the Finch HTTP client for sending emails
        !flame_parent && {Finch, name: Glossia.Finch},
        # Start a worker by calling: Glossia.Worker.start_link(arg)
        # {Glossia.Worker, arg},
        # Start to serve requests, typically the last entry
        !flame_parent && GlossiaWeb.Endpoint,
        {FLAME.Pool,
         name: Glossia.AIPool, min: 0, max: 10, max_concurrency: 5, idle_shutdown_after: 60_000, log: :debug}
      ]
      |> Enum.filter(& &1)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Glossia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GlossiaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
