--  This may need to increase as we create more objects
memset(0x4300, 0, 16)

entities={}

-- Holds the volumes of all beams and decides the currently played volume
beam_volume=split("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0")

-- set Flag 7 to face right
makefrog=function(x,y,flags)
    return frog:new({x=x*8+2,y=y*8+7,d=right(flags) and 1 or -1})
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
    return beam:new({tx=x,ty1=y,ty2=y2,idx=flags&15})
end

-- set Flag 7 to face right
makebutton=function(x,y,flags)
    return button:new({x=x*8,y=y*8,idx=flags&15,dx1=right(flags) and 0 or 4,dx2=right(flags) and 3 or 7})
end

makedrip=function(x,y,flags)
    return drip:new({ox=x*8,oy=y*8})
end

converters={
    [127]=makefrog,
    [126]=makebutton,
    [125]=makebeam,
    [124]=makedrip,
}

-- Flags 0-3 to store UID
-- Flag 4 unused
-- Flag 5 unused
-- Flag 6 for visibility. 0: Visible; 1: Hidden
-- Flag 7 for direction. 0: Left; 1: Right

for tile in all(split(__tif__)) do
    local x,y,s,f=unpack(split(tile,":"))
    local entity=converters[s](x,y,f)
    entity:reset()
    entity.hide=f&64==64
    add(entities,entity)
end
