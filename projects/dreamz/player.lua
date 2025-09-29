player=class:new({
    reset=function(_ENV)
        s=0
        dx=0
        dy=0
    end,
    update=function(_ENV)
        -- ⬅️➡️⬆️⬇️🅾️❎
        -- stationary
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
        -- moving
        else
            x+=dx
            y+=dy
            -- printh('nx='..nx..' ny='..ny..' x='..x..' y='..y)
            if x==nx and y==ny then
                dx,dy,s=0,0,0
            end
        end

        room=rif[y\16+1][x\16+1]
        local proom=rooms[room]
        for k,o in ipairs(rooms) do
            o.hidden=true
        end
        proom.hidden=false
        rx=proom.x*112
        ry=proom.y*112
        local rs={}

        if proom.mask&1==1 then
            local d=abs(x-rx-48)+abs(y-ry)
            if d<56 then add(rs,1) end
        end
        if proom.mask&2==2 then
            local d=abs(rx+96-x)+abs(y-ry-48)
            if d<56 then add(rs,2) end
        end
        if proom.mask&4==4 then
            local d=abs(x-rx-48)+abs(ry+96-y)
            if d<56 then add(rs,4) end
        end
        if proom.mask&8==8 then
            local d=abs(x-rx)+abs(y-ry-48)
            if d<56 then add(rs,8) end
        end

        for mr in all(rs) do
            for k,o in ipairs(rooms) do
                if o.x==proom.x then
                    if mr==1 and o.y==proom.y-1 then
                        o.hidden=false
                    end
                    if mr==4 and o.y==proom.y+1 then
                        o.hidden=false
                    end
                elseif o.y==proom.y then
                    if mr==2 and o.x==proom.x+1 then
                        o.hidden=false
                    end
                    if mr==8 and o.x==proom.x-1 then
                        o.hidden=false
                    end
                end
            end
        end
    end,
    draw=function(_ENV)
        spr(32,x,y,2,2)
        for k,o in ipairs(rooms) do
            if o.hidden then
                rectfill(o.x*112,o.y*112,o.x*112+111,o.y*112+111,0)
            end
        end
    end,
})

p=player:new({x=64,y=64})
p:reset()