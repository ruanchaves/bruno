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

function get_param(command)
    local zero = string.match(command,"(function%s+%l+%(%)%s*)")
    if zero == command then
        return nil
    end

    local one,param1 = string.match(command,"(function%s+%l+%((%l+)%)%s*)")
    if one == command then
        return param1
    end

    local two,param1,param2 = string.match(command,"(function%s%l+%((%l+),(%l+)%)%s)")
    if two == command then
        return param1,param2
    end

    local three,param1,param2,param3 = string.match(command,"(function%s+%l+%((%l+),(%l+),(%l+)%)%s*)")
    if three == command then
        return param1,param2,param3    
    end
end

function get_varname(command)
    local vardef = string.match(command,"var%s+(%l+)")
    if vardef then
      return vardef
    end  
end

function get_varsize(command)
  local vardef1,varsize = string.match(command,"(var%s+%l+%[(%d+)%]%s*)")
  local vardef2 = string.match(command,"(var%s+%l+%s*)")
  if command == vardef1 then
    return varsize
  elseif command == vardef2 then
    return nil
  end 
end

function get_var(command)
  local varname, varvalue = string.match(command, "(%l+)%[(%-?%d+)%]")

  if varname then
      return varname, varvalue
  end


  local varname = string.match(command, "%l+")
  if varname then
      return varname
  end

end

function get_attrvalues(command)
  local lside,rside = string.match(command,"(.+)%s+=%s+(.+)%s*")
  local arg1,op,arg2 = string.match(rside, "(.+)%s+([+|-|*|/])%s+(.+)%s*")
   if arg1 ~= nil then
      return lside, varvalue,arg1,op,arg2
   end
    return lside,varlue,rside,nil,nil
end

function get_funcall(command)
  if string.match(command,"%l+%(.*%)") then
      return ---Runner:funcall
  end
end

function get_value(command)
  if string.find("%l", command) == nil then
      local number = string.match(command,"(%-?%d+)")
      return tonumber(number)
  end
  
  local name,number = get_var(command)
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
  

end

function getresult(num1,op,num2)
  if op == "+" then
    return num1 + num2
  else if op == "-" then
    return num1 - num2
  else if op == "*" then
    return num1*num2
  else if op == "/" then
    return math.floor(num1/num2)
  end
end