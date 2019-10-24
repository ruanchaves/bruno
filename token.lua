-- -------------------------
-- TOKEN
-- -------------------------

Token = {}
Token.__index = Token

function Token:create(type, value)
    local token_object = {}
    setmetatable(token_object, Token)
    token_object.type = type
    token_object.value = value
    return token_object
 end

-- As palavras reservadas são: 
-- “function”, “var”, “if”, “then”, “else”, “fi”,
-- “begin”, “end”.

 RESERVED_KEYWORDS = {
     "function": Token:create("function", "function"),
     "var": Token:create("var", "var"),
     "if": Token:create("if", "if"),
     "then": Token:create("then", "then"),
     "else": Token:create("else", "else"),
     "fi": Token:create("fi", "fi"),
     "begin": Token:create("begin", "begin"),
     "end": Token:create("end", "end")
 }