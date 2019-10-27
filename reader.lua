-------------------------------------
-- Identifica e armazena em tabelas o código das funções de um arquivo.
-- @param file O nome do arquivo.
-- @param verbose Caso este parâmetro seja verdadeiro (true), as tabelas serão impressas na tela após serem lidas.
-------------------------------------
function func_reader(file, verbose)
    verbose = verbose or false
    function_block = {} -- tabela auxiliar temporária.
    function_list = {} -- lista de funções.
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
            if not isempty(line) then
                function_block[f_block_counter] = line
                f_block_counter = f_block_counter + 1
            end
        end
    end

    if (verbose == true) then
        print("======")
        print_table(function_list)
        print("======")
    end
    return function_list
end
