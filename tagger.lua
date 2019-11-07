require 'utils'
--Como vai estar sintaticamente correto,
--podemos usar so as palavras reservadas
--para encontrar
outer_tags = {
    [1]="(%s*var%s+.+%s*)",
    --nao mudar a ordem palavra reservada
    [2]="(%s*function%s+%l+%(.*%)%s*)",
    [3]="(%s*begin%s*)",
    [4]="(%s*end%s*)",
    [5]="(%s*if%s+.+then%s*)",
    --nao mudar a ordem if antes de =
    [6]="(%s*.+%s+=%s+.+)",
    [7]="(%s*print%(.+%)%s*)",
    -- nao mudar a ordem print antes de funcall
    [8]="(%s*%l+%(.*%)%s*)",
    [9]="(%s*else%s*)",
    [10]="(%s*fi%s*)",
}

labels = {
    [1]="vardef",
    [2]="header",
    [3]="begin",
    [4]="end",
    [5]="if",
    [6]="attr",
    [7]="print",
    [8]="funcall",
    [9]="else",
    [10]="fi",
}

function tag_match(line)
    for key, value in ipairs(outer_tags) do
	local match_value = string.match(line, value)
        if match_value == line then
	    -- print("match_value: ", match_value, "line: ",line, "value: ",value)
            return labels[key]
        end
    end
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
