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
    local function_name = name_from_function_header(command)
    self.current_function = function_name

    if function_name == 'main' then
        self.callstack:push("main")
    end
end


function Runner:vardef(command, verbose)
    local varname = get_varname(command, self.verbose)
    local varsize = get_varsize(command)

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
end

function Runner:begin(command, verbose)
    --Fazer nada
end


function Runner:end_(command, verbose)
    local _end = string.match(command,"end%s*")

    if self.current_function ~= "main" then
        local name = self.current_function
        local value = nil
        local value = self.callstack:find_local("ret",name)  
        self.callstack:pop()
        if value ~= nil then
            self.callstack:assign(name,value) 
        end
    end
end


function Runner:attr(command, verbose)
    verbose = verbose or false

    local var,arg1,op,arg2 = get_attrvalues(command, verbose)
    
    if verbose == true then
        message = "DEBUG RUNNER:ATTR :: var == %s ; arg1 == %s ; op == %s ; arg2 == %s"
        message = string.format(message, var, arg1, op, arg2)
        print(message)
    end
    
    num1 = get_argvalue(arg1,self)
    
    local result
    if op ~= nil then
        local num2 = get_argvalue(arg2,self)
        result = get_result(num1,op,num2)
    else
        result = num1
    end
    
    local varname, varvalue = get_var(var)
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
end


function Runner:funcall(command, verbose)
    local param1,param2, param3 = nil,nil,nil
    param1,param2, param3 = get_param(command)
    local value1, value2, value3 = nil,nil,nil
    --deixar invertido pode dar problema

    local name = name_from_function_call(command)
    local index = self:find_function_index(name)
    local function_commands = self.function_list[index]
    local function_tags = self.function_list_tags[index]
    header = function_commands[1]
    local name1,name2,name3= get_param(header)

    self.callstack:push(name)

    if param3 ~= nil then
        value3 = get_value(param3,run)
        self.callstack:assign(name3, value3)
    end

    if param2 ~= nil then
        value2 = get_value(param2,run)
        self.callstack:assign(name2, value2)

    end

    if param1 ~= nil then
        value1 = get_value(param1,run)
        self.callstack:assign(name1, value1)
    end    
    
    local parent_function = self.current_function
    self:execute(function_commands, function_tags)
    self.current_function = parent_function
end


function Runner:if_(command, verbose)
    local value1, op, value2 = get_if(command)
    local num1 = get_value(value1,self)
    local num2 = get_value(value2,self)
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
end


function Runner:else_(command, verbose)
    self.if_status = not self.if_status
end


function Runner:fi(command, verbose)
    self.if_status = nil
end

function Runner:print(command, verbose)
    arg = string.match(command,"print%((.+)%)")
    num = get_value(arg,self)
    print(num)
end