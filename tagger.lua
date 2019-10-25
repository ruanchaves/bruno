require 'utils'

function tag_match(line)
    scores = {}

    patterns = {
        [1]="function .+%(%)",
        [2]="function .+%(.+%)",
        [3]="var .+",
        [4]="var %[.+",
        [5]="^begin ",
        [6]="^end",
        [7]="%w+ %= %w+",
        [8]="%w+ %= %w+ %p %w+",
        [9]="%w+%(%)",
        [10]="%w+%(.+%)",
        [11]="if %w+ %p %w+ then",
        [12]="else",
        [13]="fi"
    }

    labels = {
        [1]="header_1",
        [2]="header_2",
        [3]="var_1",
        [4]="var_2",
        [5]="begin",
        [6]="end",
        [7]="attr_1",
        [8]="attr_2",
        [9]="funcall_1",
        [10]="funcall_2",
        [11]="if_then",
        [12]="else",
        [13]="fi"
    }

    for key, value in ipairs(patterns) do
        scores[key] = 0
    end

    for key, value in ipairs(patterns) do
        if string.find(line, value) then
            scores[key] = scores[key] + 1
        end
    end

    chosen_label = nil
    tmp_score = 0
    for key, value in ipairs(scores) do
        if value > tmp_score then
            chosen_label = labels[key]
        end
    end
    return chosen_label
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
