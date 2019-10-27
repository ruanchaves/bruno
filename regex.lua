command = "juliana(jubs)"


function get_funcall(command)
    if string.match(command,"%l+%(.*%)") then
        return ---Runner:funcall
    end
end


function get_var(command)
    varname, varvalue = string.match(command, "(%l+)%[(%-?%d+)%]")
  
    if varname then
        return varname, varvalue
    end


    varname = string.match(command, "%l+")
    if varname then
        return varname
    end

    --error
  end


function get_value(command)
    if string.find("%l", command) == nil then
        number = string.match(command,"(%-?%d+)")
        return number
    end
    
    name,number = get_var(command)
      --dentro do getvar ja vai ter
      ---teste de erro
    return name, number
end

function get_argvalues(command)
    funcall = get_funcall(command)
        if funcall then
            return funcall
        end

    value, number = get_value(command)
        if value then
            return value,number
        end
    
    --ja teria teste de erro no value

end

print(get_argvalues(command))