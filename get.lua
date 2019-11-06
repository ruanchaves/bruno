require 'callstack'

reserved = {
    [1]="function",
    [2]="var",
    [3]="begin",
    [4]="end",
    [5]="then",
    [6]="if",
    [7]="else",
    [8]="fi"
}

function get_param(command)
    local param1,param2,param3 = nil

    find = string.find(command,"%(%)")
    if find ~= nil then
        return nil
    end

    -- ordem invesa é importante 
    -- senão ele considera a virgula
    -- como sendo parte do ponto

    param1,param2,param3 = string.match(command,"%((.+),(.+),(.+)%)")
    if param3 ~= nil then
        return param1,param2,param3    
    end

    param1,param2 = string.match(command,"%((.+),(.+)%)")
    if param2 ~= nil then
        return param1,param2
    end

    local param1 = string.match(command,"%((.+)%)")
    if param1 ~= nil then
        return param1
    end
end

function get_varname(command, verbose)

  verbose = verbose or false

    local vardef = string.match(command,"var%s+(%l+)")

    if verbose == true then
      message = string.format("DEBUG: get_varname( %s ) - vardef: %s", command, vardef)
      print(message)
    end

    for i, value in ipairs(reserved) do
        if value == vardef then
            print("Não pode usar palavra reservada")
            os.exit()
        end
    end
    return vardef 
end

function get_varsize(command)
    local varsize = string.match(command,"(%d+)")
    return tonumber(varsize)
end

function get_var(command)
  local varname, varvalue = string.match(command, "(%l+)%[(%-?%d+)%]")
 
  if varname then
    local varvalue = tonumber(varvalue)
    if varvalue < 0 then
      varvalue = -varvalue-1
    end
    
    return varname, varvalue
  end

  local varname = string.match(command, "%l+")
  if varname then
      return varname
  end

end

function get_attrvalues(command, verbose)
  verbose = verbose or false
  local lside,rside = string.match(command,"(.+)%s+=%s+(.+)%s*")

  -- A função "trim" elimina espaços ao princípio 
  -- e ao fim da string.
  trim = function(s) return s:match "^%s*(.-)%s*$" end
  rside = trim(rside)
  
  -- Aqui estamos quebrando a string em substrings usando
  -- um ou mais espaços como delimitador.
  tokens = {}
  for word in rside:gmatch("%S+") do 
    table.insert(tokens, word) 
  end

  local arg1 = tokens[1]
  local op = tokens[2]
  local arg2 = tokens[3]

  if verbose == true then
    message = "DEBUG get_attrvalues : lside == %s ; rside == %s"
    message = string.format(message, lside, rside)
    print(message)
    message = "DEBUG get_attrvalues : arg1 == %s ; op == %s ; arg2 == %s"
    message = string.format(message, arg1, op, arg2)
    print(message)
  end

   if arg1 ~= nil then
      return lside,arg1,op,arg2
   end
    return lside,rside,nil,nil
end

function get_funcall(command,run)
  local funcall = string.match(command,"(%l+)%(.*%)")
  if funcall then
        run:funcall(command,"function")
        local ret = run.callstack:find_local(funcall,run.current_function)
        return tonumber(ret)
  else
      return nil
  end
end

function get_value(command,run)
    
  if string.find(command,"%l") == nil then
      local number = string.match(command,"(%-?%d+)")
      return tonumber(number)
  end
  
  varname,varnumber = get_var(command)
  if varnumber == nil then
    return run.callstack:find(varname)
  else
    if varnumber < 0 then
      varnumber = -varnumber-1
    end

    if tonumber(varnumber) >= tonumber(run.callstack:find(varname.."_size_")) then
        print("Vetor estorou")
        os.exit()
    else
        return run.callstack:find(varname.."["..varnumber.."]", varsize)      
    end
   end
end

function get_argvalue(command, run)
  local funcall = get_funcall(command,run)
      if funcall ~= nil then
          return funcall
      end
  return get_value(command,run)

end

function get_result(num1,op,num2)
  if op == "+" then
    return num1 + num2
  elseif op == "-" then
    return num1 - num2
  elseif op == "*" then
    return num1*num2
  elseif op == "/" then
    return math.floor(num1/num2)
  end
end

function get_if(command)
  return string.match(command, "if%s+(.+)%s+([=|>|<|!]+)%s+(.+)%s+")
end