beam=entity:new({
    reset=function(_ENV)
        x=tx*8
        y=ty1*8
        l=(ty2-ty1+1)*8
        o=false
        s=1
        t=0
        w=7
        yl=y+l-1
        particles={}
        for i=0,l\2 do
            add(particles,{x=x+rnd(w),y=y,d=1,s=range(2,5)})
            add(particles,{x=x+rnd(w),y=yl,d=-1,s=range(2,5)})
        end
    end,
    update=function(_ENV)
        if s==1 then
            local d=min(manhattan(x,y,p.x,p.y1),manhattan(x,y+l,p.x,p.y2))
            local max=160
            if d>max then
                beam_volume[idx]=0
            else
                local v=round(mid(0,(max-d)/(max/7),7))
                beam_volume[idx]=v
            end
            if peek(0x4300+idx)>0 then s=2 end
        elseif s==2 then
            sfx(4)
            s=3            --
        elseif s==3 then
            if t%4 then
                beam_volume[idx]*=-1
            end
            t+=1
            if t>20 then s=4 sfx(5) end
        elseif s==4 then
            beam_volume[idx]=0
            del(entities,_ENV)
            for i=ty1,ty2 do mset(tx,i,0) end
        end

        for px in all(particles) do
            local reset=false
            if px.d==1 then
                px.y+=px.s
                if px.y>yl then
                    reset=true
                    px.y=y
                end
            else
                px.y-=px.s
                if px.y<y then
                    reset=true
                    px.y=yl
                end
            end
            if reset then
                px.s=range(1,5)
                px.x=x+rnd(w)
                if s>2 then del(particles,px) end
            end
        end
    end,
    draw=function(_ENV)
        local v=0
        for bv in all(beam_volume) do
            if bv>v then v=bv end
        end
        if max==0 then
            sfx(4,-2)
        else
            set_volumes(4,0,{v,v,v})
            sfx(4)
        end
        for px in all(particles) do
            pset(px.x,px.y,11)
        end
    end
})