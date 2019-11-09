------------
-- Lê um arquivo bpl em memória.
-- @module reader
-- @author Juliana Resplande Sant'Anna Gomes, Ruan Chaves Rodrigues
-- @license MIT


--- Identifica e armazena em tabelas o código das funções de um arquivo.
-- @param file O nome do arquivo.
-- @param verbose Imprime mensagens do debugger.
-- @return As variáveis function_list e function_name_to_index.
function func_reader(file, verbose)
    local function_block
    local function_list
    local function_name_to_index

    verbose = verbose or false
    --- tabela auxiliar temporária.
    function_block = {} 
    --- lista de funções.
    function_list = {}
    --- dicionário com nomes de funções como chave e índice da função na tabela function_block como valor.
    function_name_to_index = {}
    f_list_counter = 1
    f_block_counter = 1

    for line in file:lines() do
        if string.find(line,"^function ") then
            function_block = {}
            f_block_counter = 1
            function_block[f_block_counter] = line
            f_block_counter = f_block_counter + 1
        elseif string.find(line,"^end") then
            function_block[f_block_counter] = line
            f_block_counter = f_block_counter + 1
            function_list[f_list_counter] = table.clone(function_block)
            f_list_counter = f_list_counter + 1
            if (verbose == true) then
                print("======")
                print_table(function_block)
            end
        else
            if line ~= nil and line ~= '' then
                function_block[f_block_counter] = line
                f_block_counter = f_block_counter + 1
            end
        end
    end

    for key, current_table in ipairs(function_list) do
        function_header = current_table[1]
        tmp = string_split(function_header)
        function_name_to_index[tmp[2]] = key
    end

    if (verbose == true) then
        print("======")
        print_table(function_list)
        print("======")
        print_table_unordered(function_name_to_index)
        print("======")
    end
    return function_list, function_name_to_index
end
