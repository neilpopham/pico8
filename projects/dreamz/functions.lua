function keywithfixedlengths(data,l)
    local items,r=split(data,";"),{}
    for item in all(items) do
        local b,d=split(item),{}
        local k=b[1]
        r[k]={}
        for i=2,#b do
            add(d,b[i])
            if #d==l then add(r[k],d) d={} end
        end
    end
    return r
end

function keywithfixedlength(data,l)
    local b,m,r,d=split(data),l+1,{},{}
    for i=1,#b do
        if i%m==1 then k=b[i] else add(d,b[i]) end
        if i%m==0 then r[k]=d d={} end
    end
    return r
end

function fixedlength(data,l)
    local b,r,d=split(data),{},{}
    for i=1,#b do
        add(d,b[i])
        if #d==l then add(r,d) d={} end
    end
    return r
end

function random(n) return flr(rnd(n))+1 end