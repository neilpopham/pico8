player=class:new({
    reset=function(_ENV)
        s=0
        dx=0
        dy=0
    end,
    update=function(_ENV)
        -- ⬅️➡️⬆️⬇️🅾️❎
        if s==0 then
            if btn(⬅️) then dx=-1
            elseif btn(➡️) then dx=1
            elseif btn(⬆️) then dy=-1
            elseif btn(⬇️) then dy=1 end

            -- printh('x='..x..' y='..y)

            if dx!=0 or dy!=0 then
                hit=false
                tx=tile(x+dx+(dx>0 and 15 or 0))
                ty=tile(y+dy+(dy>0 and 15 or 0))
                ti=mget(tx,ty)
                if ti==0 then
                    hit=true
                else
                    hit=fget(ti,0)

                end
                -- printh('tx='..tx..' ty='..ty..' tile='..ti..' flags='..(fget(ti)))
                if hit then
                    dx,dy=0,0
                else
                    nx=x+(dx*16)
                    ny=y+(dy*16)
                    s=1
                    -- printh('nx='..nx..' ny='..ny)
                end
            end
        else
            x+=dx
            y+=dy
            -- printh('nx='..nx..' ny='..ny..' x='..x..' y='..y)
            if x==nx and y==ny then
                dx,dy,s=0,0,0
            end
        end

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