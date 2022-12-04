defmodule GeneticExDev.OneMaxEx do
  alias GeneticExDev.Genetic

  def run(caller, status_interval) do
    conf = %{
      caller: caller,
      status_interval: status_interval,
      genotype: fn -> for _ <- 1..1000, do: Enum.random(0..1) end,
      fitness_fn: fn chromosome -> Enum.sum(chromosome) end,
      max_fitness: 1000,
    }

    Genetic.run(conf)
  end
end
