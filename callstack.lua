------------
-- CallStack necessária para gerenciamento de escopo de funções.
-- @module CallStack
-- @author Juliana Resplande Sant'Anna Gomes, Ruan Chaves Rodrigues
-- @license MIT

require 'utils'

CallStack = {}
CallStack.__index = CallStack

--- Cria a callstack.
-- @return Um objeto CallStack.
function CallStack:create()
   local callstack_object = {}
   setmetatable(callstack_object, CallStack)
   --- Pilha de tabelas de escopo de funções.
   callstack_object.records = {}
   --- Contador que indica o índice do escopo atual em records.
   callstack_object.counter = 0
   --- Lista que indica o nome de função correspondente a cada índice de tabela em records.
   callstack_object.functions = {}
   return callstack_object
end

--- Cria o escopo de uma função na callstack.
-- @param function_name Nome da função a ser criada.
function CallStack:push(function_name)
   self.counter = self.counter + 1
   self.records[self.counter] = {}
   self.functions[self.counter] = function_name
end

--- Remove e retorna um escopo de função do topo da callstack.
-- @return Tabela de escopo de função.
function CallStack:pop()
   current_value = table.clone(self.records[self.counter])
   self.records[self.counter] = nil
   self.counter = self.counter - 1
   return current_value
end

--- Retorna o escopo de função no topo da callstack.
-- @return Tabela de escopo de função.
function CallStack:peek()
   return self.records[self.counter]
end

--- Cria um par chave:valor correspondente a uma variável no escopo de função no topo da callstack.
-- @param var Chave.
-- @param value Valor.
-- @return nil
function CallStack:assign(var, value)
   self.records[self.counter][var] = value
end

--- Percorre toda a callstack, da base ao topo, e retorna o valor da última variável encontrada com o nome indicado.
-- @param var Nome da variável.
-- @return Valor da variável.
function CallStack:find(var)
   local found_value = nil

   for tab_idx, tab in ipairs(self.records) do
      for key, value in pairs(tab) do
         if key == var then
            found_value = value
         end
      end
   end
   return found_value
end