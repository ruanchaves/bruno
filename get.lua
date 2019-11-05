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

function get_varname(command)
    local vardef = string.match(command,"var%s+(%l+)")
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
    if tonumber(varnumber) > tonumber(run.callstack:find(varname.."_size_")) then
        print("Vetor estorou")
        os.exit()
    else
        return run.callstack:find(varname.."["..varnumber.."]", varsize)      
    end
   end
end

function get_argvalues(command, run)
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