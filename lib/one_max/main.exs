alias GeneticExDev.OneMax.Helper
alias GeneticExDev.OneMax.OneMaxEx

caller = self
arg = hd(System.argv)

cond do
  arg == "ex" ->
    Helper.run(fn -> OneMaxEx.run(caller, 20) end)
  true -> []
end
