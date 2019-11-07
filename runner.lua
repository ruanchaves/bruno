require 'utils'
require 'callstack'
require 'get'

Runner = {}
Runner.__index = Runner

function Runner:create(function_list, function_list_tags)
    runner_object = {}
    setmetatable(runner_object, Runner)
    runner_object.function_list = function_list
    runner_object.function_index = {}
    runner_object.callstack = CallStack:create()
    for i, v in ipairs(function_list) do
        header = v[1]
        key = name_from_function_header(header)
        runner_object.function_index[key] = i
    end
    runner_object.function_list_tags = function_list_tags
    runner_object.if_status = nil
    runner_object.current_function = nil
    runner_object.verbose = false
    return runner_object
 end

function Runner:find_function_index(name)
    for key, value in pairs(self.function_index) do
        if key == name then
            return value
        end
    end
end

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
end


function Runner:header(command, verbose)
    local function_name = name_from_function_header(command, verbose)
    self.current_function = function_name

    if function_name == 'main' then
        self.callstack:push("main")
    end
    if verbose == true then
        message = "DEBUG Runner:header( %s) :: function_name == %s;"
        message = string.format(message, command, function_name)
        print(message)
    end
end


function Runner:vardef(command, verbose)
    local varname = get_varname(command, verbose)
    local varsize = get_varsize(command, verbose)

    if varsize ~= nil then
        if varsize == 0 then
            print("ERRO: acesso a chave com valor menor que 1.")
            os.exit()
        end
        self.callstack:assign(varname.."_size_", varsize)
        for i = 0, varsize-1 do
            self.callstack:assign(varname.."["..tostring(i).."]", varsize)
        end
    else 
        self.callstack:assign(varname, 0)
    end
    if verbose == true then
        message = "DEBUG Runner:vardef( %s ) :: varname == %s ; varsize == %s ;"
        message = string.format(command, varname, varsize)
        print(message)
    end
end

function Runner:begin(command, verbose)
    if verbose == true then
        message = "DEBUG Runner:begin ( %s )"
        message = string.format(message, command)
        print(message)
    end
    --Fazer nada
end


function Runner:end_(command, verbose)
    local _end = string.match(command,"end%s*")
    local name, value = nil, nil

    if self.current_function ~= "main" then
        name = self.current_function
        value = self.callstack:find_local("ret",name)  
        self.callstack:pop()
        if value ~= nil then
            self.callstack:assign(name,value) 
        else
	    self.callstack:assign(name,0)
	end
    end
    if verbose == true then
        message = "DEBUG Runner:end_( %s ) :: _end == %s; name == %s; value == %s"
        message = string.format(message, command, _end, name, value)
        print(message)
    end
end


function Runner:attr(command, verbose)
    local verbose = verbose or false
    local var,arg1,op,arg2 = get_attrvalues(command, verbose)
    local num1 = get_argvalue(arg1,self, verbose)
    local num2 = nil
    local result = nil
    local varname = nil
    local varvalue = nil

    if op ~= nil then
        num2 = get_argvalue(arg2,self, verbose)
        result = get_result(num1,op,num2, verbose)
    else
        result = num1
    end
    
    varname, varvalue = get_var(var, verbose)
    if varvalue == nil then
        self.callstack:assign(varname, result)
    else
        if varvalue < self.callstack:find(varname.."_size_") then
            self.callstack:assign(varname.."["..varvalue.."]", result)
        else
            print("ERRO: acesso a índice fora do alcance do vetor.")
            os.exit()
        end
    end

    
    if verbose == true then
        message = "DEBUG Runner:attr :: var == %s ; arg1 == %s ; op == %s ; arg2 == %s"
        message = string.format(message, var, arg1, op, arg2)
        print(message)
        message = "DEBUG Runner:attr :: num1 == %s ; num2 == %s ; result == %s ;"
        message = string.format(message, num1, num2, result)
        print(message)
        message = "DEBUG Runner:attr :: varname == %s ; varvalue == %s ;"
        message = string.format(message, varname, varvalue)
        print(message)
    end
end


function Runner:funcall(command, verbose)
    local verbose = verbose or false
    local param1,param2, param3 = nil,nil,nil
    local value1, value2, value3 = nil,nil,nil
    --deixar invertido pode dar problema
    local name = name_from_function_call(command, verbose)
    local index = self:find_function_index(name)
    local function_commands = self.function_list[index]
    local function_tags = self.function_list_tags[index]
    
    local header = function_commands[1]
    local name1,name2,name3 = get_param(header, verbose)

    local parent_function = nil
    
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
        self.callstack:assign(name3, value3)
    end

    if param2 ~= nil then
        value2 = get_value(param2,run, verbose)
        self.callstack:assign(name2, value2)

    end

    if param1 ~= nil then
        value1 = get_value(param1,run, verbose)
        self.callstack:assign(name1, value1)
    end    
    
    parent_function = self.current_function
    self:execute(function_commands, function_tags)
    self.current_function = parent_function

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

end


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
end


function Runner:else_(command, verbose)
    self.if_status = not self.if_status
    if verbose == true then
        print(string.format("DEBUG Runner:else_( %s )", command))
    end
end


function Runner:fi(command, verbose)
    self.if_status = nil
    if verbose == true then
        print(string.format("DEBUG Runner:fi( %s )", command))
    end
end

function Runner:print(command, verbose)
    arg = string.match(command,"print%((.+)%)")
    num = get_value(arg,self, verbose)
    print(num)
    if verbose == true then
        print(string.format("DEBUG Runner:print( %s )", command))
    end
end
