regex = "(.+)%s+([+|-|*|/])%s+(.+)%s*"
local arg1, op, arg2 = string.match("-1 - -2", regex)
print(arg1)
print(op)
print(arg2)