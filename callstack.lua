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
   --- Pilha de tabelas de escopo de funções para variáveis.
   callstack_object.records = {}
   --- Pilha de tabelas de escopo de funções para parâmetros.
   callstack_object.params = {}
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
   self.params[self.counter] = {}
   self.functions[self.counter] = function_name
end

--- Remove e retorna um escopo de função do topo da callstack.
-- @return Tabela de escopo de função.
function CallStack:pop()
   current_value = table.clone(self.records[self.counter])
   self.records[self.counter] = nil
   self.params[self.counter] = nil
   self.counter = self.counter - 1
   return current_value
end

--- Retorna o escopo de função no topo da callstack.
-- @return Tabela de escopo de função.
function CallStack:peek()
   return self.records[self.counter]
end

--- Atribui um valor a uma variável já definida ou a um parâmetro.
-- @param var Variável.
-- @param value Valor.
-- @raise Erro na atribuição a variável não definida em nenhum escopo ou não especificada como parâmetro no escopo atual.
-- @return nil
function CallStack:assign(var, value)
   local last_tab_idx

   last_tab_idx = nil

   if var == 'ret' then
      self.records[self.counter][var] = value
      return nil
   end

   for param, param_value in pairs(self.params[self.counter]) do
      if param == var then
         self.params[self.counter][var] = value
         return nil
      end
   end

   for tab_idx, tab in ipairs(self.records) do
      for current_var, current_value in pairs(tab) do
         if current_var == var then
            last_tab_idx = tab_idx
         end
      end
   end

   if last_tab_idx ~= nil then
      self.records[last_tab_idx][var] = value
      return nil
   end

   error("ERRO: Atribuição a variável não definida e não especificada como parâmetro no escopo atual.")

end

--- Cria um par chave:valor correspondente a uma variável no escopo de função no topo da callstack.
-- @param var Chave.
-- @param value Valor.
-- @return nil
function CallStack:define(var, value)
   self.records[self.counter][var] = value
end

--- Cria um par chave:valor correspondente a um parâmetro no escopo de função no topo da callstack.
-- @param var Chave.
-- @param value Valor.
-- @return nil
function CallStack:define_param(var, value)
   self.params[self.counter][var] = value
end

--- Tenta retornar o valor de um parâmetro no escopo atual com o nome da variável. Caso o parâmetro não seja encontrado, percorre toda a callstack, da base ao topo, e retorna o valor da última variável encontrada com o nome indicado.
-- @param var Nome da variável.
-- @return Valor da variável.
function CallStack:find(var)
   local found_value = nil

   for param, param_value in pairs(self.params[self.counter]) do
      if param == var then
         return param_value
      end
   end

   for tab_idx, tab in ipairs(self.records) do
      for current_var, current_value in pairs(tab) do
         if current_var == var then
            found_value = current_value
         end
      end
   end

   return found_value
end