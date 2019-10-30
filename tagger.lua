require 'utils'
--Como vai estar sintaticamente correto,
--podemos usar so as palavras reservadas
--para encontrar
outer_tags = {
    [1]="var",
    --nao mudar a ordem palavra reservada
    [2]="function",
    [3]="begin",
    [4]="end",
    [5]="=",
    [6]="print",
    -- nao mudar a ordem print antes de funcall
    [7]="%(",
    [8]="if",
    [9]="else",
    [10]="fi",
}

labels = {
    [1]="vardef",
    [2]="header",
    [3]="begin",
    [4]="end",
    [5]="attr",
    [6]="print",
    [7]="funcall",
    [8]="if",
    [9]="else",
    [10]="fi",
}

function tag_match(line)
    --print("Entrou")
    --print(line)
    for key, value in ipairs(outer_tags) do
        if string.find(line, value) ~= nil then
            return labels[key]
        end
    end
    --print("Ficou sem catalogar")
end

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
