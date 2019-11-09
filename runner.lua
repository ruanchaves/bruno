------------
-- Classe que contém funções para a interpretação de comandos.
-- @module Runner
-- @author Juliana Resplande Sant'Anna Gomes, Ruan Chaves Rodrigues
-- @license MIT

require 'utils'
require 'callstack'
require 'get'

--- Função utilitária que extrai o nome de uma função de um header de função.
-- @param header Header de função.
-- @return Nome da função.
function name_from_function_header(header)
    local names, args = header:match("(.+)%((.+)")
    local key = string_split(names)[2]
    return key
  end  

--- Função utiliária que extrai o nome de uma função de uma chamada de função.
-- @param header Chamada de função.
-- @param key Nome da função.
-- @return Nome da função.
function name_from_function_call(header)
    local names, args = header:match("(.+)%((.+)")
    local key = string_split(names)[1]
    return key
end  

Runner = {}
Runner.__index = Runner

--- Cria um objeto Runner.
-- @param function_list Lista de listas de comandos de funções.
-- @param function_list_tags Lista de listas que para cada comando em function_list, na mesma posição, apresenta a tag correspondente.
-- @return Objeto Runner.
function Runner:create(function_list, function_list_tags)
    runner_object = {}
    setmetatable(runner_object, Runner)
    --- Lista de listas de comandos de funções.
    runner_object.function_list = function_list
    --- Lista de nomes de funções, na mesma ordem que aparecem em function_list.
    runner_object.function_index = {}
    --- Objeto da classe CallStack.
    runner_object.callstack = CallStack:create()
    for i, v in ipairs(function_list) do
        header = v[1]
        key = name_from_function_header(header)
        runner_object.function_index[key] = i
    end
    runner_object.function_list_tags = function_list_tags
    --- Variável booleana de controle para if / else.
    runner_object.if_status = nil
    --- Parâmetro booleano que decide se o debugger do Runner será executado. Caso "true", mensagens de debug serão impressas com a saída do programa.
    runner_object.verbose = false
    return runner_object
 end

--- Encontra o índice de uma função em function_index a partir do seu nome.
-- @param name Nome da função. 
-- @return Índice da função.
function Runner:find_function_index(name)
    for key, value in pairs(self.function_index) do
        if key == name then
            return value
        end
    end
end

--- Executa uma lista de comandos associada a uma lista de tags.
-- @param cmds Comandos.
-- @param cmd_tags Lista que para cada comando em cmds, na mesma posição, apresenta a tag correspondente.
-- @return nil
function Runner:execute(cmds, cmd_tags)
    for key, value in ipairs(cmds) do
        local command = value
        local command_tag = cmd_tags[key]
        if not ((command_tag ~= "else" and command_tag ~= "fi")
            and self.if_status == false) then
            if command_tag == "header" then
                self:header(command, self.verbose)
            elseif command_tag == "vardef" then
                self:vardef(command, self.verbose)
            elseif command_tag == "begin" then
                self:begin(command, self.verbose)
            elseif command_tag == "end" then
                self:end_(command, self.verbose)
            elseif command_tag == "attr" then
                self:attr(command, self.verbose)
            elseif command_tag == "funcall" then
                self:funcall(command, self.verbose)
            elseif command_tag == "if" then
                self:if_(command, self.verbose)
            elseif command_tag == "else" then
                self:else_(command, self.verbose)
            elseif command_tag == "fi" then
                self:fi(command, self.verbose)
            elseif command_tag == "print" then
                self:print(command, self.verbose)
            end
        end
    end
    return nil
end


--- Lê o header de uma função. Caso seja "main", inicializa a callstack. Caso contrário, ele é ignorado.
-- @param command Header de função.
-- @param verbose Imprime mensagens do debugger.
-- @return nil
function Runner:header(command, verbose)
    
    local function_name = name_from_function_header(command, verbose)
    if function_name == 'main' then
        self.callstack:push("main")
    end

    if verbose == true then
        message = "DEBUG Runner:header( %s) :: function_name == %s;"
        message = string.format(message, command, function_name)
        print(message)
    end
    return nil
end

