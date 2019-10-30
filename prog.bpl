function foo(a,b,c)
begin
    print(a)  
    print(b)
    print(c)
    ret = 3
end

function bar(x,y)
begin
    print(1000)
    print(x)  
    print(y)
end

function extra(x)
begin
    print(200)  
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
    saida  = foo(500,v[2],y)
    extra(x)
    print(saida)
end
