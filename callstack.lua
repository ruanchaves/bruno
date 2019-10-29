-- -------------------------
-- CALL STACK
-- -------------------------

require 'utils'

CallStack = {}
CallStack.__index = CallStack

function CallStack:create()
   local callstack_object = {}
   setmetatable(callstack_object, CallStack)
   callstack_object.records = {}
   callstack_object.counter = 0
   return callstack_object
end

function CallStack:push()
   self.counter = self.counter + 1
   self.records[self.counter] = {}
end

function CallStack:pop()
   current_value = table.clone(self.records[self.counter])
   self.records[self.counter] = nil
   self.counter = self.counter - 1
   return current_value
end

function CallStack:peek()
   return self.records[self.counter]
end

function CallStack:assign(var, value)
   self.records[self.counter][var] = value
end

function CallStack:find(var)
   found_value = nil
   for tab_idx, tab in ipairs(self.records) do
      for key, value in pairs(tab) do
         if key == var then
            found_value = value
         end
      end
   end
   return found_value
end

function CallStack:find_local(var)
   found_value = nil
      for key, value in pairs(self.records[self.counter]) do
         if key == var then
            found_value = value
         end
      end
   return found_value
end