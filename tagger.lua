------------
-- Atribui a tag adequada a cada comando.
-- @module tagger
-- @author Juliana Resplande Sant'Anna Gomes, Ruan Chaves Rodrigues
-- @license MIT

require 'utils'

--- Regex equivalente a cada tag na tabela labels.
outer_tags = {
    [1]="(%s*var%s+.+%s*)", --vardef
    [2]="(%s*function%s+%l+%(.*%)%s*)", --header
    [3]="(%s*begin%s*)", --begin
    [4]="(%s*end%s*)", --end
    [5]="(%s*if%s+.+then%s*)", --if
    [6]="(%s*.+%s+=%s+.+)", --attr
    [7]="(%s*print%(.+%)%s*)", --print
    [8]="(%s*%l+%(.*%)%s*)", --funcall
    [9]="(%s*else%s*)", --else
    [10]="(%s*fi%s*)", --fi
}

--- Tabela de tags. Cada tag determina qual chamada de função no objeto Runner será acionada para o comando que a recebe.
labels = {
    [1]="vardef", --vardef
    [2]="header", --header
    [3]="begin", --begin
    [4]="end", --end
    [5]="if", --if
    [6]="attr", --attr
    [7]="print", --print
    [8]="funcall", --funcall
    [9]="else", --else
    [10]="fi", --fi
}

--- Retorna a tag correspondente a um comando.
-- @param line comando.
-- @return Um valor da tabela labels.
function tag_match(line)
    for key, value in ipairs(outer_tags) do
	local match_value = string.match(line, value)
        if match_value == line then
            return labels[key]
        end
    end
end

--- Retorna as tags correspondentes a cada comando de cada função no programa.
-- @param function_list Lista de listas de comandos, separados por função.
-- @param verbose Imprime mensagens do debugger.
-- @return function_list_tags Lista de listas de tags de comandos, separadas por função.
function line_tagger(function_list, verbose)
    verbose = verbose or false
    function_list_tags = {}
    function_block_tags = {}
    for key, func_lines in ipairs(function_list) do
        for idx, line in ipairs(func_lines) do
            function_block_tags[idx] = tag_match(line)
        end
        function_list_tags[key] = table.clone(function_block_tags)
        if (verbose == true) then
            print("=====")
            print_table(function_block_tags)
        end
        function_block_tags = {}
    end
    return function_list_tags
end
