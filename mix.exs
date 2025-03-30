defmodule Glossia.MixProject do
  use Mix.Project

  @version "0.3.0"
  @elixir_version_requirement "~> 1.17.3"

  def project do
    [
      app: :glossia,
      version: @version,
      elixir: @elixir_version_requirement,
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),
      description: description()
    ]
  end

  defp description do
    ~S"""
    A Phoenix application to create a language hubs for organizations.
    """
  end

  defp package do
    [
      files: ["lib", "priv", "config", "assets", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Pedro Piñera Buendía"],
      licenses: ["MPL-2.0"],
      links: %{"GitHub" => "https://github.com/glossia/glossia"}
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Glossia.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.20"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2"},
      {:phoenix_live_view, "~> 1.0.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8"},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.4", only: [:dev, :test], runtime: false},
      {:hackney, "~> 1.23"},
      {:gen_smtp, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild glossia"],
      "assets.deploy": [
        "esbuild glossia --minify",
        "phx.digest"
      ]
    ]
  end

  defp elixir do
    "mise.toml"
    |> File.read!()
    |> String.split("\n")
    |> Enum.find(fn line -> String.contains?(line, "elixir =") end)
    |> case do
      nil ->
        "Version not found"

      line ->
        # Extract the version number between quotes
        ~r/elixir = "(.+?)"/
        |> Regex.run(line)
        |> Enum.at(1)
    end
  end
end