--- Lê uma definição de variável ou de array.
-- @param command Definição de variável ou array.
-- @param verbose Imprime mensagens do debugger.
-- @return nil
function Runner:vardef(command, verbose)
    local varname = get_varname(command, verbose)
    local varsize = get_varsize(command, verbose)
    local array_initial_value
    local variable_initial_value

    --- Valor de inicialização das posições de um array declarado.
    array_initial_value = 0

    --- Valor de inicialização das posições de uma variável declarada.
    variable_initial_value = 0

    if varsize ~= nil then
        self.callstack:define(varname.."_size_", varsize)
        for i = 0, varsize-1 do
            self.callstack:define(varname.."["..tostring(i).."]", array_initial_value)
        end
    else 
        self.callstack:define(varname, variable_initial_value)
    end
    if verbose == true then
        message = "DEBUG Runner:vardef( %s ) :: varname == %s ; varsize == %s ;"
        message = string.format(command, varname, varsize)
        print(message)
    end
    return nil
end

--- Lê um comando "begin", e em seguida, retorna um valor nulo.
-- @param command Comando "begin".
-- @param verbose Imprime mensagens do debugger.
-- @return nil
function Runner:begin(command, verbose)
    if verbose == true then
        message = "DEBUG Runner:begin ( %s )"
        message = string.format(message, command)
        print(message)
    end
    return nil
end

--- Lê um comando "end". Elimina o escopo da função atual, e adiciona um par chave : valor
-- ao escopo da função que a chamou. A chave é o nome da função atual, e o valor é o seu
-- valor de retorno.
-- @param command Comando "end".
-- @param verbose Imprime mensagens do debugger.
-- @return nil
function Runner:end_(command, verbose)
    local _end = string.match(command,"end%s*")
    local _end_name
    local _end_value

    --- Nome da função a ser finalizada.
    _end_name = nil
    --- Valor de retorno da função a ser finalizada.
    _end_value = nil

    _end_name = self.callstack.functions[self.callstack.counter]
    if _end_name ~= "main" then
        _end_value = self.callstack:find("ret", _end_name)  
        self.callstack:pop()
        if _end_value ~= nil then
            self.callstack:define(_end_name,_end_value) 
        else
	        self.callstack:define(_end_name,0)
	    end
    end
    if verbose == true then
        message = "DEBUG Runner:end_( %s ) :: _end == %s; name == %s; value == %s"
        message = string.format(message, command, _end, _end_name, _end_value)
        print(message)
    end
    return nil
end

--- Lê uma atribuição de valor a variável, que pode ter um argumento ou uma operação aritmética entre dois argumentos.
-- @param command Comando com atribuição.
-- @param verbose Imprime mensagens do debugger.
-- @raise Erro de acesso a índice fora do alcance do vetor.
-- @return nil
function Runner:attr(command, verbose)
    local verbose 
    local var 
    local arg1 
    local op 
    local arg2 
    local num1 
    local num2 
    local result 
    local varname 
    local varvalue  

    verbose = verbose or false
    var , arg1 , op , arg2 = get_attrvalues( command , verbose )
    num1 = get_argvalue( arg1 , self , verbose )
    num2 = nil
    result = nil
    varname = nil
    varvalue = nil

    if op ~= nil then
        num2 = get_argvalue( arg2 , self , verbose )
        result = get_result( num1 , op , num2 , verbose )
    else
        result = num1
    end
    
    varname , varvalue = get_var( var , verbose )
    if varvalue == nil then
        self.callstack:assign(varname,result)
    else
        if varvalue < self.callstack:find(varname.."_size_") then
            self.callstack:assign(varname.."["..varvalue.."]",result)
        else
            print("ERRO: acesso a índice fora do alcance do vetor.")
            os.exit()
        end
    end

    
    if verbose == true then
        message = "DEBUG Runner:attr :: var == %s ; arg1 == %s ; op == %s ; arg2 == %s"
        message = string.format( message , var , arg1 , op , arg2 )
        print(message)
        message = "DEBUG Runner:attr :: num1 == %s ; num2 == %s ; result == %s ;"
        message = string.format( message , num1 , num2 , result )
        print(message)
        message = "DEBUG Runner:attr :: varname == %s ; varvalue == %s ;"
        message = string.format( message , varname , varvalue )
        print(message)
    end
    return nil
end

