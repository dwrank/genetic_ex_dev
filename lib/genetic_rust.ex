defmodule GeneticExDev.GeneticRust do
  use Rustler, otp_app: :genetic_ex_dev, crate: "genetic_rust"

  def run_one_max(_caller, _intervals), do: :erlang.nif_error(:nif_not_loaded)
end
