player=class:new({
    reset=function(_ENV)
        y2=y1
        d=1
        s=0
        t=0
        dx=0
        dy=0
        o1=0
        o2=0
        o1c={}
        grounded=true
        jc=0
        cc=0
        button=false
    end,
    update=function(_ENV)
        if btn(❎) or btn(🅾️) then
            if button==false and jc==0 and (grounded or cc>0) then
                jc,o1=12,0
            end
            button=true
        else
            jc,button=0,false
        end

        if jc>0 then
            dy-=1
            jc-=1
            grounded=false
        end

        dy+=0.5
        dy=mid(-3,dy,3)
        local rdy,hit=round(dy)

        for tx in all({tile(x), tile(x+7)}) do
            ty=dy>0 and tile(y2+o2+7+rdy) or tile(y1+o1+rdy)
            ti=mget(tx,ty)
            hit=fget(ti,0)
            if hit then break end
        end

        if hit then
            if dy>0 then
                if not grounded then
                    if rdy>1 then
                        for i=0,rdy do add(o1c,i) end
                        for i=rdy,0,-1 do add(o1c,i) end
                    end
                    t=0
                end
                grounded=true
                local py=ty*8-8
                p.y1,p.y2=py,py
            else

            end
            dy,rdy=0,0
        elseif grounded then
            dy,rdy,cc,grounded=0,0,3,false
        elseif cc>0 then
            dy,rdy=0,0
            cc-=1
        end

        y1+=rdy
        y2+=rdy

        o2=rdy!=0 and abs(rdy) or 0

        if btn(⬅️) then dx-=.3 d=-1 end
        if btn(➡️) then dx+=.3 d=1 end

        dx*=(grounded and .8 or .8)
        if abs(dx)<.05 then dx=0 end
        dx=mid(-3,dx,3)
        local rdx=round(dx)

        hit=false
        for ty in all({tile(y1), tile(y1+4), tile(y2+7)}) do
            tx=tile(x+rdx+(dx>0 and 7 or 0))
            ti=mget(tx,ty)
            local flags=fget(ti)
            hit=flags & 1==1
            if hit then break end
            if flags & 2==2 then
                printh('HIDDEN ROOM TRIGGER')
            end
        end
        if hit then
            x=(tx+(dx>0 and -1 or 1))*8
            dx,rdx=0,0
            if ti==63 then
                sfx(3)
            end
        end

        x+=rdx

        if #o1c>0 then
            o1=deli(o1c)
        elseif btn(⬇️) then
            o1c,o1={},3
        elseif grounded and rdx!=0 then
            if t%4==0 then o1=o1==0 and 1 or 0 end
        else
            o1=0
        end

        t+=1
    end,
    draw=function(_ENV)
        local r1,r2=y1+o1+4,y2+o2+4
        rectfill(x,r1,x+7,r2,12)
        spr(83,x,y2+o2,1,1,d!=1)
        spr(67,x,y1+o1,1,1,d!=1)
    end,
})

p=player:new({x=24,y1=496})
p:reset()