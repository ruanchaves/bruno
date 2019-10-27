require 'utils'

outer_tags{
    [1]="^function",
    [2]="^var",
    [3]="^begin",
    [4]="^end",
    [5]="=",
    [6]="%(",
    [7]="^if",
    [8]="^else",
    [9]="fi%s*$",
}

labels = {
    [1]="header",
    [3]="vardef",
    [5]="begin",
    [6]="end",
    [7]="attr",
    [9]="funcall",
    [11]="if",
    [12]="else",
    [13]="fi",
}


function tag_match(line)
    for key, value in ipairs(outer_tags) do
        if string.find(line, value) then
            return labels[key]
        end
        --else error
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
