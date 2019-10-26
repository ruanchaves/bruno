function table.clone(org)
    return {table.unpack(org)}
  end


function print_table(data)
    for key, value in ipairs(data) do
        print('\t', key, value)
    end
end

function print_table_unordered(data)
  for key, value in pairs(data) do
    print('\t', key,' : ', value)
  end
end

function isempty(s)
  return s == nil or s == ''
end

function string_split(line)
  t = {}
    for token in string.gmatch(line, "[^%s]+") do
      table.insert(t, token)
    end
  return t
end

function find_function_index(function_name_to_index, regex)
  for key, value in pairs(function_name_to_index) do
    if string.find(key, regex) then
        main_index = value
        break
    end
  end
  return main_index
end