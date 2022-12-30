defmodule GeneticExDev.GeneticRust do
  use Rustler, otp_app: :genetic_ex_dev, crate: "genetic_rust"

  def run_one_max(_caller, _intervals), do: :erlang.nif_error(:nif_not_loaded)

  def shuffle_vec_u8(_genes), do: :erlang.nif_error(:nif_not_loaded)
  def shuffle(_chromosome), do: :erlang.nif_error(:nif_not_loaded)
  def crossover_vec_u8(_genes1, _genes2), do: :erlang.nif_error(:nif_not_loaded)
end
