defmodule Glossia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GlossiaWeb.Telemetry,
      Glossia.Repo,
      {DNSCluster, query: Application.get_env(:glossia, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Glossia.PubSub},
      {NodeJS.Supervisor, [path: LiveVue.SSR.NodeJS.server_path(), pool_size: 4]},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Glossia.Finch},
      # Start a worker by calling: Glossia.Worker.start_link(arg)
      # {Glossia.Worker, arg},
      # Start to serve requests, typically the last entry
      GlossiaWeb.Endpoint
    ]

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
