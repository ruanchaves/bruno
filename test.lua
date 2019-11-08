------------
-- Executa todos os testes especificados na pasta de testes.
-- @module test
-- @author Juliana Resplande Sant'Anna Gomes, Ruan Chaves Rodrigues
-- @license MIT

--- Lista de testes. Representada como lista de dicionários com as chaves filename e expected_output.
-- @field filename Caminho para o arquivo.
-- @field expected_output Lista de valores de saída esperados.
instructions = {
    {
        ["filename"]= "./tests/exemplo1.bpl",
        ["expected_output"]= {12}
    },
    {
        ["filename"]= "./tests/exemplo2.bpl",
        ["expected_output"]= {10}
    },
    {
        ["filename"]= "./tests/exemplo3.bpl",
        ["expected_output"]= {5, 3}
    },    
    {
         ["filename"]= "./tests/exemplo4.bpl",
         ["expected_output"]= {6}
    },
    {
        ["filename"]= "./tests/exemplo5.bpl",
        ["expected_output"]= {1, 10, "ERRO: acesso a índice fora do alcance do vetor."}
    },
    {
        ["filename"]= "./tests/exemplo6.bpl",
        ["expected_output"]= {50, 50, 5}
    },
    {
        ["filename"]= "./tests/exemplo7.bpl",
        ["expected_output"]= {20}
    },
    {
        ["filename"]= "./tests/exemplo8.bpl",
        ["expected_output"]= {30}
    },    
}

--- Executa um teste.
-- @param entry Entrada na lista de testes.
-- @param lua Comando que invoca o interpretador de Lua. Por padrão, tem o valor "lua".
-- @param interpretador Comando que invoca o interpretador de BPL. Por padrão, tem o valor "interpretador.lua".
-- @param buffer Nome do arquivo temporário de buffer. Por padrão, tem o valor "buffer.txt".
-- @param buffer_mode Como a shell deve enviar sua saída ao arquivo de buffer. Por padrão, ele é sobrescrito ( ">" ).
-- @param redirection Para onde redirecionar mensagens de erro em Lua (stderr). Por padrão, redireciona para stdout ( 2>&1 ).
-- @return test_report Retorna a data do teste, a saída esperada e o resultado obtido.
function run_test(entry, lua, interpretador, buffer, buffer_mode, redirection)
    test_report = string.format("\n-- DATA: %s", os.date("%c"))
    lua = lua or "lua"
    interpretador = interpretador or "interpretador.lua"
    buffer = buffer or "buffer.txt"
    buffer_mode = buffer_mode or '>'
    redirection = redirection or "2>&1"

    filename = entry["filename"]
    expected_output = entry["expected_output"]

    command = string.format("%s %s %s %s %s %s", lua, interpretador, filename, buffer_mode, buffer, redirection)
    os.execute(command)
    buffer_file = io.open(buffer, "r")
    io.input(buffer_file)
    saida = io.read("*all")
    io.close(buffer_file)
    os.remove(buffer)

    header = string.format("\n----- TESTE: \n -- PROGRAMA TESTADO: %s \n -- RESULTADO ESPERADO:", filename)
    test_report = test_report .. header
    for key, value in pairs(expected_output) do
        value_line = string.format('\n%s', value)
        test_report = test_report .. value_line
    end
    body = string.format("\n-- SAÍDA DO PROGRAMA: \n%s", saida)
    test_report = test_report .. body
    test_report = test_report .. '\n----- FIM \n'
    return test_report
end

--- Executa todos os testes, gerenciando chamadas a run_test.
-- @param results_filename Arquivo onde os resultados devem ser salvos. Por padrão, "report.txt".
-- @param mode Qual modo de escrita deve ser adotado no arquivo de resultados. Por padrão, "a".
-- @return nil
function record_results(results_filename, mode)
    results_filename = results_filename or 'report.txt'
    mode = mode or 'a'
    for idx, entry in pairs(instructions) do
        report = run_test(entry)
        results_file = io.open(results_filename, mode)
        io.output(results_file)
        io.write(report)
        io.close(results_file)
    end
    return nil
end

record_results()