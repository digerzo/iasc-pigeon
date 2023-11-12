defmodule IASCPigeon.MixProject do
  use Mix.Project

  def project do
    [
      app: :iascpigeon,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex, :wx, :observer, :runtime_tools],
      # mod: {IASCPigeon.Application, []}
      mod: {Chat, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.3"},
      {:horde, "~> 0.8.3"}
    ]
  end
end
