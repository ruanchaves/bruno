-- A função "trim" elimina espaços ao princípio 
-- e ao fim da string.
function trim_string(s)
  return s:match "^%s*(.-)%s*$"
end

-- Aqui estamos quebrando a string em substrings usando
-- um ou mais espaços como delimitador.
function split_tokens(s)
  tokens = {}
  for word in rside:gmatch("%S+") do 
    table.insert(tokens, word) 
  end
  return tokens
end  

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
  local t = {}
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

function find_type(value)
  if string.find(value, '%d+') then
      return 'number'
  elseif string.find(value, '%(') then
      return 'function'
  elseif string.find(value, '%l+') then
      return 'name'
  else
      return nil
  end
end

function find_function_args(expr)
  local tmp_table = {}
  for i in string.gmatch(expr, "%w+") do
    table.insert(tmp_table, i)
  end
  return tmp_table
end

function name_from_function_header(header)
  local names, args = header:match("(.+)%((.+)")
  local key = string_split(names)[2]
  return key
end  

function name_from_function_call(header)
  local names, args = header:match("(.+)%((.+)")
  local key = string_split(names)[1]
  return key
end  