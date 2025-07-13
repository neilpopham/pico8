
endex=0
entities={}
buttons={}
beams={}

-- sets direction according to flags 10000000 = l, 01000000 = r
makefrog=function(x,y,flags)
    local entity=frog:new({x=x*8+2,y=y*8+7,d=flags==2 and 1 or -1,entity=endex})
    printh('frog '..endex)
    entity:reset()
    add(entities,entity)
end

-- looks for a beam placeholder, finds the end and makes a beam entity
makebeam=function(x,y,flags)
    local y2=y
    repeat
        y2+=1
        ti=mget(x,y2)
    until ti==114
    for i=y,y2 do
        mset(x,i,63)
    end
    local entity=beam:new({tx=x,ty1=y,ty2=y2,entity=endex})
    printh('beam '..endex)
    entity:reset()
    add(entities,entity)
    add(beams,{x=x,y=y,i=endex})
end

makebutton=function(x,y,flags)
    local entity=button:new({x=x*8,y=y*8,dx1=flags==2 and 0 or 4,dx2=flags==2 and 3 or 7})
    printh('button '..endex)
    entity:reset()
    add(entities,entity)
    add(buttons,{x=x,y=y,i=endex})
end

converters={
    [112]=makefrog,
    [113]=makefrog,
    [114]=makebeam,
    [115]=makebutton,
    [116]=makebutton,
}

for ty=0,255 do
    for tx=0,128 do
        local ti=mget(tx,ty)
        if ti>=112 then
            mset(tx,ty,0)
            endex+=1
            converters[ti](tx,ty,fget(ti))
            printh("endex "..endex)
        end
    end
end

button_links={
    [57]={
        [59]={x=67,y=60}
    },
}

for bx,rows in pairs(button_links) do
    for by,b in pairs(rows) do
        for button in all(buttons) do
            if button.x==bx and button.y==by then
                for beam in all(beams) do
                    if beam.x==b.x and beam.y==b.y then
                        entities[button.i].beam=beam.i
                    end
                end
            end
        end
    end
end
