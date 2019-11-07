function fat(i)
    var tmp
begin
    tmp = i - 1
    if i == 1 then
	print(111)
        ret = 1
    else
	print(222)
        ret = i * fat(tmp)
    fi
end

function main()
    var f 
begin
    f = fat(3) 
    print(f)
end
