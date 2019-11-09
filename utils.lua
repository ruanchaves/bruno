------------
-- Funções utilitárias com finalidades diversas que não se encaixam em outros arquivos.
-- @module utils
-- @author Juliana Resplande Sant'Anna Gomes, Ruan Chaves Rodrigues
-- @license MIT


--- Clona uma tabela.
-- @param org Uma tabela.
-- @return Uma tabela.
function table.clone(org)
    return {table.unpack(org)}
  end

--- Imprime uma tabela com ipairs.
-- @param data Uma tabela.
-- @return nil
function print_table(data)
    for key, value in ipairs(data) do
        print('\t', key, value)
    end
    return nil
end

--- Imprime uma tabela com pairs.
-- @param Uma tabela.
-- @return nil
function print_table_unordered(data)
  for key, value in pairs(data) do
    print('\t', key,' : ', value)
  end
  return nil
end

--- Divide uma string em uma lista de tokens separados por espaços.
-- @param line Uma string.
-- @return Uma lista.
function string_split(line)
  local t = {}
    for token in string.gmatch(line, "[^%s]+") do
      table.insert(t, token)
    end
  return t
end