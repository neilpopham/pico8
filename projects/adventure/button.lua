button=entity:new({
    reset=function(_ENV)
        s=1
        beam=0
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
            entities[beam].s=2
-- (x+hitbox.x<=object.x+object.hitbox.x2) and
--    (object.x+object.hitbox.x<x+hitbox.w) and
--    (y+hitbox.y<=object.y+object.hitbox.y2) and
--    (object.y+object.hitbox.y<y+hitbox.h)
        end
    end,
    draw=function(_ENV)
        rectfill(x+dx1,y+1,x+dx2,y+6,10)
    end
})