defmodule GeneticExDev.OneMaxEx do
  alias GeneticExDev.Genetic
  alias GeneticExDev.GeneticRust
  alias GeneticExDev.GeneticMix
  alias GeneticExDev.Types.Chromosome

  def run(caller, status_interval) do
    conf = %{
      caller: caller,
      status_interval: status_interval,
      genotype: fn -> %Chromosome{genes: (for _ <- 1..1000, do: Enum.random(0..1))} end,
      fitness_fn: fn chromosome -> Enum.sum(chromosome.genes) end,
      max_fitness: 1000,
    }

    GeneticMix.run(conf)
  end
end
