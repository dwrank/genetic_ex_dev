defmodule GeneticExDev.MixProject do
  use Mix.Project

  def project do
    [
      app: :genetic_ex_dev,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      rustler_crates: rustler_crates(),
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
      {:rustler, "~> 0.26.0"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  # optional, always do a release build
  defp rustler_crates do
    [genetic_max_rust: [
      path: "native/genetic_rust",
      mode: :release, #(if Mix.env == :prod, do: :release, else: :debug),
    ]]
  end
end
