require 'callstack'

-- -------------------------
-- CALL STACK TEST
-- -------------------------

CALL_STACK = CallStack:create()
CALL_STACK:push(100)
assert(CALL_STACK.counter == 0, "CallStack failure : counter.")
assert(CALL_STACK:peek() == 100, "CallStack failure : peek().")
assert(CALL_STACK:pop() == 100, "CallStack failure : pop().")

print("The interpreter passed all the tests.")