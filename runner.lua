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
    runner_object.if_status = true
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
        command = value
        command_tag = cmd_tags[key]
        if commandtag == "header" then
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
	    else --error
	    end
    end
end


function Runner:header(command, command_tag)
    param1, param2, param3 = get_param(command)
    
    if name_from_function_header(command) == 'main' then
        self.callstack:push()
        self.callstack:assign('__call__', command)
    end
end


function Runner:vardef(command, command_tag)
    varname = get_varname(command)
    varsize = get_varsize(command)

    --checar se varsize=0 erro
end

function Runner:begin(command, command_tag)
    begin = string.match(command,"begin%s*")
    -- if begin ~= command then error
end


function Runner:end_(command, command_tag)
    _end = string.match(command,"end%s*")
    -- if begin ~= command then error

    previous_context = self.callstack:pop()
    call = previous_context['__call__']
    ret = previous_context['ret']
    self.callstack:assign(call, ret)
end


function Runner:attr(command, command_tag)
    varname,varvalue,arg1value,arg1number
    op,arg2,arg2number = get_attrvalues(command)

end


function Runner:funcall(command, command_tag)
    name = name_from_function_call(command)
    index = self:find_function_index(name)
    function_commands = self.function_list[index]
    function_tags = self.function_list_tags[index]
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

