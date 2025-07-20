entities={}

-- set Flag 7 to face right
makefrog=function(x,y,flags)
    local entity=frog:new({x=x*8+2,y=y*8+7,d=right(flags) and 1 or -1})
    entity:reset()
    add(entities,entity)
end

-- looks for a beam placeholder, finds the end and makes a beam entity
makebeam=function(x,y,flags)
    if flags==0 then return end
    local y2=y
    repeat
        y2+=1
    until fget(mget(x,y2+1))>0
    for i=y,y2 do
        mset(x,i,47)
    end
    local entity=beam:new({tx=x,ty1=y,ty2=y2,idx=flags&15})
    entity:reset()
    add(entities,entity)
end

-- set Flag 7 to face right
makebutton=function(x,y,flags)
    local entity=button:new({x=x*8,y=y*8,idx=flags&15,dx1=right(flags) and 0 or 4,dx2=right(flags) and 3 or 7})
    entity:reset()
    add(entities,entity)
end

converters={
    [127]=makefrog,
    [126]=makebutton,
    [125]=makebeam,
}

for tile in all(_tiftiles) do
    local x,y,s,f=unpack(split(tile,":"))
    converters[s](x,y,f)
end
