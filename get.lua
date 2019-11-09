------------
-- Funções utilitárias para o Runner.
-- @module get
-- @author Juliana Resplande Sant'Anna Gomes, Ruan Chaves Rodrigues
-- @license MIT

require 'callstack'

--- Extrai parâmetros de uma função de um comando usando regex.
-- @param command Comando da função.
-- @param verbose Imprime mensagens do debugger.
function get_param(command, verbose)
    local param1,param2,param3 = nil, nil, nil

    local find = string.find(command,"%(%)")
    if find ~= nil then
        return nil
    end

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

--- Extrai o nome de uma declaração de variável de um comando usando regex.
-- @param command Comando da declaração de variável.
-- @param verbose Imprime mensagens do debugger.
function get_varname(command, verbose)

    local vardef = string.match(command,"var%s+(%l+)")

    if verbose == true then
      message = string.format("DEBUG get_varname( %s ) : vardef == %s", command, vardef)
      print(message)
    end

    return vardef 
end

--- Extrai o tamanho de um array de um comando usando regex.
-- @param command Comando da declaração do array.
-- @param verbose Imprime mensagens do debugger.
function get_varsize(command, verbose)
    local varsize = string.match(command,"(%d+)")

    if verbose == true then 
      message = "DEBUG get_varsize( % s ) : varsize == %s"
      message = string.format(message, command, varsize)
      print(message)
    end

    return tonumber(varsize)
end

--- Extrai uma chamada a uma posição de array de um comando usando regex.
-- @param command Comando com chamada a uma posição de array.
-- @param verbose Imprime mensagens do debugger.
function get_var(command, verbose)
  local varname, varvalue = string.match(command, "(%l+)%[(%-?%d+)%]")
  local array_size = nil 

  if varname then
    varvalue = tonumber(varvalue)
    if varvalue < 0 then
      --- Tratamento de acesso a índices negativos de array.
      array_size = tonumber(run.callstack:find(varname.."_size_"))
      varvalue = array_size + varvalue
    end
    
    return varname, varvalue
  end

  varname = string.match(command, "%l+")

  if verbose == true then
    message = "DEBUG get_var( %s ) : varname == %s, varvalue == %s"
    message = string.format(message, command, varname, varvalue)
    print(message)
  end

  if varname then
      return varname
  end

end

--- Extrai os operadores de uma operação aritmética de um comando usando regex.
-- @param command Comando com operação aritmética.
-- @param verbose Imprime mensagens do debugger.
function get_attrvalues(command, verbose)
  local verbose = verbose or false
  local lside,rside = string.match(command,"(.+)%s+=%s+(.+)%s*")

  --- Eliminação de espaços ao princípio e ao fim da string.
  -- @param s String.
  trim = function(s) return s:match "^%s*(.-)%s*$" end
  rside = trim(rside)


  local tokens = {}  -- Lista de tokens de uma string, separados por espaços.
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

--- Extrai o teste de um comando if usando regex.
-- @param command Comando if.
-- @param verbose Imprime mensagens do debugger.
function get_if(command, verbose)

  local arg1, op, arg2 = string.match(command, "if%s+(.+)%s+([=|>|<|!]+)%s+(.+)%s+")
  if verbose == true then
    message = "DEBUG get_if( %s ): arg1 == %s; op == %s ; arg2 == %s;"
    message = string.format(message, command, arg1, op, arg2)
    print(message)
  end
  return arg1, op, arg2
end

--- Retorna o valor correspondente a uma variável ou posição de array.
-- @raise Retorna um erro para acesso a posição fora do alcance de um array.
-- @param command Comando contendo variável.
-- @param run um objeto da classe Runner.
-- @param verbose Imprime mensagens do debugger.
-- @return Valor da variável ou posição de array.
function get_value(command,run, verbose)
  
  local return_value = nil 
  local number = nil

  if verbose == true then
    message = "DEBUG get_value( %s ): return_value == %s;"
    message = string.format(message, command, return_value)
    print(message)
  end

  if string.find(command,"%l") == nil then
      number = string.match(command,"(%-?%d+)")
      return_value = tonumber(number)
  end
  
  if return_value == nil then
    varname,varnumber = get_var(command)
    if varnumber == nil then
      return_value = run.callstack:find(varname)
    else

      if tonumber(varnumber) >= tonumber(run.callstack:find(varname.."_size_")) then
          print("ERRO: acesso a índice fora do alcance do vetor.")
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

--- Executa e retorna o valor de uma chamada de função. 
-- @param command Chamada de função.
-- @param run um objeto da classe Runner.
-- @param verbose Imprime mensagens do debugger. 
function get_funcall(command,run, verbose)
  local verbose = verbose or false
  local funcall = string.match(command,"(%l+)%(.*%)")
  local return_value = nil
  local ret = nil

  if funcall then
        run:funcall(command,"function", verbose)
        ret = run.callstack:find(funcall,run.callstack.functions[run.callstack.counter])
        return_value = tonumber(ret)
  end

  if verbose == true then
    message = "get_funcall( %s ): funcall == %s ; return_value == %s"
    message = string.format(message, command, funcall, return_value)
    print(message)
  end

  return return_value
end

--- Identifica o tipo de um argumento, e então executa e retorna o valor de um argumento.
-- @param command Comando com argumento.
-- @param run um objeto da classe Runner.
-- @param verbose Imprime mensagens do debugger. 
function get_argvalue(command, run, verbose)
  local verbose = verbose or false
  local return_value = nil
  local funcall = get_funcall(command,run, verbose)
  if funcall ~= nil then
	  return_value = funcall
  else
    return_value = get_value(command,run, verbose)
  end

  if verbose == true then
    message = "DEBUG get_argvalue( %s ): funcall == %s ; return_value == %s ;"
    message = string.format(command, funcall, return_value)
    print(message)
  end

  return return_value
end

--- Executa uma operação aritmética entre dois valores. 
-- Variáveis e funções precisam ser resolvidas em valores antes da chamada desta função.
-- @param num1 Primeiro valor.
-- @param op Operador. Operadores permitidos: adição ( + ), subtração ( - ), multiplicação ( * ) e divisão ( / ).
-- @param verbose Imprime as mensagens do debugger.
function get_result(num1,op,num2, verbose)
  local return_value = nil
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