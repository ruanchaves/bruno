------------
-- Interpretador que executa programas .bpl . Modo de uso: "lua interpretador.lua <prog.bpl>"
-- @module interpretador
-- @author Juliana Resplande Sant'Anna Gomes, Ruan Chaves Rodrigues
-- @license MIT

require 'utils'
require 'reader'
require 'tagger'
require 'runner'

local verbose
local filename
local function_list
local function_name_to_index
local function_list_tags

--- Parâmetro booleano que decide se o debugger do tagger será executado. Caso "true", mensagens de debug serão impressas com a saída do programa.
verbose = false

--- Pega o nome do arquivo passado como parâmetro (se houver).
filename = nil

--- Contém uma lista de listas de comandos de funções.
function_list = nil 

--- Contém um dicionário com nome de função como chave e índice da função em function_list como valor.
function_name_to_index = nil

--- Lista de listas que para cada comando em function_list, na mesma posição, apresenta a tag correspondente.
function_list_tags = nil

filename = ...
if not filename then
   print("Usage: lua interpretador.lua <prog.bpl>")
   os.exit(1)
end

local file = io.open(filename, "r")
if not file then
   print(string.format("[ERRO] Cannot open file %q", filename))
   os.exit(1)
end

function_list, function_name_to_index = func_reader(file, verbose)
file:close()

function_list_tags = line_tagger(function_list, verbose)

main_index = find_function_index(function_name_to_index, 'main')
run = Runner:create(function_list, function_list_tags)

--- Parâmetro booleano que decide se o debugger do Runner será executado. Caso "true", mensagens de debug serão impressas com a saída do programa.
run.verbose = false

run:execute(function_list[main_index], function_list_tags[main_index])
