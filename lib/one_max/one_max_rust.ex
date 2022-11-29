defmodule GeneticExDev.OneMax.OneMaxRust do
  use Rustler, otp_app: :genetic_ex_dev, crate: "one_max_rust"

  def run(_caller, _intervals), do: :erlang.nif_error(:nif_not_loaded)
end
