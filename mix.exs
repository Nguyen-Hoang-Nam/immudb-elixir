defmodule ImmudbElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :immudb_elixir,
      version: "0.2.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Elixir client for ImmuDB"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:grpc, "~> 0.5.0"},
      {:cowlib, "~> 2.13.0"},
      {:protobuf, "~> 0.9.0"},
      {:google_protos, "~> 0.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    %{
      maintainers: ["Nguyen Hoang Nam"],
      licenses: ["Apache 2"],
      links: %{"GitHub" => "https://github.com/Nguyen-Hoang-Nam/immudb-elixir"},
      files: ~w(mix.exs README.md lib config LICENSE .formatter.exs)
    }
  end
end
