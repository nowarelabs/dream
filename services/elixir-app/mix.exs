defmodule ElixirApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_app,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirApp.Application, []}
    ]
  end
end
