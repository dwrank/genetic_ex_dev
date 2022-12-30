alias GeneticExDev.GeneticRust
alias GeneticExDev.Types.Chromosome

defmodule GeneticExDev.GeneticMix do
  def run(conf) do
    times = %{eval: 0, sel: 0, cx: 0, mut: 0}
    pop = initialize(conf)
    evolve({pop, times}, conf)
  end

  def initialize(conf) do
    for _ <- 1..100, do: conf.genotype.()
  end

  def evolve({population, times}, conf, i \\ 1) do
    {population, times} = evaluate({population, times}, conf)
    best = hd(population)
    fitness = conf.fitness_fn.(best)

    if fitness == conf.max_fitness do
      send_status(conf, i, best, fitness, :done, times)
      best
    else
      if rem(i, conf.status_interval) == 0 do
        send_status(conf, i, best, fitness, :running, times)
      end

      {population, times}
      |> select()
      |> crossover2()
      |> mutation()
      |> evolve(conf, i+1)
    end
  end

  def send_status(conf, i, best, fitness, state, times) do
    status = %{pid: self(), iters: i, best: best, fitness: fitness, state: state, times: times}
    send(conf.caller, status)
  end

  def evaluate({population, times}, conf) do
    start_time = DateTime.utc_now()
    pop = Enum.sort_by(population, conf.fitness_fn, &>=/2)
    end_time = DateTime.utc_now()
    time = times.eval + DateTime.diff(end_time, start_time, :microsecond) / 1000000.0
    {pop, %{times | eval: time}}
  end

  def select({population, times}) do
    start_time = DateTime.utc_now()
    stream =
      population
      |> Stream.chunk_every(2)
      |> Stream.map(&List.to_tuple/1)
    end_time = DateTime.utc_now()
    time = times.sel + DateTime.diff(end_time, start_time, :microsecond) / 1000000.0
    {stream, %{times | sel: time}}
  end

  def crossover2({stream, times}) do
    start_time = DateTime.utc_now()
    pop = Enum.reduce(stream, [],
      fn {p1, p2}, acc ->
        {g1, g2} = GeneticRust.crossover_vec_u8(p1.genes, p2.genes)
        [
          %Chromosome{ p1 | genes: g1},
          %Chromosome{ p2 | genes: g2}
          | acc
        ]
      end
    )
    end_time = DateTime.utc_now()
    time = times.cx + DateTime.diff(end_time, start_time, :microsecond) / 1000000.0
    {pop, %{times | cx: time}}
  end

  def crossover({stream, times}) do
    start_time = DateTime.utc_now()
    pop = Enum.reduce(stream, [],
      fn {p1, p2}, acc ->
        cx_point = :rand.uniform(length(p1.genes))
        {h1, t1} = Enum.split(p1.genes, cx_point)
        {h2, t2} = Enum.split(p2.genes, cx_point)
        [
          %Chromosome{ p1 | genes: h1 ++ t2},
          %Chromosome{ p2 | genes: h2 ++ t1}
          | acc
        ]
      end
    )
    end_time = DateTime.utc_now()
    time = times.cx + DateTime.diff(end_time, start_time, :microsecond) / 1000000.0
    {pop, %{times | cx: time}}
  end

  def mutation({population, times}) do
    start_time = DateTime.utc_now()
    pop = Enum.map(population,
      fn chromosome ->
        if :rand.uniform() < 0.05 do
          #%Chromosome{ chromosome | genes: Enum.shuffle(chromosome.genes)}
          #struct(Chromosome, GeneticRust.shuffle(chromosome))
          %Chromosome{ chromosome | genes: GeneticRust.shuffle_vec_u8(chromosome.genes)}
        else
          chromosome
        end
      end)
    end_time = DateTime.utc_now()
    time = times.mut + DateTime.diff(end_time, start_time, :microsecond) / 1000000.0
    {pop, %{times | mut: time}}
  end
end
