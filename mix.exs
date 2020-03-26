defmodule Ecto.Sort.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_sort,
      version: "0.0.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      name: "Ecto Sort",
      source_url: "https://github.com/revelrylabs/ecto_sort",
      homepage_url: "https://github.com/revelrylabs/ecto_sort",
      docs: [main: "readme", extras: ["README.md"]],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Creates a macro for ecto context modules to use to apply order_by expressions."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.4.1", only: [:test]},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test]},
      {:mix_test_watch, "~> 0.8", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: [:test]},
      {:credo, ">= 0.5.1", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE", "CHANGELOG.md"],
      maintainers: ["Revelry Labs"],
      licenses: ["MIT"],
      links: %{
        github: "https://github.com/revelrylabs/ecto_sort"
      },
      build_tools: ["mix"]
    ]
  end
end
