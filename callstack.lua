-- -------------------------
-- CALL STACK
-- -------------------------

CallStack = {}
CallStack.__index = CallStack

function CallStack:create()
   local callstack_object = {}
   setmetatable(callstack_object, CallStack)
   callstack_object.records = {}
   callstack_object.counter = -1
   return callstack_object
end

function CallStack:push(value)
   self.counter = self.counter + 1
   self.records[self.counter] = value
end

function CallStack:pop()
   current_value = self.records[self.counter]
   self.counter = self.counter - 1
   return current_value
end

function CallStack:peek()
   return self.records[self.counter]
end
