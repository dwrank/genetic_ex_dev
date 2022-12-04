defmodule GeneticExDev.Helper do

  alias GeneticExDev.OneMaxEx
  alias GeneticExDev.GeneticRust

  def start(run_fn) do
    caller = self()
    start_time = DateTime.utc_now()

    _pid = spawn(fn -> run_fn.(caller) end)

    wait = fn wait ->
      receive do
        %{state: :running} = status ->
          IO.inspect status
          wait.(wait)
        %{state: :done} = status ->
          IO.inspect status
      end
    end

    wait.(wait)

    end_time = DateTime.utc_now()
    time = DateTime.diff(end_time, start_time, :microsecond) / 1000000.0
    IO.inspect time, label: "Time"
  end

  def run("one_max", "ex"), do: start(fn caller -> OneMaxEx.run(caller, 20) end)
  def run("one_max", "rust"), do: start(fn caller -> GeneticRust.run_one_max(caller, 100) end)
  def run(args), do: IO.inspect args, label: "Invalid args"
end
