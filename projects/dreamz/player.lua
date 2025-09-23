player=class:new({
    reset=function(_ENV)

    end,
    update=function(_ENV)
        if btn(0) then p.x-=1 end
        if btn(1) then p.x+=1 end
        if btn(2) then p.y-=1 end
        if btn(3) then p.y+=1 end

        -- printh('x='..x..' y='..y)
        tx,ty=p.x\8,p.y\8
        tile=mget(tx,ty)
        room=rif[p.y\16+1][p.x\16+1]
        local prms=rms[room]
        for k,o in ipairs(rms) do
            o.hidden=true
        end
        prms.hidden=false
        for k,o in ipairs(rms) do
            if o.x==prms.x then
                if prms.mask&1==1 and o.y==prms.y-1 then
                    o.hidden=false
                end
                if prms.mask&4==4 and o.y==prms.y+1 then
                    o.hidden=false
                end
            elseif o.y==prms.y then
                if prms.mask&2==2 and o.x==prms.x+1 then
                    o.hidden=false
                end
                if prms.mask&8==8 and o.x==prms.x-1 then
                    o.hidden=false
                end
            end
        end
    end,
    draw=function(_ENV)
        spr(32,x,y,2,2)
        for k,o in ipairs(rms) do
            if o.hidden then
                rectfill(o.x*112,o.y*112,o.x*112+111,o.y*112+111,15)
            end
        end
    end,
})

p=player:new({x=64,y=64})
p:reset()