require 'callstack'

-- -------------------------
-- CALL STACK TEST
-- -------------------------

-- CALL_STACK = CallStack:create()
-- CALL_STACK:push(100)
-- assert(CALL_STACK.counter == 0, "CallStack failure : counter.")
-- assert(CALL_STACK:peek() == 100, "CallStack failure : peek().")
-- assert(CALL_STACK:pop() == 100, "CallStack failure : pop().")

-- print("The interpreter passed all the tests.")

Fib = {}
Fib.__index = Fib

function Fib:create()
    local runner_object = {}
    setmetatable(runner_object, Fib)
    return runner_object
end

function Fib:execute(n)
    if n <= 1 then
        return n
    end
    return self:execute(n-1) + self:execute(n-2)
end

fib_test = Fib:create()
print(fib_test:execute(9))
-- print(f:execute(9))

