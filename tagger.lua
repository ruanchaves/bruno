require 'utils'

function tag_match(line)
    tokens = string_split(line)
    
    patterns = {
        1: {"function", "%(%)"},
        2: {"function", "%(", "%)"},
        3: {"var"},
        4: {"var", "%["},
        5: {"begin "},
        6: {"end "},
        7: {" %= "},
        8: {" %= ", " %+ "," %- ", " %* ", " %/ "},
        9: {"%(%)"},
        10: {"%(", "%)"},
        11: {"if ", "then "},
        12: {"else"},
        13: {"fi"}
    }

    labels = {
        1: "header_1",
        2: "header_2",
        3: "var_1",
        4: "var_2",
        5: "begin",
        6: "end",
        7: "attr_1",
        8: "attr_2",
        9: "funcall_1",
        10: "funcall_2",
        11: "if_then",
        12: "else",
        13: "fi"
    }


function line_tagger(function_list, verbose)
    verbose = verbose else false
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
