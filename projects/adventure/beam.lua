beam=entity:new({
    reset=function(_ENV)
        x=tx*8
        y=ty1*8
        l=(ty2-ty1+1)*8
        o=false
        s=1
        t=0
    end,
    update=function(_ENV)
        if s==1 then
            local d=min(manhattan(x,y,p.x,p.y1),manhattan(x,y+l,p.x,p.y1))
            local max=160
            if d>max then
                if o then sfx(4,-2) o=false end
            else
                local v=round(mid(0,(max-d)/(max/7),7))
                -- printh(d..':'..v)
                set_volumes(4,0,{v,v,v})
                if not o then sfx(4) o=true end
            end
        elseif s==2 then
            -- sfx(4)
            s=3
        elseif s==3 then
            if t%4 then
                if o then
                    o=false
                    sfx(4)
                else
                    o=true
                    sfx(4,-2)
                end
            end
            t+=1
            if t>20 then s=4 sfx(5) end
        else
            sfx(4,-2)
            deli(entities,entity)
        end
    end,
    draw=function(_ENV)
        if s==4 then return end
        for i=1,12 do
            for dx=0,7 do
                pset(x+dx,y+rnd(l),(dx<3 or dx>4) and 1 or 11)
            end
        end
        if s>2 then
            if o then
                rectfill(x,y,x+7,y+l, 0)
                if t>18 then
                    for i=ty1,ty2 do mset(tx,i,0) end
                end
            end
        end
    end
})