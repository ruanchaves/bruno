require 'utils'
require 'reader'
require 'tagger'

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

verbose = true
--
-- Identifica as funções no arquivo
--
function_list, function_name_to_index = func_reader(file, verbose)
file:close()

--
-- Categoriza cada linha de cada função
--
function_list_tags = line_tagger(function_list, verbose)