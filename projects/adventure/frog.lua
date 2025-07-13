frog=entity:new({
    reset=function(_ENV)
        t=0
        stage=0
        r=range(12,16)
        -- dead=false
    end,
    update=function(_ENV)
        if stage==0 then
            -- d=p.x>x and 1 or -1
            if manhattan(x,y,p.x,p.y2)<range(16,24) then
                stage=1
                -- d=p.x<x and 1 or -1
            else
                return
            end
        end
        local dx,dy,cx,cy,tx,ty,ti
        if stage==1 then
            dx=2*d
            dy=-1
            if t==7 then sfx(0) end
        else
            dx=stage==2 and d or 0
            dy=1
        end
        cx=x+(2*d)
        cy=y+(stage==1 and -2 or 2)
        tx=tile(cx+dx)
        ty=tile(cy+dy)
        ti=mget(tx,ty)
        if fget(ti,0) then
            ti=mget(tile(cx),ty)
            if fget(ti,0) then
                if stage==1 then
                    y=ty*8+8
                else
                    y=ty*8-1
                    cy=y
                    reset(_ENV)
                end
            end
            ti=mget(tx,tile(cy))
            if fget(ti,0) then
                if ti==63 then
                    sfx(3)
                    local e=del(entities,_ENV)
                    return
                end
                x=tx*8+(d==1 and -3 or 10)
                if stage==1 and t<6 then d=d==1 and -1 or 1 end
            end
            if stage>0 then stage=3 end
            dx=0
            dy=0
        end
        x+=dx
        y+=dy
        if stage==1 then
            t+=1
            if t==r then stage=2 end
        end
    end,
    draw=function(_ENV)
        local ex=x+2*d
        local c=11
        if stage==0 then
            line(x,y,x+1,y,c)
            pset(x+(d==1 and 1 or 0),y-1,c)
        else
            line(x,y,ex,y+(stage==1 and -2 or 2),c)
        end
    end
})