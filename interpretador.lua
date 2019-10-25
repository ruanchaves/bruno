require 'utils'
require 'reader'

--
-- Pega o nome do arquivo passado como parâmetro (se houver)
--
local filename = ...
if not filename then
   print("Usage: lua interpretador.lua <prog.bpl>")
   os.exit(1)
end

local file = io.open(filename, "r")
if not file then
   print(string.format("[ERRO] Cannot open file %q", filename))
   os.exit(1)
end

--
-- Identifica as funções no arquivo
--
verbose = true
function_list, function_name_to_index = func_reader(file, verbose)
file:close()