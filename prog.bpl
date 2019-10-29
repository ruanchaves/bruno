function foo(x)
begin  
    print(x)
end

function main()  
    var x
    var y
    var z
    var v[2]
begin  
    x = 5
    y = -6
    z = 6 + 7
    z = x
    z = x + y 
    v[1] = 5 
    x = v[1] + 10
    v[2] = 30
    x = v[1] + v[2]
    print(-20)
    print(x)
    print(v[1])
    foo(v[12])
end
