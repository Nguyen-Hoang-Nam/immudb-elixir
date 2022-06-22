defmodule ImmudbElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :immudb_elixir,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:grpc, git: "https://github.com/Nguyen-Hoang-Nam/grpc.git"},
      {:cowlib, "~> 2.11.0"},
      {:protobuf, "~> 0.8.0"},
      {:google_protos, "~> 0.1"}
    ]
  end
end
