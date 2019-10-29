require 'utils'
require 'callstack'

Runner = {}
Runner.__index = Runner

function Runner:create(function_list, function_list_tags)
    local runner_object = {}
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
    return runner_object
 end

function Runner:find_function_index(name)
    for key, value in pairs(self.function_index) do
        if key == name then
            return name
        end
    end
end

function Runner:execute(cmds, cmd_tags)
    for key, value in ipairs(cmds) do
        local command = value
        local command_tag = cmd_tags[key]
        print("Executar = " .. value)
        print("command_tag = "..command_tag)
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
        else
            print("Deu ruim")
        end
    end
end


function Runner:header(command, command_tag)
    local param1, param2, param3 = get_param(command)
    
    print("Entrou em " .. name_from_function_header(command))

    if name_from_function_header(command) == 'main' then
        self.callstack:push()
        self.callstack:assign('__call__', command)
    end
end


function Runner:vardef(command, command_tag)
    local varname = get_varname(command)
    local varsize = get_varsize(command)
    --local test = "var " .. varname
    --if varsize ~= nil then
    --    test = test .. "[" .. varsize .. "]"
    --end

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
        --print("Armazenou na pilha")
        --print(self.callstack:find(varname))
    end

    print(test)
end

function Runner:begin(command, command_tag)
    --Fazer nada
end


function Runner:end_(command, command_tag)
    local _end = string.match(command,"end%s*")

    --fazer pop
    local previous_context = self.callstack:pop()
    local call = previous_context['__call__']
    local ret = previous_context['ret']
    ---inicializar com 0
    self.callstack:assign(call, ret)
end


function Runner:attr(command, command_tag)
    local var,arg1,op,arg2 = get_attrvalues(command)

    local num1 = get_argvalues(arg1)
    if op ~= nil then:
        local num2 = get_argvalues(arg2)
        local result = get_result(num1,op,num2)
    else:
        local result = num1
    
    local varname, varvalue = get_var(var)
    if varvalue ~= nil then:
        self.callstack:assign(varname, result)
    else:
        if varvalue < self.callstack:find(varname.."_size_") then
            self.callstack:assign(varname.."["..tostring(varvalue).."]", result)
        else then
            print("Vetor estorou")
            os.exit()
        end
end


function Runner:funcall(command, command_tag)
    local name = name_from_function_call(command)
    local index = self:find_function_index(name)
    local function_commands = self.function_list[index]
    local function_tags = self.function_list_tags[index]
    self.callstack:push()
    self.callstack:assign('__call__', command)
    self:execute(function_commands, function_tags)
end


function Runner:if_(command, command_tag)
end


function Runner:else_(command, command_tag)
end


function Runner:fi(command, command_tag)
end

