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
                local hit=false
                local tx=tile(x+dx+(dx>0 and 15 or 0))
                local ty=tile(y+dy+(dy>0 and 15 or 0))
                local ti=mget(tx,ty)
                if ti==0 then
                    hit=true
                else
                    hit=fget(ti,0)
                end
                -- printh('tx='..tx..' ty='..ty..' tile='..ti..' flags='..(fget(ti)))
                if hit then
                    dx,dy=0,0
                else
                    nx,ny,s=x+(dx*16),y+(dy*16),1
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

        room=rif[y\16+1][x\16+1]
        local prms=rms[room]
        for k,o in ipairs(rms) do
            o.hidden=true
        end
        prms.hidden=false
        rx=prms.x*112
        ry=prms.y*112
        local md,mr=999

        if prms.mask&1==1 then
            local d=abs(x-rx-48)+abs(y-ry)
            if d<md then md=d mr=1 end
        end
        if prms.mask&2==2 then
            local d=abs(rx+128-x)+abs(y-ry-48)
            if d<md then md=d mr=2 end
        end
        if prms.mask&4==4 then
            local d=abs(x-rx-48)+abs(ry+128-y)
            if d<md then md=d mr=4 end
        end
        if prms.mask&8==8 then
            local d=abs(x-rx)+abs(y-ry-48)
            if d<md then md=d mr=8 end
        end

        for k,o in ipairs(rms) do
            if o.x==prms.x then
                if mr==1 and o.y==prms.y-1 then
                    o.hidden=false
                end
                if mr==4 and o.y==prms.y+1 then
                    o.hidden=false
                end
            elseif o.y==prms.y then
                if mr==2 and o.x==prms.x+1 then
                    o.hidden=false
                end
                if mr==8 and o.x==prms.x-1 then
                    o.hidden=false
                end
            end
        end




        -- for k,o in ipairs(rms) do
        --     if o.x==prms.x then
        --         if prms.mask&1==1 and o.y==prms.y-1 then
        --             o.hidden=false
        --         end
        --         if prms.mask&4==4 and o.y==prms.y+1 then
        --             o.hidden=false
        --         end
        --     elseif o.y==prms.y then
        --         if prms.mask&2==2 and o.x==prms.x+1 then
        --             o.hidden=false
        --         end
        --         if prms.mask&8==8 and o.x==prms.x-1 then
        --             o.hidden=false
        --         end
        --     end
        -- end
    end,
    draw=function(_ENV)
        spr(32,x,y,2,2)
        for k,o in ipairs(rms) do
            if o.hidden then
                rectfill(o.x*112,o.y*112,o.x*112+111,o.y*112+111,0)
            end
        end

        -- local tx,ty=tile(x),tile(y)
        -- sx=max(0,tx-8)
        -- sy=max(0,ty-8)
        -- ex=tx+9
        -- ey=ty+9
        -- for cy=sy,ey do
        --     for cx=sx,ex do
        --         if not los(tx,ty,cx,cy) then
        --         rectfill(cx*8,cy*8,cx*8+7,cy*8+7,0)
        --         end
        --     end
        -- end


    end,
})

p=player:new({x=64,y=64})
p:reset()