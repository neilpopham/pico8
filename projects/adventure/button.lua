button=entity:new({
    reset=function(_ENV)
        s,beam=1,0
    end,
    update=function(_ENV)
        if s==2 then return end
        if (x+dx1<=p.x+7) and
            (p.x<x+4) and
            (y+1<=p.y2+5) and
            (p.y1<y+6) then
            dx1=dx1==0 and 0 or 7
            dx2=dx1==0 and 0 or 7
            s=2
            -- sfx(6)
            poke(0x4300+idx,1)
        end
    end,
    draw=function(_ENV)
        rectfill(x+dx1,y+1,x+dx2,y+6,10)
    end
})