alias GeneticExDev.OneMax.Helper
alias GeneticExDev.OneMax.OneMaxEx
alias GeneticExDev.OneMax.OneMaxRust

caller = self
arg = hd(System.argv)

cond do
  arg == "ex" ->
    Helper.run(fn -> OneMaxEx.run(caller, 20) end)
  arg == "rust" ->
    Helper.run(fn -> OneMaxRust.run(caller, 100) end)
  true -> []
end
