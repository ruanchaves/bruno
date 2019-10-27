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
        if commandtag == "header_1" then
            self:header_1(command, command_tag)
        elseif command_tag == "header_2" then
            self:header_2(command, command_tag)
        elseif command_tag == "var_1" then
            self:var_1(command, command_tag)
        elseif command_tag == "var_2" then
            self:var_2(command, command_tag)
        elseif command_tag == "begin" then
            self:begin(command, command_tag)
        elseif command_tag == "end" then
            self:end_(command, command_tag)
        elseif command_tag == "attr_1" then
            self:attr_1(command, command_tag)
        elseif command_tag == "attr_2" then
            self:attr_2(command, command_tag)
        elseif command_tag == "funcall_1" then
            self:funcall_1(command, command_tag)
        elseif command_tag == "funcall_2" then
            self:funcall_2(command, command_tag)
        elseif command_tag == "if_then" then
            self:if_then(command, command_tag)
        elseif command_tag == "else" then
            self:else_(command, command_tag)
        elseif command_tag == "fi" then
            self:fi(command, command_tag)
	    else
	    end
    end
end


function Runner:header_1(command, command_tag)
    if name_from_function_header(command) == 'main' then
        self.callstack:push()
        self.callstack:assign('__call__', command)
    end
end


function Runner:header_2(command, command_tag)
end


function Runner:var_1(command, command_tag)
end


function Runner:var_2(command, command_tag)
end


function Runner:begin(command, command_tag)
end


function Runner:end_(command, command_tag)
    previous_context = self.callstack:pop()
    call = previous_context['__call__']
    ret = previous_context['ret']
    self.callstack:assign(call, ret)
end


function Runner:attr_1(command, command_tag)
end


function Runner:attr_2(command, command_tag)
end


function Runner:funcall_1(command, command_tag)
    name = name_from_function_call(command)
    index = self:find_function_index(name)
    function_commands = self.function_list[index]
    function_tags = self.function_list_tags[index]
    self.callstack:push()
    self.callstack:assign('__call__', command)
    self:execute(function_commands, function_tags)
end


function Runner:funcall_2(command, command_tag)
end


function Runner:if_then(command, command_tag)
end


function Runner:else_(command, command_tag)
end


function Runner:fi(command, command_tag)
end