--- Lê e executa uma chamada de função.
-- @param command Comando com chamada de função.
-- @param verbose Imprime mensagens do debugger.
-- @return nil
function Runner:funcall(command, verbose)
    
    local verbose = verbose or false
    local param1,param2, param3 = nil,nil,nil
    local value1, value2, value3 = nil,nil,nil
    local name = name_from_function_call(command, verbose)
    local index = self:find_function_index(name)
    local function_commands = self.function_list[index]
    local function_tags = self.function_list_tags[index]
    
    local header = function_commands[1]
    local name1,name2,name3 = get_param(header, verbose)
    
    param1,param2, param3 = get_param(command, verbose)

    self.callstack:push(name)

    if verbose == true then
        message = "DEBUG Runner:funcall( %s ) :: param1 == %s ; param2 == %s ; param3 == %s"
        message = string.format(message, command, param1, param2, param3)
        print(message)
        message = "DEBUG Runner:funcall( %s ) :: value1 == %s ; value2 == %s ; value3 == %s"
        message = string.format(message, command, value1, value2, value3)
        print(message) 
        message = "DEBUG Runner:funcall( %s ) :: name == %s ; index == %s ; header == %s"
        message = string.format(message, command, name, index, header)
        print(message)      
        message = "DEBUG Runner:funcall( %s ) :: parent_function == %s"
        message = string.format(message, command, parent_function)
        print(message)       
    end

    if param3 ~= nil then
        value3 = get_value(param3,run, verbose)
        self.callstack:define_param(name3, value3)
    end

    if param2 ~= nil then
        value2 = get_value(param2,run, verbose)
        self.callstack:define_param(name2, value2)

    end

    if param1 ~= nil then
        value1 = get_value(param1,run, verbose)
        self.callstack:define_param(name1, value1)
    end    
    
    self:execute(function_commands, function_tags)

    if verbose == true then
        message = "DEBUG Runner:funcall( %s ) :: param1 == %s ; param2 == %s ; param3 == %s"
        message = string.format(message, command, param1, param2, param3)
        print(message)
        message = "DEBUG Runner:funcall( %s ) :: value1 == %s ; value2 == %s ; value3 == %s"
        message = string.format(message, command, value1, value2, value3)
        print(message) 
        message = "DEBUG Runner:funcall( %s ) :: name == %s ; index == %s ; header == %s"
        message = string.format(message, command, name, index, header)
        print(message)      
        message = "DEBUG Runner:funcall( %s ) :: parent_function == %s"
        message = string.format(message, command, parent_function)
        print(message)       
    end

    return nil
end

--- Executa um teste de um if após resolver os operadores em números. 
-- @param command Comando com o teste de if.
-- @param verbose Imprime mensagens do debugger.
-- @return nil
function Runner:if_(command, verbose)
    local value1, op, value2 = get_if(command, verbose)
    local num1 = get_value(value1,self, verbose)
    local num2 = get_value(value2,self, verbose)
    local exp = nil
    if op == "<" then
        exp = num1 < num2
    elseif op == "<=" then
        exp = num1 <= num2
    elseif op == ">" then
        exp = num1 > num2
    elseif op == ">=" then
        exp = num1 >= num2
    elseif op == "==" then
        exp = num1 == num2
    elseif op == "!=" then
        exp = num1 ~= num2
    end
    self.if_status = exp
    if verbose == true then
        message = "DEBUG Runner:if_( %s ) :: value1 == %s ; op == %s ; value2 == %s"
        message = string.format(message, command, value1, op, value2)
        print(message)
        message = "DEBUG Runner:if_( %s ) :: num1 == %s ; num2 == %s ; exp == %s"
        message = string.format(message, command, num1, num2, exp)
        print(message)
    end
    return nil
end

--- Lê um comando "else" e atualiza o estado da variável interna if_status.
-- @param command Comando "else".
-- @param verbose Imprime mensagens do debugger.
-- @return nil
function Runner:else_(command, verbose)
    self.if_status = not self.if_status
    if verbose == true then
        print(string.format("DEBUG Runner:else_( %s )", command))
    end
    return nil
end

--- Lê um comando "fi" e atualiza o estado da variável interna if_status.
-- @param command Comando "fi".
-- @param verbose Imprime mensagens do debugger.
-- @return nil
function Runner:fi(command, verbose)
    self.if_status = nil
    if verbose == true then
        print(string.format("DEBUG Runner:fi( %s )", command))
    end
    return nil
end

--- Lê um comando "print", resolve a variável e imprime seu valor na tela.
-- @param command Comando "print".
-- @param verbose Imprime mensagens do debugger.
-- @return nil
function Runner:print(command, verbose)
    arg = string.match(command,"print%((.+)%)")
    num = get_value(arg,self, verbose)
    print(num)
    if verbose == true then
        print(string.format("DEBUG Runner:print( %s )", command))
    end
    return nil
end