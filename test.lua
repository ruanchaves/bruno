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
        ["expected_output"]= {5, 50, 20}
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


for idx, entry in pairs(instructions) do
    report = run_test(entry)
    results_file = io.open('report.txt', 'a')
    io.output(results_file)
    io.write(report)
    io.close(results_file)
end
