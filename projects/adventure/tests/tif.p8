pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- "x:y:sprite:flags,x:y:sprite:flags,x:y:sprite:flags,..."
local __tif__="10:11:3:5,20:21:12:128"
local _tif,_tiftiles={},split(__tif__)
for tile in all(_tiftiles) do
    local x,y,s,f=unpack(split(tile,":"))
    if not _tif[x] then _tif[x]={} end
    _tif[x][y]={s,f}
end

function tget(x,y,f)
    return f==nil and _tif[x][y][2] or _tif[x][y][2]&1<<f>0
end

-- 80 tokens

function tgets(x,y)
    return _tif[x][y][1]
end

-- 93 tokens

function tset(x,y,f,v)
    local _f=_tif[x][y][2]
    _f=v==nil and f or v and _f|1<<f or _f&~(1<<f)
    _tif[x][y][2]=_f
end

-- 142 tokens

cls()
print(tget(10,11))
print("1 = "..tostr(1<<1))
print(tget(10,11,1))
print("2 = "..tostr(1<<2))
print(tget(10,11,2))
print("===")
print(tget(20,21))
print("7 = "..tostr(1<<7))
print(tget(20,21,7))
print("2 = "..tostr(1<<2))
print(tget(20,21,2))
print("===")

tset(10,11,255)
print(tget(10,11))
print("1 = "..tostr(1<<1))
print(tget(10,11,1))
tset(10,11,7,false)
print(tget(10,11))
tset(10,11,7,true)
print(tget(10,11))
tset(10,11,6,false)
print(tget(10,11))
tset(10,11,6,true)
print(tget(10,11))

-- print(1<<2)
-- print(5^^(1<<3))

-- print(255&~(1<<2))

-- print(5&~(1<<2))
-- print(5&~1<<2)