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
    var a
begin  
    x = 5
    y = -6
    z = 6 / 7
    print(z)
    z = x
    z = x + y 
    v[0] = 5 
    x = v[0] + 10
    v[1] = 30
    x = v[0] + v[1]
    print(-20)
    print(x)
    print(v[0])
    saida  = foo(500,v[1],y)
    extra(x)
    print(saida)
    if v[0] == 3 then
    	print(7)
    else
    	print(9)
    fi
    if saida == 3 then
    	print(111)
    fi
    a = -1 - -2
    print(a)
    v[-2] = 12
    print(v[1])
end
