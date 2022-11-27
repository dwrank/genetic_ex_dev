defmodule GeneticExDev.OneMax.OneMaxEx do
  def create_population() do
    for _ <- 1..100, do: for _ <- 1..1000, do: Enum.random(0..1)
  end

  def evaluate(population) do
    Enum.sort_by(population, &Enum.sum/1, &>=/2)
  end

  def selection(population) do
    population
    |> Stream.chunk_every(2)
    |> Stream.map(&List.to_tuple/1)
  end

  def crossover(stream) do
    Enum.reduce(stream, [],
      fn {p1, p2}, acc ->
        cx_point = :rand.uniform(1000)
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

  def algorithm(population, caller, i_update, i \\ 1) do
    sum =
      population
      |> hd()
      |> Enum.sum()

    status = %{pid: self(), status: :update, iters: i, sum: sum, solution: hd(population)}

    if sum == 1000 do
      send(caller, %{status | status: :done})
    else
      if rem(i, i_update) == 0 do
        send(caller, status)
      end

      population
      |> selection()
      |> crossover()
      |> mutation()
      |> evaluate()
      |> algorithm(caller, i_update, i+1)
    end
  end

  def run(caller, i_update) do
    create_population()
    |> evaluate()
    |> algorithm(caller, i_update)
  end
end
