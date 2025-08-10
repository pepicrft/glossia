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
      description: description(),
      releases: releases()
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
      extra_applications: [:logger],
      mod: {GlossiaDaemon.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:quokka, "~> 2.10", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.2"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:burrito, "~> 1.0"}
    ]
  end

  defp releases do
    [
      glossia_daemon: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            linux_x86_64: [os: :linux, cpu: :x86_64],
            linux_aarch64: [os: :linux, cpu: :aarch64]
          ],
          arg: [GlossiaDaemon.CLI, :main, []]
        ]
      ]
    ]
  end
end
