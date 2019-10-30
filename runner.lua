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
        --print("Executar = " .. value)
        --print("command_tag = "..command_tag)
        if command_tag == "header" then
            self:header(command, command_tag)
        elseif command_tag == "vardef" then
            self:vardef(command, command_tag)
        elseif command_tag == "begin" then
            self:begin(command, command_tag)
        elseif command_tag == "end" then
            self:end_(command, command_tag)
        elseif command_tag == "attr" then
            self:attr(command, command_tag)
        elseif command_tag == "funcall" then
            self:funcall(command, command_tag)
        elseif command_tag == "if_then" then
            self:if_(command, command_tag)
        elseif command_tag == "else" then
            self:else_(command, command_tag)
        elseif command_tag == "fi" then
            self:fi(command, command_tag)
        elseif command_tag == "print" then
            self:print(command, command_tag)
        else
            print("Deu ruim")
        end
    end
end


function Runner:header(command, command_tag)
    local function_name = name_from_function_header(command)
    self.current_function = function_name

    if function_name == 'main' then
        self.callstack:push("main")
        --self.callstack:assign('__call__', command)
    end
end


function Runner:vardef(command, command_tag)
    local varname = get_varname(command)
    local varsize = get_varsize(command)
    --local test = "var " .. varname
    --if varsize ~= nil then
    --    test = test .. "[" .. varsize .. "]"
    --end
    --print(varsize)

    if varsize ~= nil then
        if varsize == 0 then
            print("chave não pode ser 0")
            os.exit()
        end
        self.callstack:assign(varname.."_size_", varsize)
        for i = 1, tonumber(varsize) do
            self.callstack:assign(varname.."["..tostring(i).."]", varsize)
        end
    else 
        self.callstack:assign(varname, '0')
        --print("Esse caso")
        --print("Armazenou na pilha")
        --print(self.callstack:find(varname))
    end
    --print(test)
end

function Runner:begin(command, command_tag)
    --Fazer nada
end


function Runner:end_(command, command_tag)
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


function Runner:attr(command, command_tag)
    local var,arg1,op,arg2 = get_attrvalues(command)
    num1 = get_argvalues(arg1,self)
    
    local result
    if op ~= nil then
        local num2 = get_argvalues(arg2,self)
        result = get_result(num1,op,num2)
    else
        result = num1
    end
    
    local varname, varvalue = get_var(var)
    if varvalue == nil then
        self.callstack:assign(varname, result)
        --print("Armazenou na pilha:")
        --print(self.callstack:find(varname))
    else
        if tonumber(varvalue) <= tonumber(self.callstack:find(varname.."_size_")) then
            self.callstack:assign(varname.."["..varvalue.."]", result)
            --print("Armazenou na pilha:")
            --print(self.callstack:find(varname.."["..varvalue.."]"))
        else
            print("Vetor estorou")
            os.exit()
        end
    end
end


function Runner:funcall(command, command_tag)
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
        value3 = get_argvalues(param3,run)
        self.callstack:assign(name3, value3)
    end

    if param2 ~= nil then
        value2 = get_argvalues(param2,run)
        self.callstack:assign(name2, value2)

    end

    if param1 ~= nil then
        value1 = get_argvalues(param1,run)
        self.callstack:assign(name1, value1)
    end    
    
    --significado
    local parent_function = self.current_function
    --self.callstack:assign('__call__', command)
    self:execute(function_commands, function_tags)
    self.current_function = parent_function
end


function Runner:if_(command, command_tag)
end


function Runner:else_(command, command_tag)
end


function Runner:fi(command, command_tag)
end

function Runner:print(command, command_tag)
    arg = string.match(command,"print%((.+)%)")
    --print("Ta em imprimir")
    --print(command)
    num = get_argvalues(arg,self)
    print(num)
end