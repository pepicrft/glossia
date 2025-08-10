defmodule GlossiaDaemon.MixProject do
  use Mix.Project

  @version "0.1.0"
  @elixir_version_requirement "~> 1.18.4"

  def project do
    [
      app: :glossia_daemon,
      version: @version,
      elixir: @elixir_version_requirement,
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description()
    ]
  end

  defp description do
    ~S"""
    A daemon library for running operations in remote environments for Glossia.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Pedro Piñera Buendía"],
      links: %{"GitHub" => "https://github.com/glossia/glossia"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:finch, "~> 0.13"},
      {:telemetry, "~> 1.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end