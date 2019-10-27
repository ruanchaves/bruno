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
  tmp_table = {}
  for i in string.gmatch(expr, "%w+") do
    table.insert(tmp_table, i)
  end
  return tmp_table
end

function name_from_function_header(header)
  names, args = header:match("(.+)%((.+)")
  key = string_split(names)[2]
  return key
end  

function name_from_function_call(header)
  names, args = header:match("(.+)%((.+)")
  key = string_split(names)[1]
  return key
end  

function get_param(command)
    zero = string.match(command,"(function%s+%l+%(%)%s*)")
    if zero == command then
        return nil
    end

    one,param1 = string.match(command,"(function%s+%l+%((%l+)%)%s*)")
    if one == command then
        return param1
    end

    two,param1,param2 = string.match(command,"(function%s%l+%((%l+),(%l+)%)%s)")
    if two == command then
        return param1,param2
    end

    three,param1,param2,param3 = string.match(command,"(function%s+%l+%((%l+),(%l+),(%l+)%)%s*)")
    if three == command then
        return param1,param2,param3    
    end
        --error
end

function get_varname(command)
    vardef = string.match(command,"var%s+(%l+)")

    if vardef then
      return vardef
    ---error  
end

function get_varsize(command)
  vardef1,varsize = string.match(command,"(var%s+%l+%[(%d+)%]%s*)")
  vardef2 = string.match(command,"(var%s+%l+%s*)")
  if command == vardef1 then
    return varsize
  elseif command == vardef2 then
    return nil
  end
  ---error  
end

function get_var(command)
  varname, varvalue = string.match(command, "(%l+)%[(%-?%d+)%]")

  if varname then
      return varname, varvalue
  end


  varname = string.match(command, "%l+")
  if varname then
      return varname
  end

  --error
end

function get_attrvalues(command)
  attr,lside,rside = string.match(command,"((.+)%s+=%s+(.+)%s*)")
  --if attr ~= command: error

  varname, varvalue = get_var(lside)

  attr,arg1,op,arg2 = string.match(rside, "((.+)%s+([+|-|*|/])%s+(.+)%s*")

   if attr == rside then
       return varname, varvalue,arg1,op,arg2
   end

   if arg == rside then
       return varname, varvalue,arg
   end

  --error
end

function get_funcall(command)
  if string.match(command,"%l+%(.*%)") then
      return ---Runner:funcall
  end
end

function get_value(command)
  if string.find("%l", command) == nil then
      number = string.match(command,"(%-?%d+)")
      return number
  end
  
  name,number = get_var(command)
    --dentro do getvar ja vai ter
    ---teste de erro
  return name, number
end

function get_argvalues(command)
  funcall = get_funcall(command)
      if funcall then
          return funcall
      end

  value, number = get_value(command)
      if value then
          return value,number
      end
  
  --ja teria teste de erro no value

end