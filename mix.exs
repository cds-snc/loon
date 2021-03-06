defmodule Loon.MixProject do
  use Mix.Project

  def project do
    [
      app: :loon,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Loon.Application, []},
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
      {:aws, "~> 0.5.0"},
      {:gettext, "~> 0.11"},
      {:google_api_big_query, "~> 0.2.0"},
      {:goth, "~> 0.8.0"},
      {:httpoison, "~> 1.4", override: true},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.1"},
      {:tzdata, "~> 1.0.0-rc.1", override: true}
    ]
  end
end
