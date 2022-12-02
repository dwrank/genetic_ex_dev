defmodule GeneticExDev.Genetic do
  def run(conf) do
    initialize(conf)
    |> evolve(conf)
  end

  def initialize(conf) do
    for _ <- 1..100, do: conf.genotype.()
  end

  def evolve(population, conf, i \\ 1) do
    population = evaluate(population, conf)
    best = hd(population)
    fitness = conf.fitness_fn.(best)

    if fitness == conf.max_fitness do
      send_status(conf, i, best, fitness, :done)
      best
    else
      if rem(i, conf.status_interval) == 0 do
        send_status(conf, i, best, fitness, :running)
      end

      population
      |> select()
      |> crossover()
      |> mutation()
      |> evolve(conf, i+1)
    end
  end

  def send_status(conf, i, best, fitness, state) do
    status = %{pid: self(), iters: i, best: best, fitness: fitness, state: state}
    send(conf.caller, status)
  end

  def evaluate(population, conf) do
    Enum.sort_by(population, conf.fitness_fn, &>=/2)
  end

  def select(population) do
    population
    |> Stream.chunk_every(2)
    |> Stream.map(&List.to_tuple/1)
  end

  def crossover(stream) do
    Enum.reduce(stream, [],
      fn {p1, p2}, acc ->
        cx_point = :rand.uniform(length(p1))
        {h1, t1} = Enum.split(p1, cx_point)
        {h2, t2} = Enum.split(p2, cx_point)
        [h1 ++ t2, h2 ++ t1 | acc]
      end
    )
  end

  def mutation(population) do
    Enum.map(population,
      fn chromosome ->
        if :rand.uniform() < 0.05 do
          Enum.shuffle(chromosome)
        else
          chromosome
        end
      end)
  end
end
