alias GeneticExDev.OneMax.Helper
alias GeneticExDev.OneMax.OneMaxEx
alias GeneticExDev.GeneticRust

caller = self
arg = hd(System.argv)

cond do
  arg == "ex" ->
    Helper.run(fn -> OneMaxEx.run(caller, 20) end)
  arg == "rust" ->
    Helper.run(fn -> GeneticRust.run_one_max(caller, 100) end)
  true -> []
end
