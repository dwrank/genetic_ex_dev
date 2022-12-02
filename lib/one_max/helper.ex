defmodule GeneticExDev.OneMax.Helper do

  def run(run_fn) do
    start_time = DateTime.utc_now()

    _pid = spawn(fn -> run_fn.() end)

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

end
