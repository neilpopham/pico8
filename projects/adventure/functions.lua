function mrnd(x,f)
    if f==nil then f=true end
    local r=x[1]+rnd((f and 1 or 0)+x[2]-x[1])
    return f and flr(r) or r
end

function range(n,m)
    return mrnd({n,m})
end

function tile(v) return v\8 end

function round(v) return flr(v+.5) end

function manhattan(x1,y1,x2,y2)
    return abs(x1-x2)+abs(y1-y2)
end

function lerp(v0,v1,t)
    return v0+t*(v1-v0)
end

function set_volumes(sfxid, start, values)
    local address=0x3200+68*sfxid+start*2
    for _,value in ipairs(values) do
        local bytes=%address&0xf1ff
        bytes=bytes|value<<9
        poke2(address,bytes)
        address+=2
    end
end