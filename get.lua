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

function get_param(command, verbose)
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

    if verbose == true then 
      message = "DEBUG get_param( %s ) : param1 == %s ; param 2 == %s ; param 3 == %s \n"
      message = string.format(message, command, param1, param2, param3)
      print(message)
    end

end

function get_varname(command, verbose)

    local vardef = string.match(command,"var%s+(%l+)")

    for i, value in ipairs(reserved) do
        if value == vardef then
            print("Não pode usar palavra reservada")
            os.exit()
        end
    end

    if verbose == true then
      message = string.format("DEBUG get_varname( %s ) : vardef == %s", command, vardef)
      print(message)
    end

    return vardef 
end

function get_varsize(command, verbose)
    local varsize = string.match(command,"(%d+)")

    if verbose == true then 
      message = "DEBUG get_varsize( % s ) : varsize == %s"
      message = string.format(message, command, varsize)
      print(message)
    end

    return tonumber(varsize)
end

function get_var(command, verbose)
  local varname, varvalue = string.match(command, "(%l+)%[(%-?%d+)%]")
 
  if varname then
    local varvalue = tonumber(varvalue)
    if varvalue < 0 then
      varvalue = -varvalue-1
    end
    
    return varname, varvalue
  end

  local varname = string.match(command, "%l+")

  if verbose == true then
    message = "DEBUG get_var( %s ) : varname == %s, varvalue == %s"
    message = string.format(message, command, varname, varvalue)
    print(message)
  end

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
    message = "DEBUG get_attrvalues( %s ) : lside == %s ; rside == %s"
    message = string.format(message, command, lside, rside)
    print(message)
    message = "DEBUG get_attrvalues( %s ) : arg1 == %s ; op == %s ; arg2 == %s"
    message = string.format(message, command, arg1, op, arg2)
    print(message)
  end

   if arg1 ~= nil then
      return lside,arg1,op,arg2
   end
    return lside,rside,nil,nil
end

function get_funcall(command,run, verbose)
  local funcall = string.match(command,"(%l+)%(.*%)")

  if funcall then
        run:funcall(command,"function")
        local ret = run.callstack:find_local(funcall,run.current_function)
        return_value = tonumber(ret)
  else
      return_value = nil
  end

  if verbose == true then
    message = "get_funcall( %s ): funcall == %s ; return_value == %s"
    message = string.format(message, command, funcall, return_value)
    print(message)
  end

  return return_value
end

function get_value(command,run, verbose)
    
  if command == nil then 
    return 0
  end
  
  return_value = nil 

  if verbose == true then
    message = "DEBUG get_value( %s ): return_value == %s;"
    message = string.format(message, command, return_value)
    print(message)
  end

  if string.find(command,"%l") == nil then
      local number = string.match(command,"(%-?%d+)")
      return_value = tonumber(number)
  end
  
  if return_value == nil then
    varname,varnumber = get_var(command)
    if varnumber == nil then
      return_value = run.callstack:find(varname)
    else
      if varnumber < 0 then
        varnumber = -varnumber-1
      end

      if tonumber(varnumber) >= tonumber(run.callstack:find(varname.."_size_")) then
          print("Vetor estorou")
          os.exit()
      else
          return_value = run.callstack:find(varname.."["..varnumber.."]", varsize)      
      end
    end
  end
  if verbose == true then
    message = "DEBUG get_value( %s ): number == %s; return_value == %s; varname == %s; varnumber == %s"
    message = string.format(message, command, number, return_value, varname, varnumber)
    print(message)
  end
  return return_value
end

function get_argvalue(command, run, verbose)
  return_value = nil
  local funcall = get_funcall(command,run)
      if funcall ~= nil then
          return_value = funcall
      end
  if return_value == nil then
    return_value = get_value(command,run)
  end

  if verbose == true then
    message = "DEBUG get_argvalue( %s ): funcall == %s ; return_value == %s ;"
    message = string.format(command, funcall, return_value)
    print(message)
  end

  return return_value
end

function get_result(num1,op,num2, verbose)
  return_value = nil
  if num1 == nil then
    num1 = 0
  end
  if num2 == nil then
    num2 = 0
  end
  if op == "+" then
    return_value = num1 + num2
  elseif op == "-" then
    return_value = num1 - num2
  elseif op == "*" then
    return_value = num1*num2
  elseif op == "/" then
    return_value = math.floor(num1/num2)
  end
  if verbose == true then
    message = "DEBUG get_result(%s, %s, %s) : return_value == %s;"
    message = string.format(message, command, num1, op, num2)
    print(message)
  end
  return return_value
end

function get_if(command, verbose)

  return_value = string.match(command, "if%s+(.+)%s+([=|>|<|!]+)%s+(.+)%s+")
  if verbose == true then
    message = "DEBUG get_if( %s ): return_value == %s;"
    message = string.format(message, command, return_value)
    print(message)
  end
  return return_value
end